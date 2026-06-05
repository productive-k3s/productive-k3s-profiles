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

case "${COMMAND}" in
  docs-build)
    exec "${REPO_DIR}/docs/build.sh" "$@"
    ;;
  docs-serve)
    exec "${REPO_DIR}/docs/serve.sh" "$@"
    ;;
  docs-up)
    exec "${REPO_DIR}/docs/serve.sh" --background "$@"
    ;;
  docs-down|docs-clean)
    exec "${REPO_DIR}/docs/clean.sh" "$@"
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
    exec "${REPO_DIR}/tests/common.sh" test-matrix "$@"
    ;;
  test-live-matrix)
    exec "${REPO_DIR}/tests/common.sh" test-live-matrix "$@"
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
