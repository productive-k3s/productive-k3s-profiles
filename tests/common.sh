#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEMP_INFRA_DIR=""

cleanup() {
  if [[ -n "${TEMP_INFRA_DIR}" && -d "${TEMP_INFRA_DIR}" ]]; then
    rm -rf "${TEMP_INFRA_DIR}"
  fi
}
trap cleanup EXIT

log() {
  printf '[INFO] %s\n' "$*"
}

warn() {
  printf '[WARN] %s\n' "$*" >&2
}

fail() {
  printf '[FAIL] %s\n' "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

resolve_latest_infra_release() {
  need_cmd curl
  need_cmd jq
  curl -fsSL "https://api.github.com/repos/jemacchi/productive-k3s-infra/releases/latest" | jq -r '.tag_name // empty'
}

prepare_infra_checkout() {
  if [[ -n "${PRODUCTIVE_K3S_INFRA_REPO_DIR:-}" ]]; then
    [[ -d "${PRODUCTIVE_K3S_INFRA_REPO_DIR}/tests" && -d "${PRODUCTIVE_K3S_INFRA_REPO_DIR}/scripts" ]] || fail "invalid PRODUCTIVE_K3S_INFRA_REPO_DIR: ${PRODUCTIVE_K3S_INFRA_REPO_DIR}"
    TEMP_INFRA_DIR="$(mktemp -d)"
    cp -a "${PRODUCTIVE_K3S_INFRA_REPO_DIR}/." "${TEMP_INFRA_DIR}/"
    INFRA_REPO_DIR="${TEMP_INFRA_DIR}"
    return 0
  fi

  local ref="${INFRA_VERSION:-}"
  if [[ -z "${ref}" ]]; then
    ref="$(resolve_latest_infra_release)"
    [[ -n "${ref}" ]] || fail "could not resolve latest productive-k3s-infra release"
  fi

  need_cmd git
  TEMP_INFRA_DIR="$(mktemp -d)"
  git clone --depth 1 --branch "${ref}" \
    "${PRODUCTIVE_K3S_INFRA_REPO_URL:-https://github.com/jemacchi/productive-k3s-infra.git}" \
    "${TEMP_INFRA_DIR}" >/dev/null 2>&1 || fail "could not clone productive-k3s-infra ref ${ref}"
  INFRA_REPO_DIR="${TEMP_INFRA_DIR}"
}

discover_scenarios() {
  local scenario_root="${REPO_DIR}/scenarios"
  if [[ ! -d "${scenario_root}" ]]; then
    return 0
  fi

  find "${scenario_root}" -mindepth 2 -maxdepth 2 -type d | while read -r dir; do
    basename "${dir}"
  done | sort -u
}

resolve_scenario_from_profile() {
  local requested="$1"
  case "${requested}" in
    multipass-1-server-2-agents) printf 'multipass\n' ;;
    aws-single-node-basic) printf 'aws-single-node\n' ;;
    on-prem-basic|onprem-basic) printf 'onprem-basic\n' ;;
    on-prem-arm|onprem-basic-arm) printf 'onprem-basic-arm\n' ;;
    *) return 1 ;;
  esac
}

resolve_scenario() {
  if [[ -n "${SCENARIO:-}" ]]; then
    printf '%s\n' "${SCENARIO}"
    return 0
  fi
  if [[ -n "${PROFILE:-}" ]]; then
    resolve_scenario_from_profile "${PROFILE}" || fail "could not resolve scenario from PROFILE=${PROFILE}"
    return 0
  fi
  fail "set PROFILE=<name> or SCENARIO=<name>"
}

resolve_category() {
  local scenario="$1"
  if [[ -d "${REPO_DIR}/scenarios/local/${scenario}" ]]; then
    printf 'local\n'
  elif [[ -d "${REPO_DIR}/scenarios/edge/${scenario}" ]]; then
    printf 'edge\n'
  elif [[ -d "${REPO_DIR}/scenarios/cloud/${scenario}" ]]; then
    printf 'cloud\n'
  else
    fail "unknown scenario: ${scenario}"
  fi
}

run_infra_matrix_level() {
  local level="$1"
  local scenario="$2"
  PRODUCTIVE_K3S_PROFILES_REPO_DIR="${REPO_DIR}" \
    bash "${INFRA_REPO_DIR}/tests/run-matrix.sh" "${level}" "${scenario}"
}

run_scenario_level() {
  local level="$1"
  local scenario="$2"
  local category
  category="$(resolve_category "${scenario}")"
  bash "${REPO_DIR}/tests/${category}/run.sh" "${level}" "${scenario}" "${INFRA_REPO_DIR}"
}

run_matrix_levels() {
  local levels=("$@")
  local scenarios=()
  while IFS= read -r scenario; do
    [[ -n "${scenario}" ]] && scenarios+=("${scenario}")
  done < <(discover_scenarios)

  if ((${#scenarios[@]} == 0)); then
    warn "no scenarios found under ${REPO_DIR}/scenarios"
    return 0
  fi

  local level scenario
  for level in "${levels[@]}"; do
    for scenario in "${scenarios[@]}"; do
      run_scenario_level "${level}" "${scenario}"
    done
  done
}

main() {
  local command="${1:-}"
  shift || true
  prepare_infra_checkout

  case "${command}" in
    test-static)
      run_scenario_level static "$(resolve_scenario)"
      ;;
    test-contract)
      run_scenario_level contract "$(resolve_scenario)"
      ;;
    test-live)
      run_scenario_level live "$(resolve_scenario)"
      ;;
    test-matrix)
      run_matrix_levels static contract
      ;;
    test-live-matrix)
      run_matrix_levels live
      ;;
    *)
      fail "unsupported test command: ${command}"
      ;;
  esac
}

main "$@"
