# Profiles Test Runner

This repository exposes content-focused tests that run public profiles and scenarios against a chosen version of the `productive-k3s-infra` engine.

Supported suites:

- `static`
- `contract`
- `live`

Recommended usage:

```bash
make test-static PROFILE=multipass-1-server-2-agents
make test-contract PROFILE=aws-single-node-basic INFRA_VERSION=0.9.62-0.9.4
make test-live PROFILE=on-prem-basic INFRA_VERSION=0.9.62-0.9.4
make test-matrix
```

`test-matrix` runs only `static + contract`.

`live` is intended for manual validation before push, not for default CI.
