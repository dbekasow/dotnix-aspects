# Content tree under modules/ for consumer symmetry

Status: accepted

`modules/` is the single Nix content root of the library: features,
profiles, and the consumer template live under `modules/features/`,
`modules/profiles/`, and `modules/templates/` alongside the wiring
(`expose.nix`, `integration/`, `parts/`). `tests/` and `docs/` stay at the
repository root: verification and prose are not library modules. Membership
rule: everything the library flake loads or publishes as Nix lives under
`modules/`.

Motivation: consumer symmetry. The consumer keeps all of its Nix content
under `modules/` (`modules/hosts`, `modules/users`, `modules/parts.nix`);
the library now shares that shape. The
[directory-structure research](../plans/directory-structure-research.md)
(2026-10-24) rejected this layout as candidate C, but it predates the
consumer repository; consumer symmetry is a new fact that outweighs the
recorded preference for root catalogs.

Discovery stays narrow: import-tree scans `modules/features/` and
`modules/profiles/` only; wiring remains explicitly imported. Profile
assembly switches from an explicit list in `expose.nix` to the same
import-tree scan as features: adding a profile is now a file, not a list
entry. Two unreferenced wiring files, `parts/templates.nix` and
`parts/home-manager.nix`, were deleted; the template export lives in
`expose.nix` and consumers are unaffected.

## Considered Options

- **Root catalogs (research recommendation)**: keeps the producer boundary
  argument from the research, but leaves library and consumer with
  different root shapes and one more top-level directory per catalog.
- **Single scan root over all of `modules/`**: ecosystem-familiar, but
  makes `/_` exclusion rules load-bearing for keeping wiring out of
  discovery.

## Consequences

Library and consumer share `modules/` as content root. New profile files
are discovered automatically; profile files must be module-shaped, with
helpers under owner-local `_private/` paths. README and the target
architecture tree describe the new layout; the research note remains a
historical record of the pre-consumer analysis. Public outputs
(`flakeModules`, `templates.default`, the `dotnix` namespace) are
unchanged.
