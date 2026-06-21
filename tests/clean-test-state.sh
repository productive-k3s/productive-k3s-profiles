#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

bash "${SCRIPT_DIR}/clean-test-artifacts.sh"
find "${REPO_DIR}" -maxdepth 1 \( -name '.tmp' -o -name '.tmp-*' -o -name '.live-*' \) -exec rm -rf {} +
