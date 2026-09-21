# GCP Single-Node Scenario

`gcp-single-node` creates one public Google Compute Engine VM with OpenTofu,
bootstraps `productive-k3s-core` over SSH, and leaves a working single-node
Productive K3S cluster.

This is a Community/Public basic profile. It is useful for validation and
operator testing, not for HA or production network design.

## Quick Start

```bash
cp scenarios/cloud/gcp-single-node/gcp.env.example scenarios/cloud/gcp-single-node/gcp.env
$EDITOR scenarios/cloud/gcp-single-node/gcp.env
make -C scenarios/cloud/gcp-single-node up
make -C scenarios/cloud/gcp-single-node status
make -C scenarios/cloud/gcp-single-node down
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
- `gcloud` or a valid `GOOGLE_APPLICATION_CREDENTIALS` file

Required in GCP:

- a project with billing enabled
- Compute Engine API enabled
- credentials allowed to create and destroy VM instances and firewall rules
- a local SSH key pair
- quota for one `e2-standard-4` instance or the selected replacement type

## Required Inputs

- `GCP_PROJECT_ID`
- `GCP_REGION`
- `GCP_ZONE`
- `GCP_SSH_PUBLIC_KEY_PATH`
- `GCP_SSH_PRIVATE_KEY_PATH`

Authenticate before running OpenTofu:

```bash
gcloud auth application-default login
```

Alternatively, export `GOOGLE_APPLICATION_CREDENTIALS` with an absolute path to a
service account JSON file.

## Defaults

- machine type: `e2-standard-4`
- image family: `ubuntu-2404-lts-amd64`
- boot disk: `80` GiB
- SSH user: `ubuntu`
- network: `default`

## Network

The scenario opens:

- `22` for SSH
- `80` and `443` for HTTP/HTTPS services
- `6443` for the Kubernetes API

For manual validation, set all allowed CIDRs to your public IP with `/32`.

## What `up` Does

`make -C scenarios/cloud/gcp-single-node up`:

1. Initializes OpenTofu.
2. Creates one Compute Engine VM and firewall rules.
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
make -C scenarios/cloud/gcp-single-node status
```

Then follow [after-provisioning.md](./after-provisioning.md).

Expected result:

- one node is `Ready`
- system pods are running or completed
- Rancher is reachable on `https://<rancher-host>` when local DNS or hosts are configured
- registry is reachable on `https://<registry-host>` when local DNS or hosts are configured

## Cleanup

Always destroy the cloud resources when the test is complete:

```bash
make -C scenarios/cloud/gcp-single-node down
```

Use the GCP console only as a secondary check that the VM and firewall rules were
removed.

## Notes

- This path creates one public VM only.
- It does not create an HA control plane, private production networking, or a production load balancer.
- A real run depends on GCP billing, quotas, project policy, and IAM permissions.
- Keep credentials and `gcp.env` local; the scenario `.gitignore` excludes the env file.
