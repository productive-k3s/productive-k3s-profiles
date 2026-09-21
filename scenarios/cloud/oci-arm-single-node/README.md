# OCI ARM Single-Node Scenario

`oci-arm-single-node` creates one public OCI Ampere ARM64 VM with OpenTofu,
bootstraps `productive-k3s-core` over SSH, and leaves a working single-node
Productive K3S cluster.

This is a Community/Public ARM profile. It is useful for validation and operator
testing, not for HA or private production topology.

## Quick Start

```bash
cp scenarios/cloud/oci-arm-single-node/oci.env.example scenarios/cloud/oci-arm-single-node/oci.env
$EDITOR scenarios/cloud/oci-arm-single-node/oci.env
make -C scenarios/cloud/oci-arm-single-node up
make -C scenarios/cloud/oci-arm-single-node status
make -C scenarios/cloud/oci-arm-single-node down
```

## What You Need

Required on the control machine:

- `bash`
- `make`
- `ssh`
- `scp`
- `python3`
- `jq`
- `tar`
- `curl`
- `sha256sum`
- `tofu`
- OCI CLI configuration or environment variables accepted by the OCI provider

Required in OCI:

- a compartment for the test resources
- quota and capacity for one `VM.Standard.A1.Flex` instance
- a compatible Ubuntu ARM64 image OCID for the selected region
- credentials allowed to create and destroy compute and networking resources
- a local SSH key pair

## Required Inputs

- `OCI_COMPARTMENT_OCID`
- `OCI_REGION`
- `OCI_IMAGE_OCID`
- `OCI_SSH_PUBLIC_KEY_PATH`
- `OCI_SSH_PRIVATE_KEY_PATH`

## Defaults

- shape: `VM.Standard.A1.Flex`
- OCPUs: `4`
- memory: `24` GiB
- boot volume: `100` GiB
- SSH user: `ubuntu`

## Network

The scenario creates a public VCN, subnet, route table, internet gateway, and
security list. It opens:

- `22` for SSH
- `80` and `443` for HTTP/HTTPS services
- `6443` for the Kubernetes API

For manual validation, set all allowed CIDRs to your public IP with `/32`.

## Image Selection

`OCI_IMAGE_OCID` is explicit because OCI image OCIDs are region-specific. Use an
Ubuntu ARM64 image compatible with your selected region.

## What `up` Does

`make -C scenarios/cloud/oci-arm-single-node up`:

1. Initializes OpenTofu.
2. Creates one OCI ARM VM and simple public networking.
3. Writes metadata into `generated/`.
4. Validates SSH reachability and remote platform support.
5. Copies or downloads `productive-k3s-core`.
6. Bootstraps the K3S server on the same node.
7. Applies local host aliases on the VM for Rancher and registry.
8. Runs stack bootstrap on the same node.
9. Validates nodes, ingress, and storage behavior.

## Generated Files

- `generated/cluster.json`: public IP, private IP, SSH settings, hostnames, and provider metadata
- `generated/hosts.yml`: inventory-style host view
- `generated/tofu-outputs.json`: raw OpenTofu outputs

## Manual Validation

After `up`, run:

```bash
make -C scenarios/cloud/oci-arm-single-node status
```

Then follow [after-provisioning.md](./after-provisioning.md).

Expected result:

- one ARM64 node is `Ready`
- system pods are running or completed
- Rancher is reachable on `https://<rancher-host>` when local DNS or hosts are configured
- registry is reachable on `https://<registry-host>` when local DNS or hosts are configured

## Cleanup

Always destroy the cloud resources when the test is complete:

```bash
make -C scenarios/cloud/oci-arm-single-node down
```

Use the OCI console only as a secondary check that compute, subnet, route table,
internet gateway, security list, and VCN resources were removed.

## Notes

- This path creates one public ARM64 VM only.
- It does not create an HA control plane, private production networking, or a production load balancer.
- A real run depends on OCI tenancy policy, quota, and regional ARM capacity.
- Keep credentials and `oci.env` local; the scenario `.gitignore` excludes the env file.
