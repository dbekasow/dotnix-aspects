# Den Migration Review Handoff

> Historical review of the committed migration. For the paused, uncommitted repair work as of 2026-10-09, see [session-status.md](session-status.md). The original findings and baselines below are retained; they do not describe every current working-tree value.

## Verdict and Snapshot

**REQUEST_CHANGES — PARTIAL. Not merge-ready.** Review performed with GPT-6.1 Sol, read-only, and stopped at its turn limit. No complete build/VM sign-off. Native Den architecture exists, but functional and security regressions remain.

| Repository                            | Reviewed commit                            | Pre-migration baseline                     | Branch               |
| ------------------------------------- | ------------------------------------------ | ------------------------------------------ | -------------------- |
| `/home/denis/projects/dotnix-aspects` | `359b3b3226dc9fac856ed2e4c2c342ef0cee0336` | `58566cdfe16874ca89e05441fd8378dabc7d5dd6` | `feat/den-migration` |
| `/home/denis/projects/dotnix`         | `831756fe32505fa6471fc14f2675861f81bf5a3a` | `be3cd865d6e1c1b65bba23992b971c7a3b5f6dbf` | `feat/den-migration` |

Both trees were clean when the review finished. Commit hooks (private-key, treefmt, typos, commitizen) passed; this is not proof of working evaluation/builds. Hook formatting is included in the LOC snapshot below. Den API checked against revision `7594405b45e0ce2d5a418fe104a26e17f6b1dd8f`, available in this session at `/nix/store/qi4m5i7fpxr176wyafyy739lw73a96pd-source` (resolve pinned source again if unavailable).

These are snapshot findings, not assertions that later HEADs still contain each defect. Revalidate changed locations before repairs.

## Findings

Paths prefixed `library:` are relative to dotnix-aspects; `consumer:` paths are relative to dotnix.

### F01 — BLOCKER: Exported aspects resolve consumer resources from library self

**Locations:** `library:modules/aspects/core/age-rekey.nix:16,32`; `core/users.nix:5`; `core/yubikey-pam.nix:5`; `core/stylix.nix:59`. Same cause affects Age, certificates, and DMS-U2F.

Class modules close over outer `inputs.self`. In a namespace-exported aspect this is the library source, not the consumer source. Existing consumer host public keys/vault resources are therefore ignored. Evaluated Luffy values were `age.secrets = {}`, `users.mutableUsers = true`, `hashedPasswordFile = null`, and `security.pam.u2f.enable = false`. Secret paths point into the library; wallpaper/certificate lookup has the same wrong ownership.

**Smallest fix:** Set consumer resources through consumer host/user aspects and native options, or explicitly supported Den data context where genuinely needed. Retain library dependency inputs; do not restore `wrapMods` or a custom option namespace. Validate populated and intentionally empty vault cases without exposing secret values.

### F02 — BLOCKER: Repository activation requests pkgs on outer Den level

**Locations:** `consumer:modules/users/denis/repos.nix:1,8,20`.

Outer Den module requests `pkgs` and creates `cloneRepo`; outer `evalModules` does not provide `pkgs`. Luffy `system.build.toplevel.drvPath` evaluation fails with `error: attribute 'pkgs' missing` while evaluating `home.activation.cloneGitRepos.data`.

**Smallest fix:** Move `{ lib, pkgs, ... }` and `cloneRepo` into the inner `dotnix.denis-repos.homeManager` module. Preserve existing activation behavior and repository persistence.

### F03 — BLOCKER: Consumers still require deleted profile identity options

**Locations:** `library:modules/aspects/term/secrets/rbw.nix:7`; `term/mailing/maildir/maildir.nix:28–29`; Git also retains optional profile lookups.

`users-profile.nix` was deleted but RBW reads `config.profile.email`, and Maildir/Notmuch reads profile email/fullname. Luffy selects `terminal` → `term-secrets` → RBW, so this is reachable.

