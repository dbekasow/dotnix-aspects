# 07: Select Persistence independently from the Btrfs root reset

**What to build:** Make generic Persistence classes and routing consumable separately from the explicit Btrfs root-reset machine policy. Both capabilities and their existing contributions remain available, but neither is activated by the other or by contract registration alone.

**Blocked by:** [02: Reorganize feature ownership and discovery around the confirmed criterion](02-feature-ownership-discovery.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] Generic Persistence is usable for explicitly selected targets without Home Manager and without an assumed disk or boot topology.
- [x] Btrfs root reset remains a separately selectable machine policy; no generic Persistence selection activates reset, Disko, boot, or rollback behavior.
- [x] Opting in on one target changes neither unselected targets nor other users; existing class and policy contributions remain effective.
- [x] The adapter may register global class metadata, but it remains inert until the consumer explicitly selects Persistence.
- [x] Reuse existing class, policy, and VM evidence in a targeted way. Do not represent the standalone Btrfs VM as part of root `flake check`.

## Integration evidence

Merged as `feat(persistence): integrate reviewed persistence separation` after independent review returned APPROVE with no findings.

Checks run in the integration worktree after the merge:

- `nix eval --impure --file tests/broad-compositions.nix` - all asserted values `true`, including `selectedPersistenceWithoutHomeManagerIsGeneric`, `selectedRootResetIsIndependent`, `persistenceNeedsSelection`, `homePersistenceBaselineIsTargeted`, `persistenceRoutingCanBeExcluded`, `selectedSystemPersistence`, `selectedHomePersistence`, `adapterRegistrationIsInert` and `unrelatedUserHasNoPipewireHomePersistence`.
- `nix eval --impure --file tests/headless-composition.nix` - `"headless and workstation composition checks passed"`.
- `nix flake check --no-build --no-write-lock-file` - `all checks passed!`.
- `typos --force-exclude --format brief --hidden .` - exit 0, no output.
- `nix fmt -- --ci` - 220 files, 0 changed; `git status --porcelain` empty afterwards.
- `git diff 4c75978..HEAD -- flake.nix flake.lock` - empty; `sha256sum flake.lock` matches the recorded source lock digest.

Scope: this is evaluation-only evidence. No build, runtime, boot, or disk-operation proof was produced, and the standalone Btrfs rollback VM was neither built nor run here; it remains outside root `flake check`, and its inputs were narrowed to the `host.btrfs-root-reset` feature.
