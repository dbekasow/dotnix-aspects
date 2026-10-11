# Tasks

Implementation resumed at the user's request; see [session-resume.md](session-resume.md) for current authorization and verification. [session-status.md](session-status.md) preserves the historical pause on 2026-10-09. Read `review.md` first; findings describe the reviewed commits, not future HEADs. The user authorized targeted edits/checks in both repositories and required consumer input/lock changes; unrelated dependency updates remain out of scope. Use OpenAI Luna workers for implementation; keep manual suites manual and request one independent review after repairs are complete.

## 1. Consumer resource ownership and security (F01)

- [x] 1.1 Replace consumer-resource lookup through library `inputs.self` in Age/Rekey, Users, U2F, Stylix, certificates and DMS-U2F with native consumer-owned configuration or a supported explicit context; verify evaluated paths resolve to actual consumer host/user resources and no secret values are printed.
- [x] 1.2 Add or adapt existing composition assertions for populated and intentionally empty vault/resource cases; verify populated Luffy resources do not silently produce empty secrets, null password-file references or disabled intended U2F, while empty fixtures preserve their intentional gate behavior.
- [x] 1.3 Document the resource ownership contract beside existing secret/template documentation; verify examples reference consumer files and require no wrapper or new custom `dotnix` option schema.

## 2. Class-module argument and identity repairs (F02, F03)

- [x] 2.1 Move repository package/script construction into Denis' inner Home Manager module accepting `pkgs`; verify `home.activation.cloneGitRepos.data` evaluates and preserves intended repositories and persistence without performing activation or network cloning.
- [x] 2.2 Remove mandatory and optional `config.profile` consumers from RBW, Maildir/Notmuch and Git; configure identity through native consumer options, verify those settings evaluate and distinct mail-account addresses remain distinct.
- [x] 2.3 Adapt existing relevant composition coverage and identity examples; verify no deleted profile-option contract remains in live modules/examples and Luffy evaluation advances past both repaired failures.

## 3. Native Tmux behavior (F04, F08)

- [x] 3.1 Restore local default popup directory while preserving explicit null for Scratch and correct nested quoting; verify rendered commands for Shell, Scratch, a spaced working directory and multiword `dua i` parse correctly using available Tmux tooling without modifying a live session.
- [x] 3.2 Integrate Workmux without duplicate Prefix-Key `o` and correct the K9s enable gate; verify combined development/terminal `extraConfig` preserves accessible menus and K9s popup follows `programs.k9s.enable`.
- [x] 3.3 Add minimal regression assertions to retained composition coverage and update any affected key documentation; verify the combined configuration evaluates without a replacement popup options framework.

## 4. Scope-specific state and host identity (F05, F07)

- [x] 4.1 Route selected PipeWire's Home persistence contribution to Denis without importing the entire host aspect tree; verify `.local/state/wireplumber` is present, unselected optional contributions remain absent and Roger acquires no HM/desktop configuration.
- [x] 4.2 Activate the native hostname mechanism or equivalent native host settings; verify `networking.hostName` evaluates to `luffy` and `roger` respectively with existing groups, disk device and stateVersion unchanged.
- [x] 4.3 Adapt retained persistence assertions for routing-disabled and unrelated-user/host scenarios; verify host/user Class separation and document the targeted contribution contract beside existing composition guidance.

## 5. Native tooling and portable inputs (F09, A01, A02)

- [x] 5.1 Activate the supported native tooling bridge for existing formatter/check/devshell and intended Agenix apps in library/consumer; verify expected output attributes and commands exist without restoring custom `options.flake` or export wrappers.
- [ ] 5.2 Replace stale absolute local library locking with the authorized portable source contract; verify unrelated dependency revisions/hashes/follows stay unchanged, local overrides remain explicit test machinery and no unpublished remote source is claimed reproducible.
- [x] 5.3 Verify write-flake regeneration is idempotent in both repositories and align tooling/entry-point documentation; verify a second generation produces no diff and documented formatter/check commands run against the restored outputs.

## 6. Template and retained manual suites (F06, F10)

- [x] 6.1 Migrate the entire public template flake, host and user modules to the native Den entry/namespace/entity contract; verify the existing CI consumer fixture evaluates and builds its myHost target with the local library without activating a system or touching a real disk.
- [x] 6.2 Migrate broad-compositions, headless-composition and niri-dms fixtures away from removed aliases/registry; verify existing assertions, including selected/unselected/routing-disabled persistence cases, execute through the native Den model.
- [x] 6.3 Migrate retained headless-security, resume-order and btrfs-rollback VM fixtures to native composition; run their existing disposable-resource checks and record commands/results or concrete environmental blockers, with no live rollback or storage operation.
- [x] 6.4 Replace remaining obsolete README/template/diagnostic examples including `dotnix.hosts`; verify examples match executable fixture entry points and tests remain manual with no restored legacy compatibility surface.

## 7. Final integration and handoff

- [x] 7.1 Evaluate Luffy and Roger toplevel derivation paths and targeted security/Home routing values with explicit local library override; then attempt both no-link builds, recording exact successes and any external blockers separately from code defects.
- [x] 7.2 Run existing formatters, flake checks and consumer fixture gate for both repos as applicable; verify formatting is stable and no unrelated files, boot/storage configuration or secret values changed.
- [x] 7.3 Recompute physical Nix LOC and generated-root-flake exclusion against the original review baselines; deliver before/after table and explain meaningful complexity changes rather than counting lost behavior as simplification.
- [x] 7.4 Commit coherent verified repair blocks with active hooks and Git LFS available; preserve unrelated index/worktree changes, record commit hashes and do not push without authorization.
- [x] 7.5 Request independent GPT-6.1 Sol review after all repairs, update `review.md` with resolved finding IDs and verification limits, and verify no confirmed blocker remains before declaring the migration merge-ready.

## 8. Post-review Den composition and tool integration (user-approved follow-up)

- [x] 8.1 Route the selected graphical shell explicitly to the template's Home Manager user, not implicitly from host scope; fix the template's agenix edit command and host-key destination. Verify evaluated host and user shell settings without activating or writing keys.
- [x] 8.2 Make Herdr, Workmux and Tuicr packages available to standalone Home Manager selections without a host-only overlay; supply the default Pi executable when Workmux selects it. Verify isolated selection and actual consumer composition using bounded evaluations.
- [x] 8.3 Preserve Herdr popup bindings and shell defaults when one setting is overridden; move the Bottom popup off Herdr's built-in sidebar key. Verify both against pinned Herdr 0.9.3 behavior and an evaluated partial settings override.
- [x] 8.4 Keep named Den composition aspects and independent native Git/RBW/mail identities, with personal terminal and graphical-shell selection explicit in the consumer. Keep Workmux on a supported backend, never imply Herdr support. Share only enabled launcher descriptions through a narrowly scoped Den Quirk consumed by Tmux and Herdr; keep backend-specific keys, cwd, enable and package checks. Verify selecting either terminal alone and together with development.
- [x] 8.5 Guard optional Roger architecture before checking its host attribute; verify no-host and real-host evaluations, update the integration evidence and request a final consolidated review. Boundary hardware/identity tests are excluded by user request; do not claim them run or weaken narrow regression/format/flake gates.

The consumer's local absolute `dotnix` input remains intentional by explicit user choice. Keep 5.2 open as a documented portability limitation; do not substitute a guessed remote revision. Owner-side recipient/decryptability checks and separate boundary tests are excluded from this pass, not marked complete.