**Smallest fix:** Use native Git/mail/RBW settings and consumer identity values; remove remaining `config.profile` consumers without introducing a replacement profile schema. Do not collapse distinct mail-account addresses into a single Git email.

### F04 — BLOCKER: Tmux popup rendering lost required directory default and quoting

**Location:** `library:modules/aspects/term/shell-ux/tmux/tmux-popups.nix:6–23`.

Most candidates omit `directory`, but `popupCmd` reads it unconditionally. Deleted submodule previously supplied `#{pane_current_path}`. Always-enabled entries (Shell/Nix Graph) make this fail when Tmux is enabled. Multiword popup commands also require correct quoting.

**Smallest fix:** Apply a local default (`p.directory or "#{pane_current_path}"`) while retaining explicit `null` for Scratch. Restore command/directory quoting; `dua i` must remain one popup command. No new configuration framework.

### F05 — BLOCKER: Selected PipeWire persistence does not reach Denis

**Locations:** `consumer:modules/hosts/luffy/configuration.nix:43,70–78`; `library:modules/aspects/system/pipewire/pipewire.nix:42–43`; `system/impermanence.nix:12–18`.

PipeWire is selected only in host scope. Its `homePersistence` contribution is routed in user scope, where the feature was not selected. Evaluated Denis directories omit `.local/state/wireplumber`, losing device/routing state after a Home wipe.

**Smallest fix:** Deliver only the relevant PipeWire home contribution to Denis or select its user-side aspect explicitly. Do not inherit all host features into every Home.

### F06 — BLOCKER: Public template still uses removed registry contract

**Locations:** `library:templates/dotnix/modules/parts.nix:3`; `modules/hosts/myHost/configuration.nix:3`; `modules/users/myUser/default.nix:2`.

Template parts request `inputs.den`, but template flake does not declare it. Host retains `dotnix.hosts`; user retains `self.modules` and old module registration. Template evaluation fails with `error: attribute 'den' missing`; further removed-contract failures remain behind it.

**Smallest fix:** Migrate the complete template to native entry, entities, namespace and user aspects. Do not restore aliases to make the old template pass. Preserve legitimate hardware/storage placeholders and never use a live disk for fixture execution.

### F07 — MAJOR: Both hostnames fall back to nixos

**Locations:** `consumer:modules/hosts/luffy/configuration.nix:11–12`; `modules/hosts/roger/configuration.nix:2–3`.

Old builder assigned `networking.hostName`; entities alone do not do so with current activation. Both evaluate to `nixos`.

**Smallest fix:** Explicitly activate pinned `den.batteries.hostname` through appropriate includes (documented `den.default.includes`) or preserve names through native host configuration. Confirm Luffy=`luffy`, Roger=`roger` and no unrelated user changes.

### F08 — MAJOR: Workmux overwrites Tmux popup menu

**Locations:** `library:modules/aspects/development/ai/workmux.nix:34`; `term/shell-ux/tmux/tmux-popups.nix:32`.

Both bind Prefix-Key `o`; Luffy selects development and terminal. Once popup rendering is repaired, one menu displaces the other. K9s popup additionally gates on `programs.kubernetes.enable`, not `programs.k9s.enable`.

**Smallest fix:** Integrate Workmux into the native menu or select a collision-free key; repair the K9s gate and verify the final combined config.

### F09 — MAJOR: DevTools exported but existing outputs are not activated

**Locations:** `library:flake.nix:11`; `consumer:modules/parts.nix:2`; `library:README.md:33`.

Library entry does not activate dev parts. Consumer imports namespace only. `flakeModules.devTools` remains an ordinary flake-parts module with no active supported bridge. Library outputs lack `checks`, `formatter`, and `devShells`; consumer loses former tooling/Agenix integration. CI commentary about Treefmt checks is inaccurate.

**Smallest fix:** Activate supported native integration and restore intended formatter/check/devshell/rekey/generate outputs. Do not recreate `options.flake`, custom output wrapping, or the host factory.

