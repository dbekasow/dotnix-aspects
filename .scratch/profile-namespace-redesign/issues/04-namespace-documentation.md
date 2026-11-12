# 04: Document the new namespace and composition rules

**What to build:** Update the README to describe the implemented state: the
three uniform role catalogs and the top-level reservation (cross-cutting
aspects and consumer-owned composites), role-split as the multi-role
convention, the purpose-named profile inventory (shells, graphical, core,
office, browsers, terminal and its variant, development, mail, server,
workstation, base), excludes as the variant and subtraction mechanism, and
the one-line note that freeform profile keys are includes-only with
`provides` as the upgrade path for `meta` and constraints. Refresh all code
samples to the new names. Cross-check the glossary terms (occupant, profile)
against the README wording and fix drift.

**Blocked by:** [02: Slim core to a universal baseline and add GUI domain
bundles](02-core-baseline-and-domain-bundles.md), [03: Express the
multiplexer variant with excludes](03-terminal-variant-via-excludes.md).
**Status:** ready-for-agent
**Spec/authorization:** [Canonical spec](../spec.md); ticket publication is
approved, implementation requires separate approval.

## Acceptance criteria

- [ ] README documents the catalogs, the top-level reservation, role-split,
      the profile inventory, and excludes-based variants without stale names.
- [ ] The freeform-versus-`provides` note exists with the upgrade path.
- [ ] All README and template code samples use post-rename paths and
      evaluate as written.
- [ ] Glossary and README use the same terms consistently; no orphaned
      references to removed aspects (`term-ux-herdr`, `core-home`).
- [ ] Gates pass: `nix fmt`, `typos`, scoped documentation check.

## Comments

(append discussion here)
