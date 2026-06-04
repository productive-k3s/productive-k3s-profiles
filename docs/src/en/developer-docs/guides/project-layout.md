# Project Layout

The repository is organized around the public source tree for Productive K3S profiles and scenarios.

## Top-level structure

```text
productive-k3s-profiles/
  profiles/
    cloud/
    edge/
    local/
  scenarios/
    cloud/
      aws-single-node/
    edge/
      onprem-basic/
      onprem-basic-arm/
    local/
      multipass/
  docs/
  scripts/
```

## Responsibility split

- `profiles/`: public profile defaults and package metadata sidecars
- `scenarios/`: public scenario implementations, helper scripts, and scenario-local Makefiles
- `docs/`: public documentation site for profiles and scenarios
- `scripts/`: repository-local helper scripts such as docs wrappers

## Generated artifacts

Each scenario may write generated metadata under its own `generated/` directory, typically including things like:

- `cluster.json`
- `hosts.yml`
- provider-specific local state or rendered inputs

These artifacts are part of the source-oriented workflow because they expose the resolved runtime view of the scenario.

## Notes

!!! note
    Public package execution does not happen in this repository. Operators consume the published artifacts through `pk3s` or `productive-k3s-infra`.

!!! note
    Compatibility with the Infra engine is validated by engine-side CI cloning this repository into a temporary workspace.
