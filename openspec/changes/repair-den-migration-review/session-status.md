# Session checkpoint — 2026-10-09

## Stop state

The user requested stopping all work for today and documenting the state. No further implementation, builds, commits, source/lock changes or agent launches are authorized by this checkpoint. All launched implementation/review agents have returned; some late notifications describe superseded attempts. Preserve the current dirty working trees. Resume only on a new user request.

**PARTIAL — NOT MERGE-READY.** Repair code exists, but regression fixtures, documentation, full build/runtime gates, portable source handling, final review and commits remain unfinished. Do not restart broad reconnaissance: use this checkpoint and the current diffs.

## Repositories and tracking

| Repository                            | Branch               | HEAD      | Current repair state                                           |
| ------------------------------------- | -------------------- | --------- | -------------------------------------------------------------- |
| `/home/denis/projects/dotnix-aspects` | `feat/den-migration` | `359b3b3` | 23 tracked files modified; repair OpenSpec directory untracked |
| `/home/denis/projects/dotnix`         | `feat/den-migration` | `831756f` | 6 tracked files modified                                       |

No repair commits or pushes were made. Both existing lockfiles remain unchanged. No system activation, deployment, disk formatting or live rollback occurred. Secret values must not be printed; verification inspected resource paths, secret names and gates only.

`review.md` remains the historical review of the committed migration, not the status of today's dirty files. Its original findings/LOC baselines are retained. `tasks.md` still has **0/24 checked**: implementation progress was tracked in session tasks, but acceptance and checkbox reconciliation were not completed. The older `clarify-aspect-boundaries-and-harden-workstation` change still has 18/21 checked; do not silently close or archive it.

## Implemented code and evidence

Evidence below is from returned worker/reviewer results. The coordinator inspected git status/diff and did not rerun all Nix commands. Successful evaluation is not a successful build or final regression sign-off.

### Consumer resources, activation, identity and host scope

Library files modified:

- `modules/aspects/core/age-rekey.nix`
- `modules/aspects/core/age/age.nix`
- `modules/aspects/core/certificates.nix`
- `modules/aspects/core/stylix.nix`
- `modules/aspects/core/users.nix`
- `modules/aspects/core/yubikey-pam.nix`
- `modules/aspects/desktop/shell/dms/dms.nix`
- `modules/aspects/development/vcs/git.nix`
- `modules/aspects/term/mailing/maildir/maildir.nix`
- `modules/aspects/term/secrets/rbw.nix`

Consumer files modified:

- `modules/hosts/luffy/configuration.nix`
- `modules/hosts/roger/configuration.nix`
- `modules/users/denis/default.nix`
- `modules/users/denis/repos.nix`
- Battery activation in `modules/parts.nix` (also modified by tooling work).

The supported Den `flake-scope` battery passes consumer inputs to **aspect-wrapper functions**. Resource-owning aspects now capture consumer inputs there while retaining library inputs for dependency imports. Putting `inputs` only in the inner class-module function failed in earlier attempts; do not repeat that rewrite. Oracle verified wrapper-level injection also works under native flake-parts. The earlier template `attribute 'inputs' missing` report was not reproducible after current source changes.

Host/user scope can import one external module under different Den-generated keys. Stable keyed wrappers were added for external agenix-rekey modules. Stylix external imports plus shared configuration also received per-class keyed wrappers to clear duplicate package/module behavior. Do not key an entire contextual aspect: that can discard scope-specific settings. Review the Stylix wrapper boundary independently before final sign-off.

Other changes: repository package construction moved into the Home Manager module; deleted `config.profile` reads removed; native RBW identity set by the consumer; Denis explicitly selects PipeWire for Home persistence; native hostname battery and host identity settings added.

Verified with explicit local library override:

```sh
cd /home/denis/projects/dotnix
nix eval --no-write-lock-file \
  --override-input dotnix path:/home/denis/projects/dotnix-aspects \
  '.#nixosConfigurations.luffy.config.system.build.toplevel.drvPath'
nix eval --no-write-lock-file \
  --override-input dotnix path:/home/denis/projects/dotnix-aspects \
  '.#nixosConfigurations.roger.config.system.build.toplevel.drvPath'
```

Both derivations evaluate. Targeted worker probes reported:

- Hostnames `luffy` and `roger`.
- Luffy host/user rekey resource paths belong to the consumer source.
- Populated Luffy secret names present, `users.mutableUsers = false`, intended PAM U2F enabled.
- Denis Home persistence includes `.local/state/wireplumber` and repository directories.
- `home.activation.cloneGitRepos.data` evaluates; no cloning/activation performed.
- Native Git/RBW identity evaluates; distinct mail account addresses remain distinct.
- Roger has no Home Manager user configuration, U2F disabled, and remains headless.
- Luffy groups, disk device and stateVersion preserved.