### F10 — MAJOR: Retained tests reference removed APIs

**Locations:** `library:tests/broad-compositions.nix:30–31`; `tests/niri-dms.nix:51`; `tests/headless-composition.nix:26`; `tests/headless-security/flake.nix:39–41`; `tests/resume-order/vm.nix:51`; `tests/btrfs-rollback/vm.nix:7`.

Suites use removed `nixosModules`, `homeManagerModules`, `source.modules`, `flakeModule`, and `dotnix.hosts`. Broad test fails with `attribute 'nixosModules' missing` before its newly added persistence assertions run.

**Smallest fix:** Rewrite retained fixtures using native Den composition; retain meaningful assertions and evaluate actual persistence records. Tests remain manual; do not add thin suites or new CI/check wiring.

### A01 — Follow-up: Consumer source/lock is not portable

Review found an absolute local Dotnix path and stale content hash in the consumer lock. Local override checks hide this issue. Establish a final portable source/pin contract after verifying the library; publication or push requires separate authorization. Do not invent hashes or point a final consumer at an unpublished remote commit and claim reproducibility.

### A02 — Follow-up: Documentation and generation claims need verification

README still contains a removed `dotnix.hosts` example around line 87. Replace remaining legacy examples and independently verify generator idempotence and pin preservation after restoring outputs.

## Den Assessment Matrix

Scale: 0 = absent/unusable; 3 = substantially implemented with material gaps; 5 = cleanly implemented and suitably verified. Absence of unnecessary abstractions is a positive result.

| Dimension                                 | Score | Evidence / next smallest step                                                                                                    |
| ----------------------------------------- | ----- | -------------------------------------------------------------------------------------------------------------------------------- |
| Native entities / outputs                 | 4/5   | Direct evalModules; both hosts exported, Roger derivation evaluates. Repair outer pkgs and evaluate Luffy.                       |
| Aspect composition / flexible profiles    | 4/5   | Short native includes; no mandatory tier hierarchy. Repair actual feature combination regressions.                               |
| Policies / activation / targeting         | 3/5   | Explicit Core→Home and persistence policies. Route missing PipeWire contribution and check negative multiuser scope.             |
| Classes / persistence                     | 3/5   | Namespace classes and colocated contributions appropriate. Missing WirePlumber state; retained assertions currently cannot run.  |
| Quirks / pipes appropriately omitted      | 5/5   | No necessary additional pipeline established. Do not add abstractions merely for coverage.                                       |
| Host / user / HM scope                    | 3/5   | Denis only on Luffy; Roger without HM. Repair resource ownership and host identity.                                              |
| Native namespace / no bespoke substrate   | 3/5   | Builder/wrapper gone; native export works. Profile consumers and legacy template/test contracts remain.                          |
| Decentralized inputs / pins / idempotence | 3/5   | Dependency pins retained and owner-local declarations present. Repair portable consumer lock; verify generation.                 |
| Function / security / boot / secrets      | 2/5   | Disk, groups, stateVersion and rollback broadly preserved. Vault/U2F/resource behavior and Home-state regressions remain.        |
| Fixtures / tests / checks / docs          | 1/5   | Broken retained suites/template, absent tooling gates, obsolete examples. Restore existing checks without adding new frameworks. |

## LOC Baseline and End State

Physical lines of all tracked `.nix` files, measured from the reviewed commits after hooks. Both repositories counted; no untracked files existed then. Deleted files count as zero at end state. Generated root flakes included unless explicitly excluded.

| Area                                       | Before | Reviewed |         Delta |
| ------------------------------------------ | -----: | -------: | ------------: |
| Library Nix                                |   5836 |     5794 |   -42 (-0.7%) |
| Consumer Nix                               |    210 |      327 | +117 (+55.7%) |
| Combined Nix                               |   6046 |     6121 |   +75 (+1.2%) |
| Combined excluding root flake.nix          |   5936 |     5962 |   +26 (+0.4%) |
| Library profile files                      |    322 |      196 | -126 (-39.1%) |
| Library flake infrastructure               |    373 |      331 |  -42 (-11.3%) |
| Library feature files (excluding profiles) |   4218 |     4332 |  +114 (+2.7%) |
| Library Nix tests                          |    830 |      841 |           +11 |
| Consumer flake infrastructure              |     28 |       93 |           +65 |

