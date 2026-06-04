# Productive K3S Profiles

**Productive K3S Profiles** is the public source repository for Productive K3S infrastructure profiles and scenarios.

This repository contains the authoring surface for:

- public `profiles/`
- public `scenarios/`
- scenario-specific helper scripts
- package metadata sidecars such as `*.package.yaml`

It is the source-of-truth content repository used by `productive-k3s-ops` to generate published `profile.tgz` artifacts.

## Relationship with the Infra engine

- `productive-k3s-infra` is the Infra engine/runtime.
- `productive-k3s-profiles` is the public source content for profiles and scenarios.
- `productive-k3s-ops` reads this repository to package and publish profile artifacts.
- `pk3s` consumes the published artifacts and does not depend on this repository directly.

The goal of this split is to avoid coupling every profile/scenario change to a new Infra engine bundle.

## Repository structure

```text
productive-k3s-profiles/
  profiles/
  scenarios/
```

## Notes

- Generated runtime state does not belong in this repository.
- Published `profile.tgz` artifacts are self-contained and are generated elsewhere.
- Private/commercial profile source content belongs in `productive-k3s-profiles-pro`.

## License

Apache License 2.0. See [LICENSE](./LICENSE).
