# Product Overview

`productive-k3s-profiles` is the public source repository for Productive K3S profiles and scenarios.

It does not replace:

- `productive-k3s-core`, which owns cluster bootstrap
- `productive-k3s-infra`, which owns the runtime engine that executes packaged profiles

This repository owns the public authoring surface that feeds published `profile.tgz` artifacts:

- source `profiles/`
- source `scenarios/`
- scenario-local helper scripts and defaults
- package metadata sidecars such as `*.package.yaml`

In the pages below you can see what this repository is for, how it relates to the Infra engine, and how public profile/scenario content is meant to be authored and consumed.

## Pages

- [How to use Productive K3S Profiles](how-to-use.md)
- [Reasons behind the repository](reasons-behind.md)
- [Open vs Pro](open-vs-pro.md)
- [Relationship with Productive K3S Infra and Core](productive-k3s-relationship.md)