Negative/unselected/routing-disabled/multiuser assertions are **not yet added or run**. Full host builds were not attempted. No final independent review of these repairs has occurred.

### Tmux and Workmux

Modified:

- `modules/aspects/term/shell-ux/tmux/tmux-popups.nix`
- `modules/aspects/development/ai/workmux.nix`

Local default directory restored to `#{pane_current_path}`, explicit null retained for Scratch, nested quoting/multiword commands restored, K9s gate changed to `programs.k9s.enable`. Workmux agents menu now uses Prefix `w`; popup menu retains Prefix `o`, sidebar retains `a`/`A`.

Worker reported 12 focused Nix assertions passing and successful parsing through a private Tmux socket. A second private-session startup test unexpectedly showed default bindings; that runtime anomaly remains unresolved. Independent reviewer found no source issues and verified focused Nix rendering/K9s checks, but did not complete runtime/spaced-directory acceptance. Coordinator LSP probes returned no diagnostics for the two files. Coordinator could not rerun Tmux: executable was absent both directly and via the session workspace's `nix develop`.

Keep OpenSpec 3.1/3.3 acceptance open until the runtime case and retained assertions are complete. No live Tmux session was modified.

### Native tooling bridge and generation

Library modified:

- `flake.nix` (generated)
- `modules/expose.nix`
- `modules/parts/{flake-parts,devshell,pre-commit,treefmt}.nix`

Consumer modified:

- `modules/parts.nix`
- `flake.nix` (regenerated)

Both entries now use supported flake-parts `mkFlake` plus native Den integration instead of plain `evalModules`. Library activates dev parts; consumer imports `inputs.dotnix.flakeModules.devTools`. Consumer `roger-iso` moved to `perSystem.packages`, preserving its output. The manual write-flake app wrapper was removed in favor of flake-file's native integration.

Both library and consumer expose formatter, checks, default devShell, write-flake/write-inputs/write-lock packages and Agenix generate/rekey apps. Consumer also exposes `roger-iso`. **Correction:** an earlier missing-Agenix-app report used `.name`, which is not an app attribute. `.program` and app attrNames succeed; do not pursue a nonexistent missing-app bug.

Workers ran `nix run .#write-flake` twice in each repository and reported stable generated flakes and unchanged lockfiles. Consumer verification requires the local override due to its stale absolute-path lock entry.

Library `nix flake check -L` passed after template formatting repairs; reported private-key/treefmt/typos hooks passed. Consumer `nix flake check` with the local override passes check-flake-file but fails treefmt/pre-commit on this exact remaining formatting change:

```diff
--- modules/users/denis/repos.nix
-{ ... }:
+_:
```

Do not label the consumer check green until fixed and rerun.

### Pending architecture decision: input declarations in parts

The worker removed `flake-file.inputs.*` declarations from library `modules/parts/{flake-parts,devshell,pre-commit,treefmt}.nix`. Equivalent declarations remain centralized in `modules/expose.nix`. The exported devTools parts are pre-applied to **library** `inputs` and `lib`:

```nix
flake.flakeModules.devTools.imports =
  map (f: f { inherit inputs lib; }) (map import devParts);
```

Reason for the change: avoid injecting new root dependency inputs into the consumer and requiring unapproved lock edits. This is **not required by Den or flake-parts**; it is an architectural choice that removes owner-local dependency declarations/self-contained parts. The user questioned it; the coordinator acknowledged that the decision should have been discussed first and stopped further changes to this contract. **No user decision to retain or reverse this centralization has been given.** Resolve before further edits. Do not confuse this with consumer `modules/parts.nix`, which still contains `flake-file.inputs` and `flake-file.outputs`.

The library part's explicit flake-parts `modules` import was also removed; independently confirm intended exported module API rather than assuming `mkFlake` makes every opt-in module redundant.

### Public template

Modified:

- `templates/dotnix/flake.nix`
- `templates/dotnix/modules/parts.nix`
- `templates/dotnix/modules/hosts/myHost/{configuration,hardware}.nix`
- `templates/dotnix/modules/users/myUser/default.nix`

Template migrated from removed registry/module/profile APIs to native namespace/entities/aspects. User-side `core-home` now supplies Stylix Home Manager configuration; RBW/Git identity uses native placeholder settings. Unused `den` function argument removed for deadnix. The original public dummy master identity entry was restored (same nonexistent path/public dummy key as committed template); no private key or new secret file was created. Review/document this existing placeholder honestly before using the template for real hosts.

