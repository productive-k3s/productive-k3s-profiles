# Relationship With Productive K3S Infra And Core

`productive-k3s-profiles`, `productive-k3s-infra`, and `productive-k3s-core` have different responsibilities.

## What Productive K3S Core does

`productive-k3s-core` is the cluster bootstrap project. It is responsible for:

- installing `k3s`
- assembling the selected cluster mode
- installing shared stack components
- validating the resulting stack behavior

## What Productive K3S Infra does

`productive-k3s-infra` is the runtime engine. It is responsible for:

- executing packaged `profile.tgz` artifacts
- merging package defaults with local overrides
- persisting and restoring runtime state
- command dispatch, error handling, and telemetry

## What Productive K3S Profiles does

`productive-k3s-profiles` owns the public source content that prepares the infrastructure context around those bootstrap phases:

- create or target the machines
- derive node roles and service hostnames
- render generated metadata and inventory-like files
- orchestrate the bootstrap sequence across one or more nodes
- declare package metadata and defaults for published profiles

## Shared bootstrap interface

The infrastructure flows in this repository treat the `productive-k3s-core` execution modes as the public bootstrap interface:

- `single-node`
- `server`
- `agent`
- `stack`

Different scenarios consume those modes differently:

- `multipass`: `server`, `agent`, `stack`
- `onprem-basic`: `single-node` or `server`, `agent`, `stack` depending on topology
- `aws-single-node`: operationally one node, but still driven through the shared remote bootstrap layer around `productive-k3s-core`

## Why the split matters

This separation keeps infrastructure automation replaceable.

You can change:

- how machines are provisioned
- where inventories come from
- which transport is used
- how the runtime engine evolves

without redefining the core cluster bootstrap contract every time.
