# TODO

Simple, versioned backlog for `productive-k3s-profiles` only.

Format:
- `Title`: short action-oriented label
- `Description`: one sentence, max 250 chars, easy to scan in reviews

Rules:
- Keep only repo-local responsibilities here.
- Do not track work owned by other repositories.
- Cross-repo dependencies can be mentioned only as context, never as the main ownership of an item.

## Source Content Contracts

- `Review Profile Input Sidecars`
  `Check that package metadata sidecars remain complete and consistent enough for packaging, validation, and higher-level CLI experiences.`

- `Clarify Scenario Packaging Expectations`
  `Document what source content must be self-contained before Ops packages it into profile artifacts for public consumption.`

- `Identify Stable Public Profiles`
  `Mark which profiles should be treated as stable public references and which remain examples or evolving authoring content.`

## Validation and Coverage

- `Expand Contract Validation Matrix`
  `Broaden contract checks against supported Infra versions so source content regressions are caught before artifact generation.`

- `Centralize GitHub Owner and Infra/Core Release Sources`
  `Replace hardcoded jemacchi URLs with repo-local defaults in tests/common.sh, scenarios/, profiles/, and docs/ so Infra and Core release sources survive an org move cleanly.`

- `Review Live Test Scope`
  `Decide which live profile validations should stay manual and which should become expected maintainer pre-publish checks.`

- `Track Source-to-Package Drift`
  `Add simple checks that help detect when profile or scenario source changes no longer match the assumptions encoded in packaged artifacts.`
