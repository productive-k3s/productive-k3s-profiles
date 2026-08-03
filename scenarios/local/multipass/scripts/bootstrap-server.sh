#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

ensure_base_requirements
ensure_logs_dir
load_cluster_metadata
export_resolved_telemetry_env
export PRODUCTIVE_K3S_SSH_HOST="${SERVER_IP}"
export PRODUCTIVE_K3S_SSH_USER="${SSH_USER:-ubuntu}"
export PRODUCTIVE_K3S_SSH_PORT="${SSH_PORT:-22}"
export PRODUCTIVE_K3S_SSH_KEY_PATH="${SSH_KEY_PATH:-}"
export PRODUCTIVE_K3S_SSH_EXTRA_OPTS="${SSH_EXTRA_OPTS:-}"

python3 "${SCRIPT_DIR}/run_bootstrap_session.py" \
  --instance "${SERVER_NAME}" \
  --mode server \
  --remote-dir "${REMOTE_DIR}" \
  --log-file "${LOG_DIR}/bootstrap-server.log"

printf '[INFO] Local bootstrap-server reached token capture\n' >> "${LOG_DIR}/bootstrap-server.log"

token_capture_tmp="$(mktemp)"
token_capture_attempts=12
token_capture_delay_seconds=5
token_capture_ok="false"

cleanup_token_capture_tmp() {
  rm -f "${token_capture_tmp}"
}

trap cleanup_token_capture_tmp EXIT

for ((token_capture_attempt=1; token_capture_attempt<=token_capture_attempts; token_capture_attempt++)); do
  : > "${token_capture_tmp}"
  if ssh_exec_with_timeout "${SERVER_IP}" 30 "$(productive_k3s_remote_join_token_cmd)" > "${token_capture_tmp}" 2>/dev/null; then
    if [[ -s "${token_capture_tmp}" ]]; then
      mv "${token_capture_tmp}" "${SERVER_TOKEN_FILE}"
      printf '[INFO] Local bootstrap-server captured non-empty server token\n' >> "${LOG_DIR}/bootstrap-server.log"
      token_capture_ok="true"
      break
    fi
  fi

  if (( token_capture_attempt < token_capture_attempts )); then
    warn "server token capture attempt ${token_capture_attempt}/${token_capture_attempts} returned no token; retrying in ${token_capture_delay_seconds}s"
    sleep "${token_capture_delay_seconds}"
  fi
done

if [[ "${token_capture_ok}" != "true" ]]; then
  printf '[ERROR] Local bootstrap-server failed to capture server token\n' >> "${LOG_DIR}/bootstrap-server.log"
  err "failed to capture a non-empty ${PRODUCTIVE_K3S_DISTRO} server token"
  exit 1
fi

printf '%s\n' "${SERVER_URL}" > "${SERVER_URL_FILE}"
printf '[INFO] Local bootstrap-server wrote server URL\n' >> "${LOG_DIR}/bootstrap-server.log"

log "Server bootstrap completed"
