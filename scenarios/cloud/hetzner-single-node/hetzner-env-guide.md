# Hetzner Env Guide

Fill `scenarios/cloud/hetzner-single-node/hetzner.env` from
`hetzner.env.example`.

## Minimum Required Variables

```dotenv
HCLOUD_TOKEN=...
HETZNER_LOCATION=fsn1
HETZNER_SSH_PUBLIC_KEY_PATH=/home/me/.ssh/id_ed25519.pub
HETZNER_SSH_PRIVATE_KEY_PATH=/home/me/.ssh/id_ed25519
```

## Authentication

Create a Hetzner Cloud API token with read/write access and store it only in the
local `hetzner.env` file:

```dotenv
HCLOUD_TOKEN=...
```

Do not commit this file. The scenario `.gitignore` excludes it.

## Infrastructure

```dotenv
HETZNER_CLUSTER_NAME=productive-k3s-hetzner
HETZNER_LOCATION=fsn1
HETZNER_SERVER_TYPE=cx32
HETZNER_IMAGE=ubuntu-24.04
HETZNER_SSH_KEY_NAME=productive-k3s
HETZNER_SSH_USER=root
HETZNER_SSH_PORT=22
```

The default `cx32` is the basic validation size for this profile. Increase it if
you plan to keep heavier stacks running after the initial test.

## Networking

```dotenv
HETZNER_SSH_ALLOWED_CIDR=203.0.113.10/32
HETZNER_HTTP_ALLOWED_CIDR=203.0.113.10/32
HETZNER_API_ALLOWED_CIDR=203.0.113.10/32
```

Recommended first run: restrict all three CIDRs to your current public IP with
`/32`.

## Hostnames

```dotenv
HETZNER_BASE_DOMAIN=k3s.lab.internal
HETZNER_RANCHER_HOST=rancher.k3s.lab.internal
HETZNER_REGISTRY_HOST=registry.k3s.lab.internal
HETZNER_REMOTE_DIR=/root/productive-k3s-core
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
