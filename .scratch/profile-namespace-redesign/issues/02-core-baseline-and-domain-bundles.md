# 02: Slim core to a universal baseline and add GUI domain bundles

**What to build:** Reshape the profile layer for the occupant design lens.
`host.core` keeps only the universal baseline: locale, nix, security,
certificates, ssh, age, home-manager, system-packages. `home.core` keeps
home.age, home.age-rekey, home.ssh. Move author-specific content to its
domain: git and git-alias join `home.development` while kubernetes leaves it
(the work occupant selects `dotnix.home.kubernetes` explicitly); stylix
joins the `graphical` profiles (host and home); gnupg and gpg-agent become
explicit auth selections instead of core content; fish leaves core (the
shells area owns it). `host.nur` stays individually selectable. Add the GUI domain
bundles: `home.office` (onlyoffice, thunderbird as the GUI mail client) and
`home.browsers` (firefox); shrink `home.desktop-apps` to the author's
remainder (alacritty, ghostty, handy, anki). Fill `host.server` minimally:
includes base, ssh, security.

**Blocked by:** [01: Unify role catalogs, split multi-role features, rename
profiles](01-uniform-role-catalogs.md).
**Status:** claimed
**Spec/authorization:** [Canonical spec](../spec.md); ticket publication is
approved, implementation requires separate approval.

## Acceptance criteria

- [ ] `host.core` contains exactly the universal baseline; `home.core`
      contains exactly home.age, home.age-rekey, home.ssh; both remain
      role-pure and override nothing.
- [ ] `home.development` includes git and git-alias and no longer includes
      kubernetes; `dotnix.home.kubernetes` remains individually selectable;
      `graphical` includes stylix on both roles; gnupg/gpg-agent are
      selectable without core.
- [ ] `home.office` and `home.browsers` exist and compose for a
      non-developer occupant without terminal or development content.
- [ ] `home.desktop-apps` contains only alacritty, ghostty, handy, anki.
- [ ] `host.server` includes base, ssh, security and nothing speculative.
- [ ] A representative family-occupant composition (graphical, office,
      browsers, one shell) evaluates without developer content leaking in.
- [ ] Gates pass: `nix fmt`, `nix flake check --no-build --no-write-lock-file`,
      updated composition tests, template consumer evaluation.

## Comments

(append discussion here)
