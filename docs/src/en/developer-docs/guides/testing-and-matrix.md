# Testing And Matrix

`productive-k3s-profiles` owns the public source tree for scenarios, but it does not yet own a root-level runtime test harness equivalent to the old Infra repository.

## What is validated here

Today the practical validation surfaces are:

- scenario-local `make` targets inside `scenarios/...`
- packaging validation in `productive-k3s-ops`
- engine compatibility validation in `productive-k3s-infra`, which clones this repository into a temporary workspace

## Scenario-local validation

When a scenario exposes local test or review targets, run them from the scenario directory, for example:

```bash
make -C scenarios/local/multipass validate
make -C scenarios/local/multipass status
make -C scenarios/edge/onprem-basic validate
make -C scenarios/cloud/aws-single-node infra-up
```

The exact surface is owned by each scenario Makefile.

## Packaging and release validation

Published `profile.tgz` artifacts are built outside this repository by `productive-k3s-ops`.

That means packaging checks such as:

- package layout
- catalog metadata
- published artifact availability

belong in `productive-k3s-ops`, not in this repository.

## Engine compatibility validation

The Infra engine still needs to prove that runtime changes do not break public profiles.

The intended model is:

1. `productive-k3s-infra` clones `productive-k3s-profiles` into a temporary workspace
2. engine-side integration checks execute against that checkout
3. a broken public profile remains a profile problem, while a broken engine/profile interaction is caught in Infra CI

## Notes

!!! note
    If and when this repository gains its own root-level test harness, that should validate source content and scenario contracts, not duplicate the package execution responsibilities of `productive-k3s-infra`.
