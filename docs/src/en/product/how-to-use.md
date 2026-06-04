# How To Use Productive K3S Profiles

`productive-k3s-profiles` is the public source repository for profile and scenario content. In normal user-facing flows, operators consume published `profile.tgz` artifacts through `pk3s` or `productive-k3s-infra`; they do not execute this repository directly.

## Choose the matching profile

- `multipass-1-server-2-agents`: local three-node cluster on top of Multipass VMs
- `on-prem-basic` / `on-prem-arm`: bootstrap existing hosts over `SSH`
- `aws-single-node-basic`: provision one `EC2` instance with `OpenTofu` and bootstrap it remotely

## Understand the responsibility split

Each scenario in this repository defines the infrastructure behavior around the cluster, while:

- `productive-k3s-core` remains responsible for the cluster bootstrap itself
- `productive-k3s-infra` remains responsible for package execution, state, telemetry, and runtime dispatch

In practice that means `productive-k3s-profiles` owns:

- host creation or host targeting
- generated inventories and cluster metadata
- orchestration of `server`, `agent`, and `stack` phases when the scenario needs them
- scenario-specific validation

`productive-k3s-infra` then consumes that content either:

- indirectly, once `productive-k3s-ops` has built a `profile.tgz`
- or directly in development/CI flows when a temporary clone of this repository is used to validate engine compatibility

## Optional K3S install engine

The default engine remains the native Productive K3S bootstrap path.

Advanced users can also opt into:

```bash
PRODUCTIVE_K3S_ENGINE=k3sup
```

This is intentionally documented as experimental.

Why it exists:

- to show that `k3sup` can complement `productive-k3s-core`
- to let advanced users experiment with the same opinionated Productive K3S platform decisions while using a familiar K3S install backend

What it does not mean:

- `k3sup` is not the product
- `k3sup` does not replace the Productive K3S bootstrap contract
- `k3sup` does not expand the public support matrix beyond the repository's documented VM, OS, and scenario coverage

If you enable the experimental engine, you are still inside the Productive K3S support model only where the repository matrix and tests explicitly cover it.
Outside that scope, especially in custom or manually orchestrated combinations, the responsibility shifts to the experimenting user.

## Consume published profiles

The normal end-user path is package-first:

```bash
pk3s profile show multipass-1-server-2-agents
pk3s infra install multipass-1-server-2-agents
pk3s infra install aws-single-node-basic --env-file ./aws.env
```

If you are working directly with the runtime engine, the equivalent interface is `productive-k3s-infra`:

```bash
./productive-k3s-infra.sh profile validate --tgz ./multipass-1-server-2-agents.tgz
./productive-k3s-infra.sh profile install --tgz ./aws-single-node-basic.tgz --env-file ./aws.env
```

The `profile.env` embedded in a public `profile.tgz` is treated as package defaults. Installation-specific values still belong on the invoking machine through `--env-file`, especially for cloud and on-prem targets.

## Choose the Productive K3S Core source mode

Most public scenarios support two source modes:

- `PRODUCTIVE_K3S_SOURCE=local`: package a sibling local checkout of `productive-k3s-core`
- `PRODUCTIVE_K3S_SOURCE=remote`: download a published GitHub Release bundle

If `remote` is used, `PRODUCTIVE_K3S_VERSION` can pin a specific release. If it is omitted, the scenario resolves the latest release from `PRODUCTIVE_K3S_RELEASE_REPO`.

## Use the development entry points

Source-based `.env` profiles remain valid here for authoring, CI, and compatibility testing against the Infra engine.

Development examples:

```bash
make -C scenarios/local/multipass up
make -C scenarios/edge/onprem-basic validate
make -C scenarios/cloud/aws-single-node infra-up
```

In engine-side CI, `productive-k3s-infra` should clone this repository into a temporary workspace and validate that engine changes still work with the public scenario tree. That keeps `infra` decoupled from the source content while preserving compatibility coverage.

Typical scenario command patterns:

- infrastructure only: `infra-up`
- preflight only: `preflight`
- full bootstrap: `up`
- validation only: `validate`
- inspect generated state: `status`
- cleanup or teardown: `clean` or `down`

See [Make targets](../user-docs/make-targets.md) for the detailed matrix.

## Notes

!!! note
    These public scenarios are intentionally pragmatic. They are meant to be evaluable, reusable, and explainable. They are not presented as fully hardened production blueprints.

!!! note
    Generated artifacts under each scenario are part of the public workflow. They make infrastructure decisions, bootstrap inputs, and validation state easier to inspect.
