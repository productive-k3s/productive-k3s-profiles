# GCP Env Guide

Fill `scenarios/cloud/gcp-single-node/gcp.env` from `gcp.env.example`.

## Minimum Required Variables

```dotenv
GCP_PROJECT_ID=my-project
GCP_REGION=us-central1
GCP_ZONE=us-central1-a
GCP_SSH_PUBLIC_KEY_PATH=/home/me/.ssh/id_ed25519.pub
GCP_SSH_PRIVATE_KEY_PATH=/home/me/.ssh/id_ed25519
```

## Authentication

Use Application Default Credentials:

```bash
gcloud auth application-default login
```

Or point the provider at a service account JSON file:

```bash
export GOOGLE_APPLICATION_CREDENTIALS=/absolute/path/to/service-account.json
```

The credentials need enough permission to manage Compute Engine instances,
disks, network tags, and firewall rules in the selected project.

## Infrastructure

```dotenv
GCP_CLUSTER_NAME=productive-k3s-gcp
GCP_MACHINE_TYPE=e2-standard-4
GCP_BOOT_DISK_SIZE_GB=80
GCP_SSH_USER=ubuntu
GCP_NETWORK=default
GCP_SUBNETWORK=
GCP_IMAGE_PROJECT=ubuntu-os-cloud
GCP_IMAGE_FAMILY=ubuntu-2404-lts-amd64
```

Leave `GCP_NETWORK=default` unless you already know the target network. Leave
`GCP_SUBNETWORK` empty when the selected network does not require an explicit
subnetwork.

## Networking

```dotenv
GCP_SSH_ALLOWED_CIDR=203.0.113.10/32
GCP_HTTP_ALLOWED_CIDR=203.0.113.10/32
GCP_API_ALLOWED_CIDR=203.0.113.10/32
```

Recommended first run: restrict all three CIDRs to your current public IP with
`/32`.

## Hostnames

```dotenv
GCP_BASE_DOMAIN=k3s.lab.internal
GCP_RANCHER_HOST=rancher.k3s.lab.internal
GCP_REGISTRY_HOST=registry.k3s.lab.internal
GCP_REMOTE_DIR=/home/ubuntu/productive-k3s-core
```

Use hosts-file entries or DNS pointing at the VM public IP when you want browser
access to Rancher or the registry.

## Productive K3S Source

```dotenv
PRODUCTIVE_K3S_SOURCE=remote
PRODUCTIVE_K3S_VERSION=0.9.5
PRODUCTIVE_K3S_RELEASE_REPO=productive-k3s/productive-k3s-core
```

Use `PRODUCTIVE_K3S_SOURCE=remote` for normal manual validation. Use
`PRODUCTIVE_K3S_SOURCE=local` when validating local Core changes.
