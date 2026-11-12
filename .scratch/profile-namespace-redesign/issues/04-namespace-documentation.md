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
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); ticket publication is
approved, implementation requires separate approval.

## Acceptance criteria

- [x] README documents the catalogs, the top-level reservation, role-split,
      the profile inventory, and excludes-based variants without stale names.
- [x] The freeform-versus-`provides` note exists with the upgrade path.
- [x] All README and template code samples use post-rename paths and
      evaluate as written.
- [x] Glossary and README use the same terms consistently; no orphaned
      references to removed aspects (`term-ux-herdr`, `core-home`).
- [x] Gates pass: `nix fmt`, `typos`, scoped documentation check.

## Comments

### Implementation (2026-11-12, worktree t04, branch impl/pnr-04-namespace-docs)

Base: `36635d0` (verified with `git log --oneline -1`). Commits: `bed493a`
(claim), `d6e08b3` (implementation). `git merge
integration/profile-namespace-redesign` → "Already up to date".

**README changes (update, not rewrite; six regions):**

- _Feature catalog and discovery_: new paragraph documenting the three
  uniform role catalogs (`dotnix.host.*`/`dotnix.home.*`/`dotnix.account.*`),
  the top-level reservation (cross-cutting `dotnix.popup-launchers`,
  consumer-owned per-user aspects and hardware profiles), and role-split as
  the multi-role convention (`host.dms`/`home.dms`, `host.noctalia`/
  `home.noctalia`; class-multiplexed single aspects retired).
- _Usage sample_: refreshed to the template's current shape — classes
  `[ "user" "homeManager" ]`, host includes gain `base` and `age-rekey`
  (the template includes `host.age-rekey` now), user includes gain
  `account.users`; paths verified against `templates/dotnix/`.
- _Composition rules_: `host.core` "no other tier" → "no other profile";
  `host.desktop`/`home.desktop` bullet now states both include their role's
  `graphical` foundation (renamed from the former desktop-shell claim);
  Herdr bullet now documents the excludes subtraction and drops the stale
  Zellij claim — `home.term-ux` keeps Tmux and Sesh (zellij is not in
  `term-ux`; it remains an individual selection).
- _Reusable profiles_: opening aligned with GLOSSARY Profile/Occupant
  wording ("optional, purpose-named combinations … not occupant
  archetypes"); new purpose-named inventory table covering all 19 profile
  modules (base, core, shells, graphical, desktop, desktop-apps, office,
  browsers, terminal, terminal-herdr, development, mail, server, workstation,
  and the five `term-*` sub-bundles as occupant-granular building blocks);
  new paragraph on `excludes` as the authoritative, subtree-scoped variant
  and subtraction mechanism with `home.terminal-herdr` as the worked example,
  plus the freeform-includes-only note with `provides` as the upgrade path
  for `meta`/constraints.

**Deviations:** the inventory table also lists `desktop` and the `term-*`
sub-bundles although the ticket's name list does not mention them — both
exist in the implemented library (`profiles/desktop.nix`, the five
`profiles/term-*.nix`), are referenced by the composition rules, and ticket
03 keeps the `term-*` bundles public by decision 7. The Zellij fix is a
factual correction against `profiles/term-ux.nix` (zellij absent).

**Code-sample verification:** registry of 157 `dotnix.(host|home|account).*`
aspects extracted from `features/` + `profiles/`; every role-qualified
README mention checked against it — zero missing (the only extraction hit
outside the registry was `home.stateVersion`, a Home Manager option, not an
aspect). Top-level mentions (`dotnix.myuser`, `dotnix.popup-launchers`,
`dotnix.flakeModules`, `dotnix.inputs`) verified against template/features/
modules. Sample paths verified present in `templates/dotnix/` host and user
modules (classes, `host.age-rekey`, `account.users` confirmed). Stale-name
grep (`term-ux-herdr`, `core-home`, `term-shell`, `desktop-shell`) clean.

**Gates:** `nix fmt` → 1 file reformatted (inventory table), re-run → 0
changed; `typos` → clean; `nix flake check --no-build --no-write-lock-file`
→ all checks passed; `bash tests/consumer-generation.sh
/tmp/pnr04-consumer-gen` → "Consumer generation lifecycle passed".

**Open items:** none.
