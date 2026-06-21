#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/productive-k3s-profiles-dev.sh <command> [args...]

Development commands:
  docs-build
  docs-serve
  docs-up
  docs-down
  docs-clean
  test-checkstatus
  test-checkstatus-matrix
  test-checkstatus-live
  test-clean-artifacts
  test-clean
  test-static
  test-contract
  test-live
  test-matrix
  test-live-matrix
EOF
}

if (($# == 0)); then
  usage >&2
  exit 1
fi

COMMAND="$1"
shift || true

artifacts_dir() {
  printf '%s\n' "${TEST_ARTIFACTS_DIR:-${REPO_DIR}/test-artifacts}"
}

clean_named_suite_artifacts() {
  local suite_category="$1"
  local suite_name="$2"
  rm -f "$(artifacts_dir)"/test-"${suite_category}"-*-"${suite_name}".json
}

case "${COMMAND}" in
  docs-build)
    exec bash "${REPO_DIR}/docs/build.sh" "$@"
    ;;
  docs-serve)
    exec bash "${REPO_DIR}/docs/serve.sh" "$@"
    ;;
  docs-up)
    exec bash "${REPO_DIR}/docs/serve.sh" --background "$@"
    ;;
  docs-down|docs-clean)
    exec bash "${REPO_DIR}/docs/clean.sh" "$@"
    ;;
  test-checkstatus)
    exec bash "${REPO_DIR}/tests/check-test-status.sh" --category all
    ;;
  test-checkstatus-matrix)
    exec bash "${REPO_DIR}/tests/check-test-status.sh" --category matrix
    ;;
  test-checkstatus-live)
    exec bash "${REPO_DIR}/tests/check-test-status.sh" --category live
    ;;
  test-clean-artifacts)
    exec bash "${REPO_DIR}/tests/clean-test-artifacts.sh"
    ;;
  test-clean)
    exec bash "${REPO_DIR}/tests/clean-test-state.sh"
    ;;
  test-static)
    exec "${REPO_DIR}/tests/common.sh" test-static "$@"
    ;;
  test-contract)
    exec "${REPO_DIR}/tests/common.sh" test-contract "$@"
    ;;
  test-live)
    exec "${REPO_DIR}/tests/common.sh" test-live "$@"
    ;;
  test-matrix)
    clean_named_suite_artifacts matrix test-matrix
    exec bash "${REPO_DIR}/tests/run-suite-with-artifact.sh" matrix test-matrix make -C "${REPO_DIR}/tests" test-matrix-raw
    ;;
  test-live-matrix)
    clean_named_suite_artifacts live test-live-matrix
    exec bash "${REPO_DIR}/tests/run-suite-with-artifact.sh" live test-live-matrix make -C "${REPO_DIR}/tests" test-live-matrix-raw
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    echo "Unsupported development command: ${COMMAND}" >&2
    usage >&2
    exit 1
    ;;
esac
