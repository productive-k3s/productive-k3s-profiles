#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
COMMAND_NAME="stack-up"

cleanup_telemetry() {
  local exit_code=$?
  complete_infra_command_telemetry "${exit_code}" "${COMMAND_NAME}"
}

trap cleanup_telemetry EXIT

ensure_base_requirements
ensure_logs_dir
load_cluster_metadata
begin_infra_command_telemetry "${COMMAND_NAME}"
export_resolved_telemetry_env
export PRODUCTIVE_K3S_SSH_HOST="${SERVER_IP}"
export PRODUCTIVE_K3S_SSH_USER="${SSH_USER:-ubuntu}"
export PRODUCTIVE_K3S_SSH_PORT="${SSH_PORT:-22}"
export PRODUCTIVE_K3S_SSH_KEY_PATH="${SSH_KEY_PATH:-}"
export PRODUCTIVE_K3S_SSH_EXTRA_OPTS="${SSH_EXTRA_OPTS:-}"

"${SCRIPT_DIR}/sync-hosts.sh"

stack_tgz_arg=()
if [[ "${PRODUCTIVE_K3S_SOURCE_RESOLVED}" == "remote" ]]; then
  log "Downloading published stack artifact from ${PRODUCTIVE_K3S_STACK_TGZ_URL_RESOLVED}"
  mp_exec "${SERVER_NAME}" "curl -fsSL '${PRODUCTIVE_K3S_STACK_TGZ_URL_RESOLVED}' -o '${PRODUCTIVE_K3S_STACK_REMOTE_PATH_RESOLVED}'"
  mp_exec "${SERVER_NAME}" "tar -tzf '${PRODUCTIVE_K3S_STACK_REMOTE_PATH_RESOLVED}' >/dev/null"
  stack_tgz_arg=(--stack-tgz "${PRODUCTIVE_K3S_STACK_REMOTE_PATH_RESOLVED}")
fi

python3 "${SCRIPT_DIR}/run_bootstrap_session.py" \
  --instance "${SERVER_NAME}" \
  --mode stack \
  --remote-dir "${REMOTE_DIR}" \
  "${stack_tgz_arg[@]}" \
  --base-domain "${BASE_DOMAIN}" \
  --rancher-host "${RANCHER_HOST}" \
  --registry-host "${REGISTRY_HOST}" \
  --rancher-password "admin" \
  --registry-size "20Gi" \
  --longhorn-data-path "/data" \
  --longhorn-replica-count 2 \
  --log-file "${LOG_DIR}/bootstrap-stack.log"

"${SCRIPT_DIR}/reconcile-cluster-defaults.sh"

log "Stack bootstrap completed"
