# Make Targets

`make` is the main development and content-validation interface of this repository.

Published profiles are consumed through `pk3s` or `productive-k3s-infra`, not through a dedicated runtime CLI in this repo:

```bash
pk3s infra install multipass-1-server-2-agents
./productive-k3s-infra.sh profile install --tgz ./multipass-1-server-2-agents.tgz
```

The root targets below are intentionally source-oriented and are aimed at repository development, CI, and scenario authoring.

## Root-level targets

| Target | Purpose |
| --- | --- |
| `make docs-build` | Build the MkDocs site strictly |
| `make docs-serve` | Serve the docs locally |
| `make docs-up` | Run the docs server in the background |
| `make docs-down` | Stop the docs server and clean docs artifacts |
| `make test-static PROFILE=...` | Run only the `static` suite for the selected public profile or scenario |
| `make test-contract PROFILE=...` | Run only the `contract` suite for the selected public profile or scenario |
| `make test-live PROFILE=...` | Run only the `live` suite for the selected public profile or scenario |
| `make test-matrix` | Run `static + contract` across all public scenarios |
| `make test-live-matrix` | Run `live` across all public scenarios |

Supported selector inputs:

- `PROFILE=<published-profile-name>`
- `SCENARIO=<source-scenario-name>`

Examples:

```bash
make test-static PROFILE=multipass-1-server-2-agents
make test-contract PROFILE=aws-single-node-basic INFRA_VERSION=0.9.62-0.9.4
make test-live PROFILE=on-prem-basic INFRA_VERSION=0.9.62-0.9.4
make test-static SCENARIO=onprem-basic
make test-matrix
```

## Infra engine selection

The root test runner validates source content against a selected version of `productive-k3s-infra`.

Available inputs:

| Variable | Purpose |
| --- | --- |
| `INFRA_VERSION` | Clone and use a specific released branch or tag of `productive-k3s-infra` |
| `PRODUCTIVE_K3S_INFRA_REPO_DIR` | Use a local Infra checkout instead of cloning a release |

Behavior:

- if `PRODUCTIVE_K3S_INFRA_REPO_DIR` is set, the local checkout wins
- if `INFRA_VERSION` is omitted, the runner resolves the latest released `productive-k3s-infra`

Examples:

```bash
make test-contract PROFILE=aws-single-node-basic INFRA_VERSION=0.9.62-0.9.4
PRODUCTIVE_K3S_INFRA_REPO_DIR=../productive-k3s-infra make test-static PROFILE=multipass-1-server-2-agents
```

## Scenario-local targets

Source-oriented scenario Makefiles still expose their own local entry points, for example:

```bash
make -C scenarios/local/multipass validate
make -C scenarios/edge/onprem-basic validate
make -C scenarios/cloud/aws-single-node infra-up
```

Those targets remain useful during authoring, but they are not the same thing as the root content-validation runner.

## Notes

!!! note
    `make test-matrix` is the intended CI-friendly root validation surface for this repository.

!!! note
    `make test-live` and `make test-live-matrix` are meant for maintainer-driven runtime validation before push or release.
