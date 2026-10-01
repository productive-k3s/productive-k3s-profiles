#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MINIMUM="${PK3S_COVERAGE_MIN:-80}"
total=0
covered=0
failures=()
declare -A referenced_scenarios=()

validate_lock() {
  local scenario_dir="$1"
  local lock="${scenario_dir}/materials.lock.yaml"
  if [[ ! -f "${lock}" ]]; then
    failures+=("${scenario_dir}: missing materials.lock.yaml")
    return 1
  fi
  if ! grep -Eq '^apiVersion:[[:space:]]+materials\.productive-k3s\.io/' "${lock}" ||
     ! grep -Eq '^kind:[[:space:]]+MaterialsLock[[:space:]]*$' "${lock}" ||
     ! grep -Eq '^[[:space:]]*materials:[[:space:]]*$' "${lock}" ||
     ! grep -Eq 'version:[[:space:]]*[^[:space:]}]+' "${lock}"; then
    failures+=("${lock}: incomplete MaterialsLock contract")
    return 1
  fi
  if grep -Eiq 'version:[[:space:]]*["'\'']?(latest|main|master|dev|development)["'\'']?([,[:space:]}]|$)' "${lock}"; then
    failures+=("${lock}: floating material version")
    return 1
  fi
}

while IFS= read -r profile_env; do
  total=$((total + 1))
  scenario_path="$(
    unset PK3S_INFRA_SCENARIO_PATH
    # shellcheck disable=SC1090
    source "${profile_env}"
    printf '%s' "${PK3S_INFRA_SCENARIO_PATH:-}"
  )"
  if [[ -z "${scenario_path}" || "${scenario_path}" == /* || "${scenario_path}" == *".."* ]]; then
    failures+=("${profile_env}: invalid PK3S_INFRA_SCENARIO_PATH")
    continue
  fi
  scenario_dir="${ROOT_DIR}/${scenario_path}"
  referenced_scenarios["${scenario_dir}"]=1
  if [[ ! -d "${scenario_dir}" ]]; then
    failures+=("${profile_env}: missing scenario ${scenario_path}")
    continue
  fi
  if validate_lock "${scenario_dir}"; then
    covered=$((covered + 1))
  fi
done < <(find "${ROOT_DIR}/profiles" -type f -name '*.env' 2>/dev/null | sort)

while IFS= read -r scenario_dir; do
  [[ -n "${referenced_scenarios["${scenario_dir}"]:-}" ]] && continue
  total=$((total + 1))
  if validate_lock "${scenario_dir}"; then
    covered=$((covered + 1))
  fi
done < <(find "${ROOT_DIR}/scenarios" -mindepth 2 -type f -name Makefile -printf '%h\n' 2>/dev/null | sort -u)

if ((total == 0)); then
  printf '[INFO] Contract coverage: N/A (no publishable profiles or scenarios)\n'
  exit 0
fi

coverage=$((covered * 100 / total))
printf '[INFO] Contract coverage: %d%% (%d/%d declarations); required: %s%%\n' "${coverage}" "${covered}" "${total}" "${MINIMUM}"
if (("${#failures[@]}" > 0)); then
  printf '[FAIL] %s\n' "${failures[@]}" >&2
fi
awk -v actual="${coverage}" -v minimum="${MINIMUM}" 'BEGIN { exit actual + 0 >= minimum + 0 ? 0 : 1 }'

