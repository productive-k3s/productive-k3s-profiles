#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
COMMAND_NAME="stack-up"
STACK_REGISTRY_CONVERGENCE_ATTEMPTS="${STACK_REGISTRY_CONVERGENCE_ATTEMPTS:-2}"
stack_artifact_local_tgz=""

cleanup_stack_bootstrap() {
  local exit_code=$?
  if [[ -n "${stack_artifact_local_tgz}" ]]; then
    rm -f "${stack_artifact_local_tgz}"
  fi
  complete_infra_command_telemetry "${exit_code}" "${COMMAND_NAME}"
}

trap cleanup_stack_bootstrap EXIT

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

case "${PRODUCTIVE_K3S_SOURCE_RESOLVED}" in
  local)
    package_stack_script="${PRODUCTIVE_K3S_ADDONS_REPO_DIR}/scripts/package-stack.sh"
    [[ -f "${package_stack_script}" ]] || {
      err "productive-k3s-addons stack packager not found at ${package_stack_script}"
      exit 1
    }
    stack_artifact_local_tgz="$(mktemp "${HOME}/pk3s-stack-artifact-XXXXXX.tgz")"
    log "Packaging local base stack from ${PRODUCTIVE_K3S_ADDONS_REPO_DIR}"
    bash "${package_stack_script}" --stack base --output "${stack_artifact_local_tgz}"
    tar -tzf "${stack_artifact_local_tgz}" >/dev/null
    chmod 0644 "${stack_artifact_local_tgz}"
    mp_exec "${SERVER_NAME}" "rm -f '${PRODUCTIVE_K3S_STACK_REMOTE_PATH_RESOLVED}'"
    mp_transfer_to "${stack_artifact_local_tgz}" "${SERVER_NAME}" "${PRODUCTIVE_K3S_STACK_REMOTE_PATH_RESOLVED}"
    rm -f "${stack_artifact_local_tgz}"
    stack_artifact_local_tgz=""
    ;;
  remote)
    log "Downloading published stack artifact from ${PRODUCTIVE_K3S_STACK_TGZ_URL_RESOLVED}"
    mp_exec "${SERVER_NAME}" "curl -fsSL '${PRODUCTIVE_K3S_STACK_TGZ_URL_RESOLVED}' -o '${PRODUCTIVE_K3S_STACK_REMOTE_PATH_RESOLVED}'"
    ;;
  *)
    err "unsupported Productive K3S source: ${PRODUCTIVE_K3S_SOURCE_RESOLVED}"
    exit 1
    ;;
esac
mp_exec "${SERVER_NAME}" "tar -tzf '${PRODUCTIVE_K3S_STACK_REMOTE_PATH_RESOLVED}' >/dev/null"

run_stack_bootstrap_session() {
  python3 "${SCRIPT_DIR}/run_bootstrap_session.py" \
    --instance "${SERVER_NAME}" \
    --mode stack \
    --remote-dir "${REMOTE_DIR}" \
    --stack-tgz "${PRODUCTIVE_K3S_STACK_REMOTE_PATH_RESOLVED}" \
    --base-domain "${BASE_DOMAIN}" \
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
