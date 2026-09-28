#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  printf '[FAIL] %s\n' "$*" >&2
  exit 1
}

validate_relative_path() {
  local label="$1"
  local value="$2"
  [[ -n "${value}" ]] || fail "${label} must not be empty"
  [[ "${value}" != /* ]] || fail "${label} must be relative: ${value}"
  [[ "/${value}/" != *"/../"* ]] || fail "${label} must not escape its package: ${value}"
}

profile_count=0
while IFS= read -r profile_env; do
  unset \
    PK3S_INFRA_PROFILE_NAME PK3S_INFRA_ENGINE PK3S_INFRA_SCENARIO \
    PK3S_INFRA_CATEGORY PK3S_INFRA_SCENARIO_PATH PK3S_INFRA_INSTALL_SCRIPT \
    PK3S_INFRA_APPLY_TARGET PK3S_INFRA_STATUS_TARGET PK3S_INFRA_DESTROY_TARGET \
    PK3S_INFRA_ENV_FILE_VARIABLE PK3S_INFRA_INCLUDE_REMOTE_CLUSTER_RUNTIME

  set -a
  # shellcheck disable=SC1090
  source "${profile_env}"
  set +a

  for variable in \
    PK3S_INFRA_PROFILE_NAME PK3S_INFRA_ENGINE PK3S_INFRA_SCENARIO \
    PK3S_INFRA_CATEGORY PK3S_INFRA_SCENARIO_PATH PK3S_INFRA_INSTALL_SCRIPT \
    PK3S_INFRA_APPLY_TARGET PK3S_INFRA_STATUS_TARGET \
    PK3S_INFRA_INCLUDE_REMOTE_CLUSTER_RUNTIME; do
    [[ -n "${!variable:-}" ]] || fail "${profile_env} is missing ${variable}"
  done

  case "${PK3S_INFRA_ENGINE}" in
    opentofu|ansible|shell) ;;
    *) fail "${profile_env} declares unsupported engine ${PK3S_INFRA_ENGINE}" ;;
  esac
  case "${PK3S_INFRA_INCLUDE_REMOTE_CLUSTER_RUNTIME}" in
    true|false) ;;
    *) fail "${profile_env} must declare remote cluster runtime as true or false" ;;
  esac

  validate_relative_path PK3S_INFRA_SCENARIO_PATH "${PK3S_INFRA_SCENARIO_PATH}"
  validate_relative_path PK3S_INFRA_INSTALL_SCRIPT "${PK3S_INFRA_INSTALL_SCRIPT}"
  [[ "${PK3S_INFRA_SCENARIO_PATH}" == "scenarios/${PK3S_INFRA_CATEGORY}/"* ]] || \
    fail "${profile_env} category does not match scenario path"
  [[ -d "${ROOT_DIR}/${PK3S_INFRA_SCENARIO_PATH}" ]] || \
    fail "${profile_env} scenario path does not exist: ${PK3S_INFRA_SCENARIO_PATH}"

  for target in \
    "${PK3S_INFRA_APPLY_TARGET}" \
    "${PK3S_INFRA_STATUS_TARGET}" \
    "${PK3S_INFRA_DESTROY_TARGET:-}"; do
    [[ -z "${target}" || "${target}" =~ ^[A-Za-z0-9_.-]+$ ]] || \
      fail "${profile_env} declares unsafe make target: ${target}"
  done

  profile_count=$((profile_count + 1))
done < <(find "${ROOT_DIR}/profiles" -type f -name '*.env' | sort)

((profile_count > 0)) || fail 'no profile env files were discovered'
printf '[PASS] %d profile runtime declarations are complete and portable\n' "${profile_count}"