Approximate lines excluding blank and pure `#` comments: library 4671→4812; consumer 188→310; combined 4859→5122, +263 (+5.4%). This is not parser-based SLOC: block comments and multiline strings are not classified.

Real simplification: removed 95-line host builder, wrapping, legacy export surfaces and profile schema. Profile reduction is substantial. Herdr/Yazi growth was mostly formatter expansion, not new abstractions. Impermanence growth is justified by the feature-selective routing contract, but routing must be finished. Tmux reduction cannot all be claimed as a gain: defaults, quoting and menu integration were lost. Explicit consumer feature choices increase LOC and visibility but duplicate part of Core's list; duplication alone is not a blocker. Compare repaired results against this same baseline, not against the already-migrated commit only.

## Verification Evidence and Limits

Consumer probes used `--no-write-lock-file --override-input dotnix path:/home/denis/projects/dotnix-aspects`.

- Host output names: **PASS**, `["luffy", "roger"]`.
- Roger `system.build.toplevel.drvPath`: **PASS**, derivation constructed; not built.
- Luffy `system.build.toplevel.drvPath`: **FAIL**, `attribute 'pkgs' missing`.
- Luffy targeted native values: Denis only HM Home; groups wheel/networkmanager/docker; disk `/dev/nvme0n1`; system stateVersion `26.11`.
- Luffy targeted resource/security values: secrets empty; password file null; mutable users enabled; U2F disabled; resource paths point to library.
- Denis persistence directory list: evaluates, but `.local/state/wireplumber` absent.
- Roger: no HM integration; hostname `nixos`. Luffy hostname also `nixos`.
- Library namespace/classes: evaluates, `homePersistence` and `systemPersistence`; native `devTools` export; no checks/formatter/devShells.
- `nix eval --impure --no-write-lock-file --json --file tests/broad-compositions.nix`: **FAIL**, `attribute 'nixosModules' missing`.
- Template with local override: **FAIL**, `attribute 'den' missing`; override of absent root Den input rejected.
- Complete serialization of persistence hit removed `allowOther`; no separate finding inferred from serializing removed option fields.
- Prior worker's `method` failure was not independently reproduced in this review; do not present it as a confirmed current defect.
- Full Luffy build, native tooling bridge, multiuser/standalone scope, generator idempotence and retained VM suites: **not verified**.

No switch, Disko execution, filesystem formatting, deployment, or push performed. Review did not edit source.

## Next Session Constraints

- Implementation workers: OpenAI Luna (`gpt-6-luna`) only, per latest user preference. Independent review model: GPT-6.1 Sol when requested.
- Read den-nix skill and verify pinned APIs; no unrelated dependency upgrades.
- Keep whole-option mkDefault in Noctalia/DMS settings, colocated persistence contributions, native Class separation, and manual test policy.
- Preserve secrets, boot/storage/rollback ordering, hardware, legitimate stateVersion values and permissions. Do not activate systems without explicit request.
- `/home/denis/projects/agents/flake.lock` was unintentionally changed by an earlier worker and reported read-only; outside this review/change. Do not silently mutate or bypass its protections.
- All code changes are already committed on feature branches; no push authorized. This planning handoff is a new uncommitted change unless committed separately on request.

## Repair review addendum — 2026-10-11

The verdict and line references above describe the **historical reviewed commits**, not the repaired tree. One independent GPT-6.1 Sol review examined the cumulative library and consumer changes after the repair and returned **REQUEST_CHANGES** for a stale consumer `dotnix` lock snapshot; it found no other confirmed blocker. Its reproduction is specific: without an override, Luffy's Home Manager packages contained Workmux and Tuicr but not Pi, although Workmux configures `agent = "pi"`; with the current local library override all three were present. This was an integration defect, not a reason to invent a portable remote pin.

