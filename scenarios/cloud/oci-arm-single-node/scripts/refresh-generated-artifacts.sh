#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCENARIO_DIR="${SCENARIO_DIR:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
CASE_PREFIX="${CASE_PREFIX:-OCI}"
export SCENARIO_DIR CASE_PREFIX

SHARED_DIR="${SCENARIO_DIR}/../../../ansible/roles/remote_cluster/files"
GENERATED_DIR="${SCENARIO_DIR}/generated"
OPENTOFU_DIR="${SCENARIO_DIR}/opentofu"
TOFU_OUTPUTS_JSON="${GENERATED_DIR}/tofu-outputs.json"
TOFU_BIN="${TOFU_BIN:-tofu}"

source "${SHARED_DIR}/common.sh"

ensure_base_requirements
need_cmd "${TOFU_BIN}"
mkdir -p "${GENERATED_DIR}"

"${TOFU_BIN}" -chdir="${OPENTOFU_DIR}" output -json > "${TOFU_OUTPUTS_JSON}"

server_ip="$(jq -r '.public_ip.value // empty' "${TOFU_OUTPUTS_JSON}")"
private_ip="$(jq -r '.private_ip.value // empty' "${TOFU_OUTPUTS_JSON}")"
instance_id="$(jq -r '.instance_id.value // empty' "${TOFU_OUTPUTS_JSON}")"
instance_name="$(jq -r '.instance_name.value // empty' "${TOFU_OUTPUTS_JSON}")"
availability_domain="$(jq -r '.availability_domain.value // empty' "${TOFU_OUTPUTS_JSON}")"

[[ -n "${server_ip}" ]] || {
  err "could not resolve OCI public IP from OpenTofu outputs"
  exit 1
}

export OCI_SERVER_IP="${server_ip}"
export OCI_AGENT_IPS=""
export OCI_CLUSTER_NAME="${OCI_CLUSTER_NAME:-$(jq -r '.cluster_name.value // "productive-k3s-oci-arm"' "${TOFU_OUTPUTS_JSON}")}"
export OCI_BASE_DOMAIN="${OCI_BASE_DOMAIN:-$(jq -r '.base_domain.value // "k3s.lab.internal"' "${TOFU_OUTPUTS_JSON}")}"
export OCI_RANCHER_HOST="${OCI_RANCHER_HOST:-$(jq -r '.rancher_host.value // empty' "${TOFU_OUTPUTS_JSON}")}"
export OCI_REGISTRY_HOST="${OCI_REGISTRY_HOST:-$(jq -r '.registry_host.value // empty' "${TOFU_OUTPUTS_JSON}")}"
export OCI_REMOTE_DIR="${OCI_REMOTE_DIR:-$(jq -r '.remote_dir.value // "/home/ubuntu/productive-k3s-core"' "${TOFU_OUTPUTS_JSON}")}"

"${SHARED_DIR}/refresh-generated-artifacts.sh"

tmp_json="$(mktemp)"
jq \
  --arg provider "oci" \
  --arg public_ip "${server_ip}" \
  --arg private_ip "${private_ip}" \
  --arg instance_id "${instance_id}" \
  --arg instance_name "${instance_name}" \
  --arg availability_domain "${availability_domain}" \
  --arg region "${OCI_REGION:-}" \
  '
  .provider = $provider
  | .region = $region
  | .server.public_ip = $public_ip
  | .server.private_ip = $private_ip
  | .server.instance_id = $instance_id
  | .server.instance_name = $instance_name
  | .network = { availability_domain: $availability_domain }
  ' \
  "${CLUSTER_JSON}" > "${tmp_json}"
mv "${tmp_json}" "${CLUSTER_JSON}"

log "Generated ${CLUSTER_JSON} from OCI OpenTofu outputs"
