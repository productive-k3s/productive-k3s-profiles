#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCENARIO="${1:-}"

fail() {
  printf '[FAIL] %s\n' "$1" >&2
  exit 1
}

need_file() {
  local path="$1"
  [[ -f "${path}" ]] || fail "missing required file: ${path}"
}

has_pattern() {
  local pattern="$1"
  local path="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -q "${pattern}" "${path}"
  else
    grep -Eq "${pattern}" "${path}"
  fi
}

expect_output() {
  local outputs_file="$1"
  local output_name="$2"
  has_pattern "^output \"${output_name}\"" "${outputs_file}" || fail "missing output '${output_name}' in ${outputs_file}"
}

scenario_dir="${ROOT_DIR}/scenarios/cloud/${SCENARIO}"

need_file "${scenario_dir}/Makefile"
need_file "${scenario_dir}/README.md"
need_file "${scenario_dir}/after-provisioning.md"
need_file "${scenario_dir}/opentofu/main.tf"
need_file "${scenario_dir}/opentofu/outputs.tf"
need_file "${scenario_dir}/opentofu/variables.tf"
need_file "${scenario_dir}/opentofu/versions.tf"
need_file "${scenario_dir}/scripts/refresh-generated-artifacts.sh"

git -C "${ROOT_DIR}" check-ignore -q "scenarios/cloud/${SCENARIO}/generated/contract-probe" || fail "generated/ should be ignored for ${SCENARIO}"

for output_name in cluster_name base_domain remote_dir rancher_host registry_host ssh_user instance_id instance_name public_ip private_ip; do
  expect_output "${scenario_dir}/opentofu/outputs.tf" "${output_name}"
done

case "${SCENARIO}" in
  gcp-single-node)
    need_file "${ROOT_DIR}/profiles/cloud/gcp-basic/basic.env"
    need_file "${ROOT_DIR}/profiles/cloud/gcp-basic/basic.package.yaml"
    need_file "${scenario_dir}/gcp.env.example"
    need_file "${scenario_dir}/gcp-env-guide.md"
    has_pattern '^gcp\.env$' "${scenario_dir}/.gitignore" || fail "gcp.env should be ignored"
    for output_name in region zone machine_type network subnetwork; do
      expect_output "${scenario_dir}/opentofu/outputs.tf" "${output_name}"
    done
    ;;
  hetzner-single-node)
    need_file "${ROOT_DIR}/profiles/cloud/hetzner-basic/basic.env"
    need_file "${ROOT_DIR}/profiles/cloud/hetzner-basic/basic.package.yaml"
    need_file "${scenario_dir}/hetzner.env.example"
    need_file "${scenario_dir}/hetzner-env-guide.md"
    has_pattern '^hetzner\.env$' "${scenario_dir}/.gitignore" || fail "hetzner.env should be ignored"
    for output_name in location server_type datacenter firewall_id; do
      expect_output "${scenario_dir}/opentofu/outputs.tf" "${output_name}"
    done
    ;;
  oci-arm-single-node)
    need_file "${ROOT_DIR}/profiles/cloud/oci-arm/basic.env"
    need_file "${ROOT_DIR}/profiles/cloud/oci-arm/basic.package.yaml"
    need_file "${scenario_dir}/oci.env.example"
    need_file "${scenario_dir}/oci-env-guide.md"
    has_pattern '^oci\.env$' "${scenario_dir}/.gitignore" || fail "oci.env should be ignored"
    for output_name in region availability_domain shape vcn_id subnet_id; do
      expect_output "${scenario_dir}/opentofu/outputs.tf" "${output_name}"
    done
    has_pattern 'VM.Standard.A1.Flex' "${scenario_dir}/opentofu/variables.tf" || fail "OCI scenario should default to Ampere A1"
    ;;
  *)
    fail "unsupported cloud scenario '${SCENARIO}'"
    ;;
esac

printf '[PASS] cloud contract checks for %s\n' "${SCENARIO}"
