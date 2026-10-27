# 10: Use the popup catalog with both backends

**What to build:** Make the popup launcher usable with one authoritative library-owned data source and explicit backend selection. Tmux and Herdr renderers use the same launcher data without taking Zellij/Sesh capabilities from their owners.

**Blocked by:** [02: Reorganize feature ownership and discovery around the confirmed criterion](02-feature-ownership-discovery.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] Launcher records define the command, size, and required backend keys once; Tmux and Herdr renderers translate this source instead of maintaining parallel complete required mappings.
- [x] Programs enabled through native Home Manager options remain discoverable, even when no same-named Aspect is selected.
- [x] If a backend key is missing, the renderer omits the candidate and provides an actionable diagnostic; do not perform an unchecked lookup or force a feature.
- [x] Preserve existing scratch, directory, and menu behavior and ordinary native overrides.
- [x] Zellij and Sesh retain their existing ownership; backend selection does not require Fish selection when absolute program files are available.

## Integration evidence

Reviewed branch `impl/den-redesign-10-popup-backends` (tip `496cf58d60032a2702fb6b42d437b4789caac473`), merged as `08f3af7ffadb428d13cf69e5a231c83707bc2afb` with `git merge --no-ff`. The diff from the previous integration tip `7dad29ac8e9feb59e7f013ed513eab4b53b5a42a` touched only `features/popup-launchers.nix`, `features/tmux/tmux-popups.nix`, `features/herdr.nix`, `tests/broad-compositions.nix` and this ticket.

Independent reviewer verdict: APPROVE, no issues found. All 14 launcher records were compared against both old renderer maps and each keeps both original bindings, together with preserved commands, dimensions, enable predicates, scratch/directory/menu behaviour and the duplicate-key assertion. Native Home Manager discovery is intact, adapter registration stays inert, and no aliases, shims, priorities or frameworks were introduced.

Verification run in the integration worktree:

- `nix eval --impure --json --file tests/broad-compositions.nix` — exit 0, 41 assertions, all true, including `popupQuirkEnabledForBothBackends`, `popupMissingBackendBindingIsOmitted`, `popupQuirkExcludesDisabledLauncher`, `popupMenuCoexistsWithWorkmux`, `popupTmuxWorksWithoutWorkmux` and `popupQuirkDoesNotLeakToUnrelatedUser`.
- `nix eval --impure --file tests/headless-composition.nix` — exit 0, `"headless and workstation composition checks passed"`.
- `nix flake check --no-build --no-write-lock-file` — exit 0, `all checks passed!` (incompatible-system notice only).
- `typos --force-exclude --format brief --hidden .` — exit 0.
- `nix fmt -- --ci` — exit 0, `0 changed`; `git status --porcelain` empty.
- `git diff 7dad29a..HEAD -- flake.nix flake.lock` empty; `sha256sum flake.lock` is `6f9c06db3f8a4211e10a99998c20c27c3307d8a4eedd9a69d3fed9b0af2f0e47`, equal to `source-lock.sha256`.

Caveat: this is evaluation-only evidence. No build, activation or runtime proof was produced for this ticket, and the original-checkout digest guard was not run here.
