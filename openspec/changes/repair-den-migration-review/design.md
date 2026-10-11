# Design

## Context

See `proposal.md` for motivation and `review.md` for evidence, source locations, matrix, and LOC. The two committed migrations use native Den namespaces and generated flake-file entry points, but do not preserve every consumer contract. The inspected repository activation still requests outer `pkgs`; Age/Rekey still closes over library `inputs.self`; RBW still consumes removed `config.profile`; Tmux candidates still omit a required `directory` field.

No implementation is authorized by this persistence request. This change is a next-session repair plan; existing source commits remain unchanged.

## Goals / Non-Goals

**Goals:**

- Restore intended consumer behavior using native options and explicit Den scope/routing.
- Keep the new feature-selective persistence contract and native namespace exports.
- Produce reproducible evidence with retained fixtures, both hosts, and the existing toolchain.

**Non-Goals:**

- Reintroducing custom `dotnix` option schemas, the host builder, legacy module aliases, or input-wrapping adapters.
- Building a generic policy/capability engine or adding quirks/pipes merely for coverage.
- Reorganizing feature directories, changing unrelated pins, adding privileges, live activation, or pushing commits.
- Turning manually run suites into flake checks or reintroducing deleted thin tests.

## Decisions

### Consumer resources remain consumer-owned

Library inputs identify dependency flakes; they are not the caller's source tree. Configure actual resource paths and secret-manager references in consumer host/user modules and let library features read native options where available. An explicitly supported Den data binding is acceptable only if multiple features truly require it. Do not recover the old behavior with `wrapMods` or a renamed option namespace. Keep absence-of-vault behavior for genuinely empty fixtures without silently treating existing consumer vaults as absent.

### Module arguments stay on the module-system level that provides them

Create the repository-cloning package inside the Home Manager class function with `{ lib, pkgs, ... }`. Replace remaining identity consumers with native settings; person-specific addresses belong to the consumer. Preserve clone behavior and persistence while repairing scope.

### Persistence routes follow the selected feature and intended destination

Keep `homePersistence` and `systemPersistence` namespace classes. Restore WirePlumber state through a targeted user-side contribution or explicit consumer selection, not inheritance of the entire host aspect tree. Do not change rollback code, storage layout, persistence root, ownership, or access controls as collateral fixes.

### Tmux uses native configuration with preserved defaults and quoting

Normalize the removed popup directory default locally (`#{pane_current_path}`), retaining explicit `null` for Scratch. Quote nested menu commands/directories correctly; retain multiword commands. Integrate Workmux without conflicting Prefix-Key bindings and use the native K9s enable option. No replacement popup-options framework.

### Native output integration must include existing development tools

Keep direct Den evaluation and `denful.dotnix`. Activate the supported Den/flake-parts bridge for tooling rather than recreating a `flake` option system. Templates and retained fixtures must use the same native contract. A local override is verification machinery, not the final portable consumer lock.

## Risks / Trade-offs

- Secret-related checks can leak data → inspect evaluated gates and path references, never print or copy secret values into artifacts.
- Security gates can look valid when files are missing → exercise both actual consumer resources and intentionally empty fixtures.
- Local overrides can hide broken source pins → distinguish local verification from the final portable source/lock contract; no push without authorization.
- Narrow evaluation misses lazy failures → evaluate final Luffy and Roger toplevel derivations before attempting builds.
- LOC decreases can conceal removed behavior → fix regressions first; retain before/after physical LOC and generated-file separation.
- Commit hooks can lose unstaged consumer work without Git LFS → ensure `git-lfs` on PATH and preserve unrelated work before committing.
- Repo-local OpenSpec tooling limits edits to its root → resolve authorized cross-repo execution scope before changing `dotnix`; do not bypass the tooling boundary silently.

## Migration Plan

1. Re-read the persisted review and compare current HEADs with the reviewed commits; revalidate findings that moved.
2. Repair consumer resource/security binding and evaluation/identity failures.
3. Repair Tmux, targeted persistence, and host identity.
4. Restore tooling and migrate existing template/manual suites; correct source/lock portability.
5. Run narrow evaluations, existing tests, format/check gates, consumer fixture, and host builds; document external blockers separately.
6. Commit coherent verified repair blocks and request an independent review only after the repair work is finished. Do not activate a live host.

Rollback is limited to reverting task-owned repair commits if requested; never overwrite unrelated working-tree/index changes or revert the migration wholesale as cleanup.

## Post-review decisions (user-approved)

The follow-up review found integration defects beyond the original migration findings. Retain `profiles/` as named Den `includes` compositions rather than adding a typed profile framework or universal identity. Graphical host selection does not automatically configure Home Manager: route the selected shell explicitly to each intended user. In a Herdr composition, Workmux remains a separate tool for its supported backends, not a Herdr multiplexer adapter. Keep Git, RBW and mail identity values independent and consumer-owned.

A shared popup launcher Quirk is now justified by the requested Tmux/Herdr/tool intercommunication. Pinned Den `7594405` exports namespaced aspects and classes but not Quirk declarations, so each participating consumer (the real caller, public template and standalone fixtures) must declare the built-in `den.quirks.popup-launcher` exactly once in its root Den module. Aspect producers publish enabled launcher records in the selected user scope; Tmux and Herdr read that same-scope collection. No host-to-user forwarding or other-user leakage is implicit. It carries only common launcher data and selection metadata; each backend still owns its own key bindings, popup runtime, directory semantics, package and enable checks. Do not create a generic popup option framework, new package input, or host-wide routing for this data. First repair independently selectable tool packages, the Herdr partial-settings merge and its `prefix+b` collision; then introduce the smallest shared data contract that removes actual duplicate launcher lists. Preserve stable public aspect names. Capture a focused fixture proving both consumers of the Quirk receive the same enabled tools and disabled tools stay absent.

The user chose to retain the machine-local library source, so portable-source acceptance 5.2 remains explicitly open. User also excluded the separate boundary hardware/identity tests from this pass. Continue narrow source-level regressions and formatter/flake checks for changed logic; never equate skipped boundary checks with verification. Final review must identify these limitations rather than declaring the entire migration merge-ready.
