# 01: Unify role catalogs, split multi-role features, rename profiles

**What to build:** Make the three role catalogs complete and uniform. Move
every home-only aspect from the namespace top level into `dotnix.home.*`
(about seventy aspects, for example `dotnix.bat` becomes `dotnix.home.bat`;
assign by class content, so `handy-service` lands in its owning catalog).
`dotnix.popup-launchers` stays top-level as the cross-cutting exception.
Role-split the multiplexed features: `dotnix.dms` becomes `dotnix.host.dms`
plus `dotnix.home.dms`, `dotnix.noctalia` becomes `dotnix.host.noctalia` plus
`dotnix.home.noctalia` (nixos content to host, homeManager content to home;
`dms-plugins` follows its class content). Rename the profiles:
`home.term-shell` becomes `home.shells`, `host.desktop-shell` and
`home.desktop-shell` become `host.graphical`/`home.graphical`, and
`home.core-home` becomes `home.core`. Update every reference: profiles,
features, the executable template, and all tests.

**Blocked by:** None (can start immediately).
**Status:** claimed
**Spec/authorization:** [Canonical spec](../spec.md); ticket publication is
approved, implementation requires separate approval.

## Acceptance criteria

- [ ] No home-scoped aspect exists outside `dotnix.home.*`; no host-scoped
      aspect outside `dotnix.host.*`; the only library-owned top-level
      aspects are cross-cutting (`popup-launchers`).
- [ ] `dms` and `noctalia` are selectable per role; a host-only selection
      works without pulling home content and vice versa.
- [ ] The renames `shells`, `graphical`, and `core` are applied everywhere;
      no stale references remain in features, profiles, template, tests, or
      README code samples.
- [ ] `with dotnix.home; [ bat fd ripgrep ]` style selections resolve
      uniformly.
- [ ] Gates pass: `nix fmt`, `nix flake check --no-build --no-write-lock-file`,
      `tests/broad-compositions.nix` (updated), `tests/headless-composition.nix`,
      `tests/niri-dms.nix`, `typos`; the template consumer evaluates and builds.

## Comments

(append discussion here)
