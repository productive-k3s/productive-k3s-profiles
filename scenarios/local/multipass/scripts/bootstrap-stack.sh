#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
COMMAND_NAME="stack-up"
STACK_REGISTRY_CONVERGENCE_ATTEMPTS="${STACK_REGISTRY_CONVERGENCE_ATTEMPTS:-2}"

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

run_stack_bootstrap_session() {
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
}

wait_for_rancher_registry_prereqs() {
  local kubectl_cmd
  kubectl_cmd="$(productive_k3s_remote_kubectl_cmd)"

  log "Waiting for Rancher rollout before registry verification"
  ssh_exec_with_timeout "${SERVER_IP}" 960 "${kubectl_cmd} rollout status deploy/rancher -n cattle-system --timeout=15m"
  if ssh_exec_with_timeout "${SERVER_IP}" 30 "${kubectl_cmd} get deploy/rancher-webhook -n cattle-system >/dev/null 2>&1"; then
    ssh_exec_with_timeout "${SERVER_IP}" 660 "${kubectl_cmd} rollout status deploy/rancher-webhook -n cattle-system --timeout=10m"
  else
    log "Rancher webhook deployment is not present; continuing without waiting for it"
  fi
}

registry_deployment_ready() {
  local kubectl_cmd
  kubectl_cmd="$(productive_k3s_remote_kubectl_cmd)"

  ssh_exec_with_timeout "${SERVER_IP}" 30 "${kubectl_cmd} get deploy/registry -n registry >/dev/null 2>&1" || return 1
  ssh_exec_with_timeout "${SERVER_IP}" 660 "${kubectl_cmd} rollout status deploy/registry -n registry --timeout=10m"
}

ensure_registry_stack_convergence() {
  local attempt=1

  while (( attempt <= STACK_REGISTRY_CONVERGENCE_ATTEMPTS )); do
    wait_for_rancher_registry_prereqs
    if registry_deployment_ready; then
      log "Registry deployment is ready after stack bootstrap"
      return 0
    fi

    if (( attempt == STACK_REGISTRY_CONVERGENCE_ATTEMPTS )); then
      err "registry deployment is still unavailable after ${STACK_REGISTRY_CONVERGENCE_ATTEMPTS} stack bootstrap attempt(s)"
      return 1
    fi

    warn "registry deployment missing after stack bootstrap attempt ${attempt}; retrying stack convergence"
    run_stack_bootstrap_session
    attempt=$((attempt + 1))
  done
}

run_stack_bootstrap_session
ensure_registry_stack_convergence

"${SCRIPT_DIR}/reconcile-cluster-defaults.sh"

log "Stack bootstrap completed"
