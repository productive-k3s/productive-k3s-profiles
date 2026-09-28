#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
stack_artifact_local_tgz=""

cleanup_stack_artifact() {
  if [[ -n "${stack_artifact_local_tgz}" ]]; then
    rm -f "${stack_artifact_local_tgz}"
  fi
}

trap cleanup_stack_artifact EXIT

ensure_base_requirements
ensure_logs_dir
load_cluster_metadata
export_resolved_telemetry_env

"${SCRIPT_DIR}/sync-hosts.sh"

stack_artifact_local_tgz="$(mktemp "${GENERATED_DIR}/stack-artifact.XXXXXX.tgz")"
case "${PRODUCTIVE_K3S_SOURCE_RESOLVED}" in
  local)
    package_stack_script="${PRODUCTIVE_K3S_ADDONS_REPO_DIR}/scripts/package-stack.sh"
    [[ -f "${package_stack_script}" ]] || {
      err "productive-k3s-addons stack packager not found at ${package_stack_script}"
      exit 1
    }
    log "Packaging local base stack from ${PRODUCTIVE_K3S_ADDONS_REPO_DIR}"
    bash "${package_stack_script}" --stack base --output "${stack_artifact_local_tgz}"
    ;;
  remote)
    log "Downloading published stack artifact on controller from ${PRODUCTIVE_K3S_STACK_TGZ_URL_RESOLVED}"
    log "Controller download started at $(date -Iseconds)"
    timeout --foreground "$((PRODUCTIVE_K3S_STACK_DOWNLOAD_REQUEST_TIMEOUT_SECONDS + 30))" \
    curl --fail --silent --show-error --location \
        --retry "${PRODUCTIVE_K3S_STACK_DOWNLOAD_MAX_RETRIES}" \
        --retry-all-errors \
        --retry-delay 2 \
        --connect-timeout "${PRODUCTIVE_K3S_STACK_DOWNLOAD_CONNECT_TIMEOUT_SECONDS}" \
        --max-time "${PRODUCTIVE_K3S_STACK_DOWNLOAD_REQUEST_TIMEOUT_SECONDS}" \
        --write-out '\n[INFO] curl stats: code=%{http_code} dns=%{time_namelookup}s connect=%{time_connect}s tls=%{time_appconnect}s ttfb=%{time_starttransfer}s total=%{time_total}s size=%{size_download} bytes speed=%{speed_download} bytes/s\n' \
        "${PRODUCTIVE_K3S_STACK_TGZ_URL_RESOLVED}" \
        -o "${stack_artifact_local_tgz}"
    log "Controller download finished at $(date -Iseconds)"
    ;;
  *)
    err "unsupported Productive K3S source: ${PRODUCTIVE_K3S_SOURCE_RESOLVED}"
    exit 1
    ;;
esac

log "Controller stack artifact ready at ${stack_artifact_local_tgz} ($(wc -c < "${stack_artifact_local_tgz}") bytes)"
tar -tzf "${stack_artifact_local_tgz}" >/dev/null
remote_exec "${SERVER_IP}" "rm -f '${PRODUCTIVE_K3S_STACK_REMOTE_PATH_RESOLVED}'"
log "Uploading stack artifact to remote host ${SERVER_IP}"
scp_to "${stack_artifact_local_tgz}" "${SERVER_IP}" "${PRODUCTIVE_K3S_STACK_REMOTE_PATH_RESOLVED}"
log "Validating remote stack artifact at ${PRODUCTIVE_K3S_STACK_REMOTE_PATH_RESOLVED}"
remote_exec "${SERVER_IP}" "tar -tzf '${PRODUCTIVE_K3S_STACK_REMOTE_PATH_RESOLVED}' >/dev/null"
rm -f "${stack_artifact_local_tgz}"
stack_artifact_local_tgz=""

python3 "${SCRIPT_DIR}/run_remote_bootstrap_session.py" \
  --host "${SERVER_IP}" \
  --user "${ONPREM_SSH_USER}" \
  --port "${ONPREM_SSH_PORT}" \
  --key-path "${ONPREM_SSH_KEY_PATH}" \
  --extra-opts "${ONPREM_SSH_EXTRA_OPTS}" \
  --mode stack \
  --remote-dir "${REMOTE_DIR}" \
  --stack-tgz "${PRODUCTIVE_K3S_STACK_REMOTE_PATH_RESOLVED}" \
  --base-domain "${BASE_DOMAIN}" \
  --log-file "${LOG_DIR}/bootstrap-stack.log"

"${SCRIPT_DIR}/reconcile-cluster-defaults.sh"

log "Stack bootstrap completed"