The user explicitly approved `dotnix.inputs.home-manager.follows = "home-manager"` in the template to prevent differing Home Manager revisions from declaring `home-manager.users` twice. Workers also added Den/Home Manager template inputs and `dotnix.inputs.den.follows` during migration; final review must check input-change authorization scope. Existing repository locks remain unchanged; ephemeral fixtures generated their own locks.

Fresh fixture `/tmp/fx3` generated from template:

```sh
cd /home/denis/projects/dotnix-aspects
nix flake new /tmp/fx3 -t .#default --accept-flake-config
cd /tmp/fx3
nix eval --no-write-lock-file \
  --override-input dotnix /home/denis/projects/dotnix-aspects \
  '.#nixosConfigurations.myHost.config.system.build.toplevel.drvPath'
```

Worker reported evaluation success and `nix build --dry-run` success (840 derivations planned). **A dry-run is not a build.** Full CI template build remains unrun. Do not mark OpenSpec 6.1 complete from this evidence alone.

## Remaining work and session task mapping

| Session task                  | Current factual state                                                                    | OpenSpec mapping                                |
| ----------------------------- | ---------------------------------------------------------------------------------------- | ----------------------------------------------- |
| 1 Oracle repair plan          | Complete; safe workstream ownership established                                          | Planning                                        |
| 2 Consumer behavior/resources | Code plus targeted positive evaluation done; final tests/review still required           | 1.1, 2.1, 2.2, 4.1, 4.2                         |
| 3 Tmux/Workmux                | Code/source review done; runtime anomaly and retained assertions unfinished              | 3.1, 3.2; 3.3 under task 5                      |
| 4 Library tooling/template    | Outputs/check/generation and template eval/dry-run done; full template build unfinished  | Library 5.1/5.3; 6.1                            |
| 7 Consumer tooling            | Outputs/idempotence done; consumer formatting/check red; parts contract decision pending | Consumer 5.1/5.3                                |
| 5 Fixtures/docs               | Not started                                                                              | 1.2, 1.3, 2.3, 3.3, 4.3, remaining 5.3, 6.2–6.4 |
| 6 Final integration/handoff   | Not started                                                                              | 5.2, 7.1–7.5                                    |

Prior agents hitting their turn limits were automatically marked completed in the session task list even when their results said PARTIAL. Treat actual gates above as authoritative, not automatic task completion labels. All 24 persisted OpenSpec checkboxes remain unchanged.

The portable source/lock contract is undecided. Consumer lock still contains an absolute library path with stale NAR hash; plain evaluation fails with `NAR hash mismatch`. Local override validates dirty code, not reproducibility. Do not invent a hash, update unrelated inputs, push, or claim an unpublished remote pin is usable.

## Resume order (only after user requests continuation)

1. Confirm current git status and read this checkpoint, review, design and tasks. Preserve dirty changes; no repeat of broad migration reconnaissance.
2. Resolve whether dependency declarations belong back in owner-local parts versus centralized/library-bound devTools. Get explicit authorization for any resulting input/lock changes and the portable source contract.
3. Fix consumer formatting and rerun checks. Verify the tooling contract after any architectural adjustment.
4. Migrate retained fixtures and docs with one owner: broad-compositions, headless-composition, niri-dms, headless-security, resume-order, btrfs-rollback, consumer headless/persistence tests; add positive/negative scope/resource/Tmux assertions. Keep manual suites manual.
5. Resolve Tmux runtime acceptance; run fresh full template build, host no-link build attempts, manual VM suites or record concrete external blockers. Never activate a system or touch a real disk.
6. Recompute LOC against original review baselines, run final independent GPT-6.1 Sol review, reconcile only fully accepted OpenSpec checkboxes, commit verified scoped blocks with hooks/Git LFS, no push without authorization.

Implementation model preference in the persisted change is OpenAI Luna; use that explicitly when resuming. Many short worker launches in this session repeated reconnaissance and exhausted turn limits; avoid repeating that pattern. Original Oracle diagnosis proved the wrapper-level flake-scope and keyed external-module fix; use existing evidence, then verify changed targets.

Temporary diagnostic fixtures under `/tmp` (including `/tmp/fx3`, `/tmp/dotnix-fixture*`, `/tmp/fx*`, patched source/probe files) may disappear. They are not durable tests or final artifacts. No cleanup/deletion was performed during this stop checkpoint.
