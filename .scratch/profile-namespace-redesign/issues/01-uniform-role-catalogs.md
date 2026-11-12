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
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); ticket publication is
approved, implementation requires separate approval.

## Acceptance criteria

- [x] No home-scoped aspect exists outside `dotnix.home.*`; no host-scoped
      aspect outside `dotnix.host.*`; the only library-owned top-level
      aspects are cross-cutting (`popup-launchers`).
- [x] `dms` and `noctalia` are selectable per role; a host-only selection
      works without pulling home content and vice versa.
- [x] The renames `shells`, `graphical`, and `core` are applied everywhere;
      no stale references remain in features, profiles, template, tests, or
      README code samples.
- [x] `with dotnix.home; [ bat fd ripgrep ]` style selections resolve
      uniformly.
- [x] Gates pass: `nix fmt`, `nix flake check --no-build --no-write-lock-file`,
      `tests/broad-compositions.nix` (updated), `tests/headless-composition.nix`,
      `tests/niri-dms.nix`, `typos`; the template consumer evaluates and builds.
      (Full template NixOS build attempted; see comments — pre-existing failure,
      identical on the integration base.)

## Comments

### Implementation (2026-11-12, worktree t01, branch impl/pnr-01-uniform-role-catalogs)

**Commits:** `1a21842` (claim), `012e3cd` (implementation, 110 files),
`5a476dc` (merge of `integration/profile-namespace-redesign` — tip had moved to
`5b6aeef`, docs-only, no conflicts).

**TDD:** test expectations rewritten to post-rename paths first. Red confirmed:
`tests/broad-compositions.nix` → `error: undefined variable 'ai-tools'`;
`tests/niri-dms.nix` → `error: attribute 'dms' missing`. Implementation then
turned both green. No assertion keys added or removed — fixture selection
paths only. Assertion counts unchanged: broad 94 (all true), niri 48 (all true).

**Gates (exact commands, exit status):**

- `nix fmt` → exit 0; re-run reports 0 changed (idempotent), tree clean.
- `nix flake check --no-build --no-write-lock-file` → exit 0, `all checks passed!`.
- `nix eval --impure --json --file tests/broad-compositions.nix` → exit 0,
  94/94 assertions true.
- `nix eval --impure --file tests/headless-composition.nix` → exit 0,
  `"headless and workstation composition checks passed"`.
- `nix eval --impure --json --file tests/niri-dms.nix` → exit 0, 48/48 true.
- `typos` → exit 0, no findings.
- `bash tests/consumer-generation.sh /tmp/pnr-consumer-gen` → exit 0,
  `Consumer generation lifecycle passed` (template consumer evaluation:
  `nixosConfigurations.myHost.config.home-manager.users.myuser.programs.direnv-instant.enable`
  evals to true).
- Full template NixOS build: **attempted, fails pre-existing, skipped.**
  `nix build .#nixosConfigurations.myHost.config.system.build.toplevel` on a
  freshly generated consumer fails with `The option
'home-manager.users.myuser.home.homeDirectory' has conflicting definition
values: "/home/myuser" vs "/var/empty"` (home-manager `nixos/common.nix`
  default). Verified identical on the integration base `f2ff948` (fresh
  worktree, original `myHost.nix`) — with fresh consumer nixpkgs
  (`9ac0edc`), the library's pinned nixpkgs (`8edc0c72`), and the
  library-locked home-manager rev (`095fef2`). The failure tracks the
  consumer's floating `home-manager` input, not this ticket's changes; the
  required consumer-evaluation gate above is green.

**Deviations from the rename-impact inventory (with reasons):**

1. `gh` (`features/gh.nix`) is home-bound but missing from the 66-aspect
   table. Moved to `dotnix.home.gh` — required, because
   `profiles/development.nix` selects it bare and that list switched to
   `with dotnix.home;`.
2. `tests/broad-compositions.nix:441` (`dmsSelected` hostIncludes) carried
   `host.desktop-shell dms` — inventory listed only :110/:132/:150.
   Converted like the others.
3. `tests/broad-compositions.nix:325` carried a fourth `dotnix.noctalia`
   (inventory listed :507/:532). Converted.
4. `tests/broad-compositions.nix:452` (`noctaliaSelected`) carried
   `host.desktop-shell` — not in the inventory's desktop-shell list.
   Converted.
5. `docs/plans/den-flake-file-assessment.md` contains `dotnix.direnv` prose;
   deliberately NOT rewritten — it documents a past evaluation, not a living
   reference (ticket scope lists features, profiles, template, tests, README).
6. Scope guards honored: `term-ux-herdr` kept (decision 7 is ticket 03+),
   `host.core`/`home.core` contents untouched (decision 5 is separate),
   `desktop-apps` bundle contents untouched (decision 4 is separate).

**Fix during green-up:** bare `home.noctalia` / `home.dms` inside `with dotnix;`
lists in `tests/broad-compositions.nix` (:442, :543, :548) collided with the
file-level `home = evaluate { ... }` let-binding (Nix lexical shadowing over
`with`), causing infinite recursion / missing attributes. Fully qualified as
`dotnix.home.*` there. No other file has shadowing bindings.

**Warning strings and comments** (`dotnix.home.herdr:` / `dotnix.home.tmux:`
trace prefixes, `gh.nix` → `dotnix.home.git` comment, profile comments) updated
to post-rename paths. Consumer-owned composites (`dotnix.myuser`,
`dotnix.dell-precision-5570`) and infrastructure (`dotnix.classes`,
`dotnix.popup-launchers`) untouched, per ADR 0001.
