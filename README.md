# Productive K3S Profiles

**Productive K3S Profiles** is where the curated deployment solutions of Productive K3S live.

If you want ready-to-use paths first, this is the solution layer to look at.

Recommended public paths today include:

- `onprem-basic` for existing hosts reachable through `SSH`
- `aws-single-node-basic` for a simple cloud evaluation path
- `multipass-1-server-2-agents` for a local multi-node path

Behind that product view, this repository contains the public `profiles/`, `scenarios/`, package metadata, and helper assets used to generate published `profile.tgz` artifacts.

## Documentation

The published documentation site for this repository is:

- [profiles.productive-k3s.io](https://profiles.productive-k3s.io/)

Local docs workflow:

```bash
make docs-build
make docs-serve
```

Detailed docs lifecycle commands live under `docs/`:

```bash
make -C docs docs-up
make -C docs docs-down
make -C docs docs-clean
```

## Content validation

This repository can validate its own public content against a selected version of the `productive-k3s-infra` engine.

Examples:

```bash
PRODUCTIVE_K3S_INFRA_REPO_URL="https://github.com/productive-k3s/productive-k3s-infra.git" PRODUCTIVE_K3S_INFRA_REPO_REF="development" make test-matrix
PRODUCTIVE_K3S_INFRA_REPO_URL="https://github.com/productive-k3s/productive-k3s-infra.git" PRODUCTIVE_K3S_INFRA_REPO_REF="development" make test-live-matrix
```

Behavior:

- `test-matrix` runs `static + contract`
- `test-live-matrix` runs live validation across every discovered scenario
- detailed targets like `test-static`, `test-contract`, and `test-live` live under `tests/`
- if `PRODUCTIVE_K3S_INFRA_REPO_URL` and/or `PRODUCTIVE_K3S_INFRA_REPO_REF` are set, the runner clones that repo/ref
- otherwise, if `INFRA_VERSION` is set, the runner clones that exact ref
- otherwise, the runner resolves the latest released `productive-k3s-infra`

## Relationship with the rest of the ecosystem

- `productive-k3s-infra` executes these curated deployment solutions.
- `productive-k3s-core` remains responsible for the Kubernetes base bootstrap.
- `productive-k3s-ops` packages and publishes the resulting profile artifacts.
- `pk3s` consumes the published artifacts and does not depend on this repository directly.

The goal of this split is to keep curated solutions evolving independently from the Infra release cadence.

## Repository structure

```text
productive-k3s-profiles/
  profiles/
  scenarios/
  docs/
```

## Notes

- Generated runtime state does not belong in this repository.
- Published `profile.tgz` artifacts are self-contained and are generated elsewhere.
- Private/commercial profile source content belongs in `productive-k3s-profiles-pro`.

## License

Apache License 2.0. See [LICENSE](./LICENSE).
