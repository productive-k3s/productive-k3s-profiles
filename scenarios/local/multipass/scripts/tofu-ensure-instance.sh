#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

ACTION="${1:-}"
NAME="${2:-}"
IMAGE="${3:-}"
CPUS="${4:-}"
MEMORY="${5:-}"
DISK="${6:-}"
CLOUD_INIT_FILE="${7:-}"
TEMP_CLOUD_INIT_FILE=""
MULTIPASS_LAUNCH_MAX_ATTEMPTS="${MULTIPASS_LAUNCH_MAX_ATTEMPTS:-3}"
MULTIPASS_LAUNCH_RETRY_DELAY_SECONDS="${MULTIPASS_LAUNCH_RETRY_DELAY_SECONDS:-5}"

cleanup() {
  if [[ -n "${TEMP_CLOUD_INIT_FILE}" && -f "${TEMP_CLOUD_INIT_FILE}" ]]; then
    rm -f "${TEMP_CLOUD_INIT_FILE}"
  fi
}
trap cleanup EXIT

print_recovery_hints() {
  warn "Transient Multipass errors can leave a partial cluster state."
  warn "Inspect current instances with: multipass list"
  if [[ -n "${PK3S_INFRA_PROFILE_NAME:-}" ]]; then
    warn "Retry in place with: pk3s infra install ${PK3S_INFRA_PROFILE_NAME}"
    warn "Clean retry with: pk3s infra destroy ${PK3S_INFRA_PROFILE_NAME} && pk3s infra install ${PK3S_INFRA_PROFILE_NAME}"
    return 0
  fi
  warn "Retry in place by rerunning the current install command."
  warn "If you prefer a clean retry, destroy the partial cluster and run the install again."
}

launch_instance_with_retry() {
  local name="$1"
  local image="$2"
  local cpus="$3"
  local memory="$4"
  local disk="$5"
  local cloud_init_file="$6"
  local attempt=1
  local max_attempts="${MULTIPASS_LAUNCH_MAX_ATTEMPTS}"
  local stderr_file=""
  local exit_code=0
  local last_error=""

  while (( attempt <= max_attempts )); do
    stderr_file="$(mktemp)"
    set +e
    multipass launch "${image}" \
      --name "${name}" \
      --cpus "${cpus}" \
      --memory "${memory}" \
      --disk "${disk}" \
      --cloud-init "${cloud_init_file}" \
      2> >(tee "${stderr_file}" >&2)
    exit_code=$?
    set -e

    if [[ "${exit_code}" == "0" ]]; then
      rm -f "${stderr_file}"
      return 0
    fi

    last_error="$(tr '\n' ' ' < "${stderr_file}" | sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//')"
    rm -f "${stderr_file}"

    if (( attempt < max_attempts )); then
      if [[ "${last_error}" == *'Remote "" is unknown or unreachable.'* ]]; then
        warn "multipass launch hit a transient remote resolution error for ${name}; retrying (${attempt}/${max_attempts})"
      else
        warn "multipass launch failed for ${name}; retrying (${attempt}/${max_attempts})"
      fi
      sleep "${MULTIPASS_LAUNCH_RETRY_DELAY_SECONDS}"
      attempt=$((attempt + 1))
      continue
    fi

    err "Failed to launch Multipass instance ${name} after ${max_attempts} attempts."
    if [[ -n "${last_error}" ]]; then
      err "Last multipass error: ${last_error}"
    fi
    print_recovery_hints
    return "${exit_code}"
  done

  return 1
}

[[ -n "${ACTION}" && -n "${NAME}" ]] || {
  err "usage: $0 <apply|destroy> <name> [image cpus memory disk cloud-init-file]"
  exit 2
}

ensure_base_requirements

case "${ACTION}" in
  apply)
    [[ -n "${IMAGE}" && -n "${CPUS}" && -n "${MEMORY}" && -n "${DISK}" && -n "${CLOUD_INIT_FILE}" ]] || {
      err "apply requires image, cpus, memory, disk, and cloud-init-file"
      exit 2
    }
    if multipass_instance_exists "${NAME}"; then
      state="$(multipass_state "${NAME}")"
      if [[ "${state}" != "Running" ]]; then
        log "Starting existing Multipass instance ${NAME}"
        multipass start "${NAME}"
      else
        log "Multipass instance ${NAME} already exists"
      fi
      exit 0
    fi
    log "Launching Multipass instance ${NAME}"
    TEMP_CLOUD_INIT_FILE="$(mktemp "${HOME}/pk3s-multipass-cloud-init-XXXXXX.yaml")"
    cp "${CLOUD_INIT_FILE}" "${TEMP_CLOUD_INIT_FILE}"
    ensure_multipass_ssh_key_pair
    {
      printf '\nssh_authorized_keys:\n'
      printf '  - %s\n' "$(cat "${MULTIPASS_SSH_KEY_PATH}.pub")"
    } >> "${TEMP_CLOUD_INIT_FILE}"
    chmod 0644 "${TEMP_CLOUD_INIT_FILE}"
    launch_instance_with_retry "${NAME}" "${IMAGE}" "${CPUS}" "${MEMORY}" "${DISK}" "${TEMP_CLOUD_INIT_FILE}"
    ;;
  destroy)
    if multipass_instance_exists "${NAME}"; then
      log "Deleting Multipass instance ${NAME}"
      multipass delete "${NAME}"
      multipass purge
    else
      log "Multipass instance ${NAME} already absent"
    fi
    ;;
  *)
    err "unknown action: ${ACTION}"
    exit 2
    ;;
esac