| Historical finding | Repair evidence and remaining limit                                                                                                                                                                                                                                                           |
| ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| F01                | Consumer-owned flake-scope resources and populated/empty manual fixture assertions restore Age/Rekey, password-file and U2F references; no vault decryption or recipient match was attempted.                                                                                                 |
| F02                | Denis' repository scripts are constructed inside Home Manager; activation data and both persistence directories evaluate, without activation or cloning.                                                                                                                                      |
| F03                | Git, RBW and Maildir use native identities; the retained fixture checks distinct account addresses and no live module reads `config.profile`.                                                                                                                                                 |
| F04, F08           | Private-socket Tmux parsing/callback checks cover popup directory default, explicit Scratch null, spaced cwd and `dua i`; Luffy's popup `o` and Workmux `w` coexist, K9s follows its own enable flag. The shared launcher Quirk carries data only; backend-specific bindings remain separate. |
| F05                | WirePlumber Home persistence reaches Denis through selected user scope; disabled-policy and unrelated-user cases in the retained fixture remain negative.                                                                                                                                     |
| F06                | A fresh native template built its myHost system toplevel without activation; after the graphical-shell routing change, a fresh lockless template also evaluates host DMS/greeter and user DMS/spotlight bindings.                                                                             |
| F07                | Luffy and Roger hostnames, existing Luffy groups/disk and state versions evaluate as intended.                                                                                                                                                                                                |
| F09                | Native DevTools outputs and generate/rekey apps evaluate; two write-flake runs in each repository produce no root/lock diff. Both formatter and flake checks pass.                                                                                                                            |
| F10                | Retained Broad (28 true), Headless, Niri (33 true), and three disposable VM checks pass through native Den; manual suites remain manual.                                                                                                                                                      |

**New finding R01 — lock snapshot (repaired for the chosen local source, subject to final pin refresh):** `/home/denis/projects/dotnix/flake.lock:388-390` originally selected an older library snapshot. The consumer's root `flake-file`, Home Manager, nixos-hardware, and nixpkgs pins also drifted during an earlier unguarded lock evaluation. The repaired, Nix-generated lock preserves all four original root revisions and the old Home Manager child pin; the single new `dotnix.inputs.flake-file.follows = "flake-file"` prevents duplicate module declarations. Only the authorized local library and three DevTools root inputs account for the remaining dependency changes. At consumer commit `787b659`, default-input Luffy evaluates `pi = true`, `workmux = true`, `tuicr = true`; both repositories pass formatter and flake checks, and default-input no-link Luffy and Roger builds complete. Two `nix run .#write-flake` regenerations leave the consumer root flake and lock unchanged.

**Final local lock gate:** `path:` includes the entire library tree and Git metadata. After committing this addendum, refresh the consumer's `dotnix` locked hash/time, audit the semantic dependency graph against the original consumer lock, and rerun the no-override Pi/Workmux/Tuicr and flake checks before calling R01 closed. Do not silently upgrade the four preserved root pins or replace the old Home Manager child with a second copy. The absolute path remains the user's explicitly chosen nonportable local contract: A01/Repair 5.2 is not resolved or reproducible on another machine. A02's documentation and generation checks are covered by the repaired docs and tooling gates.

Review limits: no host switch, live rollback, disk operation, secret decryption, owner-side age recipient/decryptability check, or hardware test. Evaluated derivations and no-link Luffy/Roger builds are not activation proof. The initial independent Sol review stopped at its turn limit after reporting R01; its later correction must be checked separately rather than attributed to that review. Whole-Home-Manager JSON serialization of an unassigned `accounts.calendar.basePath` was not treated as a build failure: targeted Luffy HM settings and activation evaluate. The owner-only identity boundary remains open without weakening any source gate.
