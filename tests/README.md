# Profiles Test Runner

This repository exposes content-focused tests that run public profiles and scenarios against a chosen version of the `productive-k3s-infra` engine.

Supported suites:

- `static`
- `contract`
- `live`

Use the root entrypoints for the main flows:

```bash
PRODUCTIVE_K3S_INFRA_REPO_URL="https://github.com/jemacchi/productive-k3s-infra.git" PRODUCTIVE_K3S_INFRA_REPO_REF="development" make test-matrix
PRODUCTIVE_K3S_INFRA_REPO_URL="https://github.com/jemacchi/productive-k3s-infra.git" PRODUCTIVE_K3S_INFRA_REPO_REF="development" make test-live-matrix
```

Artifacts and status helpers:

```bash
make -C tests test-checkstatus
make -C tests test-checkstatus-matrix
make -C tests test-checkstatus-live
make -C tests test-clean-artifacts
make -C tests test-clean
```

Use detailed targets from inside `tests/`:

```bash
make -C tests test-static PROFILE=multipass-1-server-2-agents
make -C tests test-contract SCENARIO=onprem-basic INFRA_VERSION=0.9.62-0.9.4
make -C tests test-live SCENARIO=onprem-basic INFRA_VERSION=0.9.62-0.9.4
```

`test-matrix` runs only `static + contract`.

`test-live` and `test-live-matrix` are intended for manual validation before push, not for default CI.

Resolution order for the Infra engine:

- `PRODUCTIVE_K3S_INFRA_REPO_DIR`
- `PRODUCTIVE_K3S_INFRA_REPO_URL` + `PRODUCTIVE_K3S_INFRA_REPO_REF`
- `INFRA_VERSION`
- latest released `productive-k3s-infra`
