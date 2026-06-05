# Testing And Matrix

`productive-k3s-profiles` now owns a root-level content test runner.

That runner validates public profiles and scenarios against a chosen version of the `productive-k3s-infra` engine, while still keeping runtime ownership in the Infra repository.

## Validation surfaces

There are now three practical validation layers:

- root-level content validation in this repository
- scenario-local `make` targets inside `scenarios/...`
- packaging and catalog validation in `productive-k3s-ops`

## Root-level content validation

Use the repository root when you want to validate the public source tree itself:

```bash
make test-static PROFILE=multipass-1-server-2-agents
make test-contract PROFILE=aws-single-node-basic INFRA_VERSION=0.9.62-0.9.4
make test-live PROFILE=on-prem-basic INFRA_VERSION=0.9.62-0.9.4
make test-matrix
```

Supported suites:

- `static`: shape and source-level validation
- `contract`: compatibility checks against the Infra engine contract
- `live`: real scenario execution against a selected Infra engine version

Notes:

- `test-matrix` runs only `static + contract`
- `test-live` is meant for manual pre-push validation
- if `INFRA_VERSION` is omitted, the runner resolves the latest released `productive-k3s-infra`
- if `PRODUCTIVE_K3S_INFRA_REPO_DIR` is set, the runner uses that local Infra checkout instead of cloning a release

## Why the runner delegates to Infra

The public scenarios are still source content. They are not a standalone runtime engine.

That means the root test runner here intentionally delegates execution to `productive-k3s-infra`, because the Infra harness still owns:

- temporary scenario checkout preparation
- overlay of shared `ansible/`, `scripts/`, and `tests/`
- scenario execution manifests and matrix summaries

This keeps responsibilities clean:

- `productive-k3s-profiles` validates public content
- `productive-k3s-infra` validates engine compatibility

## Scenario-local validation

Scenario-local targets remain useful during authoring, for example:

```bash
make -C scenarios/local/multipass validate
make -C scenarios/edge/onprem-basic validate
make -C scenarios/cloud/aws-single-node infra-up
```

Those targets belong to each scenario Makefile and are still source-oriented.

## Packaging and release validation

Published `profile.tgz` artifacts are built outside this repository by `productive-k3s-ops`.

That means packaging concerns such as:

- package layout
- catalog metadata
- published artifact availability

belong in `productive-k3s-ops`, not here.

## CI model

The intended default CI contract for this repository is:

1. run `make test-matrix`
2. keep `live` validation manual unless a maintainer explicitly wants to exercise it

This gives fast structural confidence in every change without forcing Multipass or cloud-dependent runtime validation on every pull request.

## Notes

!!! note
    `productive-k3s-infra` still needs its own compatibility lane that clones this repository and proves engine changes do not break public profiles.
