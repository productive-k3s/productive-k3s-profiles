#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ARTIFACTS_DIR="${TEST_ARTIFACTS_DIR:-${REPO_DIR}/test-artifacts}"
CATEGORY_FILTER="all"

usage() {
  cat <<'EOF'
Usage: ./tests/check-test-status.sh [--category matrix|live|all]
EOF
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    printf '[ERROR] Missing required command: %s\n' "$1" >&2
    exit 1
  }
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --category)
        CATEGORY_FILTER="${2:-}"
        [[ -n "${CATEGORY_FILTER}" ]] || exit 2
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        printf '[ERROR] Unsupported argument: %s\n' "$1" >&2
        exit 2
        ;;
    esac
  done
}

collect_artifacts() {
  [[ -d "${ARTIFACTS_DIR}" ]] || return 0
  find "${ARTIFACTS_DIR}" -maxdepth 1 -type f -name '*.json' -print0 | sort -z
}

format_result_line() {
  local artifact="$1"
  local suite_category suite_name status
  suite_category="$(jq -r '.suite_category // empty' "${artifact}")"
  suite_name="$(jq -r '.suite // empty' "${artifact}")"
  status="$(jq -r '.status // empty' "${artifact}")"

  [[ -n "${suite_category}" && -n "${suite_name}" && -n "${status}" ]] || return 0

  case "${CATEGORY_FILTER}" in
    all) ;;
    matrix|live)
      [[ "${suite_category}" == "${CATEGORY_FILTER}" ]] || return 0
      ;;
    *)
      printf '[ERROR] Unsupported category filter: %s\n' "${CATEGORY_FILTER}" >&2
      exit 2
      ;;
  esac

  printf '%s\t%s suite=%s\t%s\n' "${status}" "${suite_category}" "${suite_name}" "${artifact}"
}

main() {
  need_cmd jq
  parse_args "$@"

  declare -A latest_results=()
  local artifact line description
  while IFS= read -r -d '' artifact; do
    line="$(format_result_line "${artifact}")"
    if [[ -n "${line}" ]]; then
      IFS=$'\t' read -r _status description _path <<< "${line}"
      latest_results["${description}"]="${line}"
    fi
  done < <(collect_artifacts)

  local results=()
  for description in "${!latest_results[@]}"; do
    results+=("${latest_results[${description}]}")
  done

  IFS=$'\n' results=($(printf '%s\n' "${results[@]}" | sort))
  unset IFS

  if (( ${#results[@]} == 0 )); then
    printf '[WARN] No test result artifacts found in %s\n' "${ARTIFACTS_DIR}" >&2
    exit 1
  fi

  local success_count=0 failed_count=0 unknown_count=0
  local result status prefix description
  for result in "${results[@]}"; do
    IFS=$'\t' read -r status description _path <<< "${result}"
    case "${status}" in
      success) prefix='[OK]'; success_count=$((success_count + 1)) ;;
      failed) prefix='[FAIL]'; failed_count=$((failed_count + 1)) ;;
      *) prefix='[WARN]'; unknown_count=$((unknown_count + 1)) ;;
    esac
    printf '%s %s\n' "${prefix}" "${description}"
  done

  printf 'Summary: %d success, %d failed, %d unknown\n' "${success_count}" "${failed_count}" "${unknown_count}"
  (( failed_count == 0 && unknown_count == 0 ))
}

main "$@"
