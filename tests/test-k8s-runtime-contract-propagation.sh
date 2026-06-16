#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

pass() {
  printf '[PASS] %s\n' "$1"
}

check_helpers() {
  local common_sh="$1"
  local distro="$2"
  local expected_kubectl="$3"
  local expected_token="$4"
  local actual_kubectl actual_token

  actual_kubectl="$(
    PRODUCTIVE_K3S_DISTRO="${distro}" bash -lc "
      source '${common_sh}'
      productive_k3s_remote_kubectl_cmd
    "
  )"
  [[ "${actual_kubectl}" == "${expected_kubectl}" ]] || {
    printf '[FAIL] unexpected kubectl command for %s (%s): %s\n' "${common_sh}" "${distro}" "${actual_kubectl}" >&2
    exit 1
  }

  actual_token="$(
    PRODUCTIVE_K3S_DISTRO="${distro}" bash -lc "
      source '${common_sh}'
      productive_k3s_remote_join_token_cmd
    "
  )"
  [[ "${actual_token}" == "${expected_token}" ]] || {
    printf '[FAIL] unexpected join token command for %s (%s): %s\n' "${common_sh}" "${distro}" "${actual_token}" >&2
    exit 1
  }
}

MULTIPASS_COMMON="${REPO_DIR}/scenarios/local/multipass/scripts/common.sh"
ONPREM_COMMON="${REPO_DIR}/scenarios/edge/onprem-basic/scripts/common.sh"
ONPREM_ARM_COMMON="${REPO_DIR}/scenarios/edge/onprem-basic-arm/scripts/common.sh"

check_helpers \
  "${MULTIPASS_COMMON}" \
  "k3s" \
  "sudo k3s kubectl" \
  "sudo cat /var/lib/rancher/k3s/server/node-token | tr -d '\\r'"
pass "multipass common exposes k3s runtime commands"

check_helpers \
  "${MULTIPASS_COMMON}" \
  "rke2" \
  "sudo /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml" \
  "sudo cat /var/lib/rancher/rke2/server/node-token | tr -d '\\r'"
pass "multipass common exposes rke2 runtime commands"

check_helpers \
  "${ONPREM_COMMON}" \
  "rke2" \
  "sudo /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml" \
  "sudo cat /var/lib/rancher/rke2/server/node-token | tr -d '\\r'"
pass "onprem common exposes rke2 runtime commands"

check_helpers \
  "${ONPREM_ARM_COMMON}" \
  "k3s" \
  "sudo k3s kubectl" \
  "sudo cat /var/lib/rancher/k3s/server/node-token | tr -d '\\r'"
pass "onprem arm common exposes k3s runtime commands"
