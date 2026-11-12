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
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); ticket publication is
approved, implementation requires separate approval.

## Acceptance criteria

- [x] `host.core` contains exactly the universal baseline; `home.core`
      contains exactly home.age, home.age-rekey, home.ssh; both remain
      role-pure and override nothing.
- [x] `home.development` includes git and git-alias and no longer includes
      kubernetes; `dotnix.home.kubernetes` remains individually selectable;
      `graphical` includes stylix on both roles; gnupg/gpg-agent are
      selectable without core.
- [x] `home.office` and `home.browsers` exist and compose for a
      non-developer occupant without terminal or development content.
- [x] `home.desktop-apps` contains only alacritty, ghostty, handy, anki.
- [x] `host.server` includes base, ssh, security and nothing speculative.
- [x] A representative family-occupant composition (graphical, office,
      browsers, one shell) evaluates without developer content leaking in.
- [x] Gates pass: `nix fmt`, `nix flake check --no-build --no-write-lock-file`,
      updated composition tests, template consumer evaluation.

## Comments

### Implementation (2026-11-12, worktree t02, branch impl/pnr-02-core-baseline)

**Commits:** `6b74c6f` (claim), `e2b076d` (implementation, 13 files).

**TDD:** assertions written and confirmed red before the profile changes.

- Red A (`tests/broad-compositions.nix`, profiles untouched):
  `error: Broad composition fixture failed: developmentOwnsGitAndDropsKubernetes, dmsShellAndGreeterExplicitlySelected, homeCoreIsTheUniversalBaseline, homeDesktopProfileIsRolePure, hostCoreIsTheUniversalBaseline, noctaliaNiriContextHasBinds, socketDoesNotSelectShellOrGreeter`.
- Red (`tests/headless-composition.nix`): `error: assertion '(server).services.openssh.enable' failed`, exit 1.
- Red B (after adding the family-occupant fixture and `home.browsers` selections):
  `error: attribute 'browsers' missing` — the new bundles did not exist yet.
- Green after the profile changes; no assertion was weakened to get there.

**Gates (exact commands, exit status):**

- `nix fmt` → exit 0; re-run reports no changes (idempotent).
- `nix flake check --no-build --no-write-lock-file` → exit 0, all checks passed
  (after `git add profiles/browsers.nix profiles/office.nix`; untracked files are
  invisible to the flake).
- `nix eval --impure --json --file tests/broad-compositions.nix` → exit 0,
  98/98 assertions true (was 94/94 on the ticket-01 base; +4 new checks:
  hostCoreIsTheUniversalBaseline, homeCoreIsTheUniversalBaseline,
  developmentOwnsGitAndDropsKubernetes, familyOccupantComposesWithoutDeveloperContent).
- `nix eval --impure --file tests/headless-composition.nix` → exit 0,
  `"headless and workstation composition checks passed"` (+8 server asserts:
  openssh/polkit/sudo-rs enabled, includes length 3, no fish/stylix/age).
- `nix eval --impure --json --file tests/niri-dms.nix` → exit 0, 48/48 true
  (unchanged count; home.stylix arriving via home.graphical breaks nothing).
- `typos` → exit 0, no findings.
- `bash tests/consumer-generation.sh /tmp/pnr02-consumer-gen` → exit 0,
  `Consumer generation lifecycle passed`.
- Full template NixOS build not attempted — pre-existing failure on the base,
  documented in ticket 01 (homeDirectory conflict via the consumer's floating
  home-manager input); the required consumer-evaluation gate above is green.

**Bundle shapes implemented:** `host.core` = age, certificates, home-manager,
locale, nix, security, ssh, system-packages; `home.core` = age, age-rekey,
ssh; `home.development` += git, git-alias, − kubernetes;
`host.graphical`/`home.graphical` += stylix; `home.desktop-apps` = alacritty,
anki, ghostty, handy; new `home.office` = onlyoffice, thunderbird,
`home.browsers` = firefox; `host.server` = base, ssh, security.

**Interpretation decisions (spec leaves these host-side leavers without a
named destination):**

1. Profiles stay role-pure (GLOSSARY: a profile is "for one selection scope").
   No host aspect was added to a home profile. `host.git`, `host.fish`,
   `host.age-rekey`, and `host.nh` leave `host.core` and become individually
   selectable, like `host.nur` and `host.gnupg`. "Fish to the shells area" is
   read as domain classification: `home.shells` already owns `home.fish`;
   host-side fish enablement is an explicit host selection. "Git and
   git-alias to home.development" moves the home aspects; `host.git` stays an
   explicit selection (mirrored by `hostGitRemainsExplicitlySelectable`).
2. Template: `host.age-rekey` added to the host includes — the template's
   own `age.rekey` resource block requires the agenix-rekey options that
   `host.core` no longer imports. `host.fish`, `host.git`, `host.nh`,
   `host.nur`, `host.gnupg` are NOT re-added: that slimming is the documented
   behavior change, and re-selecting them is consumer-owned occupant
   composition (ADR 0002). The consumer-generation fixture does not exercise
   the template's own host module (it replaces configuration.nix), consistent
   with ticket 01.

**Test-reference updates for changed bundle contents:** `coreOnly` fixture
loses its `age.rekey.localStorageDir` host module (core no longer wires
rekey); `workstation` fixture re-selects `host.fish` and adds `home.browsers`
(author occupant); `home` fixture adds `home.browsers` (keeps the `.mozilla`
persistence assertion meaningful); `workstationHasCoreSystemDesktopDevelopment`
flips its home-stylix conjunct positive (the user now gets stylix via
home.desktop → home.graphical by design); `socketDoesNotSelectShellOrGreeter`,
`dmsShellAndGreeterExplicitlySelected`, and `noctaliaNiriContextHasBinds` flip
their host/home stylix conjuncts positive (graphical includes stylix) while
keeping host-does-not-leak-into-home negatives; `homeDesktopProfileIsRolePure`
asserts the new desktop-apps contents (alacritty, ghostty, anki, handy present;
firefox, onlyoffice, thunderbird absent).

**Testing lesson:** `!(config.programs ? foo)` is not a valid negative in this
harness — every Home-Manager-declared option exists for every user (declaring
is not activating). Negatives use the file-wide `.enable or false` convention.

**Open items:** none for this ticket. Ticket 03 (excludes semantics,
terminal-herdr) remains; `features/home-manager.nix` still carries a stale
comment referencing a former `aspects/core.nix` sharedModules coupling that no
longer exists anywhere — pre-existing, feature bodies are out of scope here.
