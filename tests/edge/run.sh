#!/usr/bin/env bash
set -euo pipefail

LEVEL="${1:?level is required}"
SCENARIO="${2:?scenario is required}"
INFRA_REPO_DIR="${3:?infra repo is required}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCENARIO_REL_DIR="scenarios/edge/${SCENARIO}"

PRODUCTIVE_K3S_PROFILES_REPO_DIR="${REPO_DIR}" \
  bash "${INFRA_REPO_DIR}/scripts/productive-k3s-infra-dev.sh" "test-${LEVEL}-scenario" "${SCENARIO_REL_DIR}"
