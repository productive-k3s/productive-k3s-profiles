# Hetzner Single-Node Scenario

`hetzner-single-node` creates one public Hetzner Cloud VM with OpenTofu,
bootstraps `productive-k3s-core` over SSH, and leaves a working single-node
Productive K3S cluster.

This is a Community/Public basic profile. It is useful for low-cost validation
and operator testing, not for HA or private production topologies.

## Quick Start

```bash
cp scenarios/cloud/hetzner-single-node/hetzner.env.example scenarios/cloud/hetzner-single-node/hetzner.env
$EDITOR scenarios/cloud/hetzner-single-node/hetzner.env
make -C scenarios/cloud/hetzner-single-node up
make -C scenarios/cloud/hetzner-single-node status
make -C scenarios/cloud/hetzner-single-node down
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

Required in Hetzner Cloud:

- an API token with read/write access
- quota for one `cx32` server or the selected replacement type
- a local SSH key pair

## Required Inputs

- `HCLOUD_TOKEN`
- `HETZNER_LOCATION`
- `HETZNER_SSH_PUBLIC_KEY_PATH`
- `HETZNER_SSH_PRIVATE_KEY_PATH`

## Defaults

- location: `fsn1`
- server type: `cx32`
- image: `ubuntu-24.04`
- SSH user: `root`

## Network

The scenario creates a firewall for:

- `22` for SSH
- `80` and `443` for HTTP/HTTPS services
- `6443` for the Kubernetes API

For manual validation, set all allowed CIDRs to your public IP with `/32`.

## What `up` Does

`make -C scenarios/cloud/hetzner-single-node up`:

1. Initializes OpenTofu.
2. Creates one Hetzner Cloud server, SSH key entry, and firewall.
3. Writes metadata into `generated/`.
4. Validates SSH reachability and remote platform support.
5. Copies or downloads `productive-k3s-core`.
6. Bootstraps the K3S server on the same node.
7. Applies local host aliases on the VM for Rancher and registry.
8. Runs stack bootstrap on the same node.
9. Validates nodes, ingress, and storage behavior.

## Generated Files

- `generated/cluster.json`: public IP, SSH settings, hostnames, and provider metadata
- `generated/hosts.yml`: inventory-style host view
- `generated/tofu-outputs.json`: raw OpenTofu outputs

## Manual Validation

After `up`, run:

```bash
make -C scenarios/cloud/hetzner-single-node status
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
make -C scenarios/cloud/hetzner-single-node down
```

Use the Hetzner Cloud console only as a secondary check that the server and
firewall were removed.

## Notes

- This path creates one public VM only.
- It does not create an HA control plane, private production networking, or a production load balancer.
- A real run depends on token permissions, cloud quota, and regional capacity.
- Keep credentials and `hetzner.env` local; the scenario `.gitignore` excludes the env file.
