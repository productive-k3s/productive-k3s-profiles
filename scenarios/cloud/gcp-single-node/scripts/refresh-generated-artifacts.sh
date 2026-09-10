#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCENARIO_DIR="${SCENARIO_DIR:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
CASE_PREFIX="${CASE_PREFIX:-GCP}"
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
zone="$(jq -r '.zone.value // empty' "${TOFU_OUTPUTS_JSON}")"

[[ -n "${server_ip}" ]] || {
  err "could not resolve GCP public IP from OpenTofu outputs"
  exit 1
}

export GCP_SERVER_IP="${server_ip}"
export GCP_AGENT_IPS=""
export GCP_CLUSTER_NAME="${GCP_CLUSTER_NAME:-$(jq -r '.cluster_name.value // "productive-k3s-gcp"' "${TOFU_OUTPUTS_JSON}")}"
export GCP_BASE_DOMAIN="${GCP_BASE_DOMAIN:-$(jq -r '.base_domain.value // "k3s.lab.internal"' "${TOFU_OUTPUTS_JSON}")}"
export GCP_RANCHER_HOST="${GCP_RANCHER_HOST:-$(jq -r '.rancher_host.value // empty' "${TOFU_OUTPUTS_JSON}")}"
export GCP_REGISTRY_HOST="${GCP_REGISTRY_HOST:-$(jq -r '.registry_host.value // empty' "${TOFU_OUTPUTS_JSON}")}"
export GCP_REMOTE_DIR="${GCP_REMOTE_DIR:-$(jq -r '.remote_dir.value // "/home/ubuntu/productive-k3s-core"' "${TOFU_OUTPUTS_JSON}")}"

"${SHARED_DIR}/refresh-generated-artifacts.sh"

tmp_json="$(mktemp)"
jq \
  --arg provider "gcp" \
  --arg public_ip "${server_ip}" \
  --arg private_ip "${private_ip}" \
  --arg instance_id "${instance_id}" \
  --arg instance_name "${instance_name}" \
  --arg zone "${zone}" \
  --arg region "${GCP_REGION:-}" \
  '
  .provider = $provider
  | .region = $region
  | .server.public_ip = $public_ip
  | .server.private_ip = $private_ip
  | .server.instance_id = $instance_id
  | .server.instance_name = $instance_name
  | .network = { zone: $zone }
  ' \
  "${CLUSTER_JSON}" > "${tmp_json}"
mv "${tmp_json}" "${CLUSTER_JSON}"

log "Generated ${CLUSTER_JSON} from GCP OpenTofu outputs"
