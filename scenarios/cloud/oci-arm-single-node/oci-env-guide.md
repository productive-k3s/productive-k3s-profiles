# OCI Env Guide

Fill `scenarios/cloud/oci-arm-single-node/oci.env` from `oci.env.example`.

## Minimum Required Variables

```dotenv
OCI_COMPARTMENT_OCID=ocid1.compartment.oc1..example
OCI_REGION=us-ashburn-1
OCI_IMAGE_OCID=ocid1.image.oc1..ubuntu-24-04-aarch64
OCI_SSH_PUBLIC_KEY_PATH=/home/me/.ssh/id_ed25519.pub
OCI_SSH_PRIVATE_KEY_PATH=/home/me/.ssh/id_ed25519
```

## Authentication

Use the standard OCI provider configuration. The most common path is an OCI CLI
config file under `~/.oci/config`.

At minimum, confirm that your local configuration can read tenancy metadata
before running the scenario:

```bash
oci iam region list
```

The credentials need enough permission to manage compute instances, boot
volumes, VCNs, subnets, internet gateways, route tables, and security lists in
the selected compartment.

## Infrastructure

```dotenv
OCI_CLUSTER_NAME=productive-k3s-oci-arm
OCI_SHAPE=VM.Standard.A1.Flex
OCI_OCPUS=4
OCI_MEMORY_IN_GBS=24
OCI_BOOT_VOLUME_SIZE_GB=100
OCI_AVAILABILITY_DOMAIN=
OCI_IMAGE_OCID=ocid1.image.oc1..ubuntu-24-04-aarch64
OCI_SSH_USER=ubuntu
OCI_SSH_PORT=22
```

Leave `OCI_AVAILABILITY_DOMAIN` empty to use the first domain returned by OCI.
Set it explicitly when you need to target a specific availability domain.

`OCI_IMAGE_OCID` must be a region-compatible Ubuntu ARM64 image. OCI image OCIDs
are not portable between regions.

## Networking

```dotenv
OCI_SSH_ALLOWED_CIDR=203.0.113.10/32
OCI_HTTP_ALLOWED_CIDR=203.0.113.10/32
OCI_API_ALLOWED_CIDR=203.0.113.10/32
```

Recommended first run: restrict all three CIDRs to your current public IP with
`/32`.

## Hostnames

```dotenv
OCI_BASE_DOMAIN=k3s.lab.internal
OCI_RANCHER_HOST=rancher.k3s.lab.internal
OCI_REGISTRY_HOST=registry.k3s.lab.internal
OCI_REMOTE_DIR=/home/ubuntu/productive-k3s-core
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
