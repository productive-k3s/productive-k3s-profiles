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

sidecar_value() {
  local sidecar="$1" owner="$2" key="$3"
  awk -v owner="${owner}" -v key="${key}" '
    /^compatibility:/ { in_compat=1; next }
    in_compat && /^  requires:/ { in_requires=1; next }
    in_requires && $0 == "    " owner ":" { in_owner=1; next }
    in_owner && $0 ~ "^      " key ":" {
      sub("^      " key ":[[:space:]]*", "", $0)
      print
      exit
    }
    in_owner && /^    [^[:space:]]/ { exit }
  ' "${sidecar}"
}

validate_compatibility_sidecar() {
  local profile_env="$1" sidecar="${profile_env%.env}.package.yaml"
  local contract infra_min infra_max core_min core_max
  [[ -f "${sidecar}" ]] || fail "${profile_env} is missing its package compatibility sidecar"
  contract="$(sidecar_value "${sidecar}" infra contract)"
  infra_min="$(sidecar_value "${sidecar}" infra minEngineVersion)"
  infra_max="$(sidecar_value "${sidecar}" infra maxEngineVersionExclusive)"
  core_min="$(sidecar_value "${sidecar}" core minVersion)"
  core_max="$(sidecar_value "${sidecar}" core maxVersionExclusive)"
  [[ "${contract}" == "profile/v1" ]] || fail "${sidecar} must require Infra contract profile/v1"
  for value in "${infra_min}" "${infra_max}" "${core_min}" "${core_max}"; do
    [[ "${value}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || fail "${sidecar} has a malformed compatibility version: ${value:-missing}"
  done
  [[ "${infra_min}" != "${infra_max}" && "$(printf '%s\n%s\n' "${infra_min}" "${infra_max}" | sort -V | head -n1)" == "${infra_min}" ]] || fail "${sidecar} has an empty Infra compatibility window"
  [[ "${core_min}" != "${core_max}" && "$(printf '%s\n%s\n' "${core_min}" "${core_max}" | sort -V | head -n1)" == "${core_min}" ]] || fail "${sidecar} has an empty Core compatibility window"
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
  validate_compatibility_sidecar "${profile_env}"

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
