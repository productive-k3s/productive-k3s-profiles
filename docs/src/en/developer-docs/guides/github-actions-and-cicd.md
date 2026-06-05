# CI/CD Flow

`productive-k3s-profiles` uses a lightweight CI model by default.

The goal is to validate public content structure and engine compatibility contracts on every change, without forcing live runtime validation in every pull request.

## What exists today

- deterministic root `make` targets for docs and content validation
- root-level `static`, `contract`, and `live` suites
- a repository-local test runner that delegates execution to a selected version of `productive-k3s-infra`
- a default CI workflow that runs `make test-matrix`
- a separate docs workflow for the published site

## Default CI contract

The default CI path for this repository is:

1. run `make test-matrix`
2. keep `live` validation manual unless a maintainer explicitly decides to run it

In practice that means:

- `static` runs in CI
- `contract` runs in CI
- `live` is manual pre-push or pre-release validation

This keeps CI fast and reproducible while still allowing maintainers to exercise the full runtime path when needed.

## Current test workflow

The repository includes `.github/workflows/tests.yml`.

That workflow currently:

1. checks out the repository
2. installs OpenTofu
3. runs `make test-matrix INFRA_VERSION=development`

The matrix here is intentionally content-focused:

- it validates all public scenarios
- it uses the selected Infra engine version as the contract owner
- it does not run the full live runtime suite by default

## Manual live validation

Maintainers can run live validation locally before pushing sensitive scenario changes, for example:

```bash
make test-live PROFILE=multipass-1-server-2-agents INFRA_VERSION=0.9.62-0.9.4
make test-live PROFILE=on-prem-basic INFRA_VERSION=0.9.62-0.9.4
make test-live-matrix INFRA_VERSION=0.9.62-0.9.4
```

Because these flows may require Multipass, SSH reachability, or cloud credentials, they are intentionally not required on every CI run.

## Relationship with Infra CI

This repository validates public content from the content side.

`productive-k3s-infra` still needs its own compatibility lane that clones this repository and proves engine-side changes do not break public profiles.

That gives two complementary directions:

- `profiles -> infra`: does this content satisfy the expected engine contract?
- `infra -> profiles`: did an engine change break existing public content?

## Notes

!!! note
    Packaging and publication checks still belong in `productive-k3s-ops`, not in this repository.
