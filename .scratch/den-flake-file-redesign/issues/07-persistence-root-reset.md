# 07: Select Persistence independently from the Btrfs root reset

**What to build:** Make generic Persistence classes and routing consumable separately from the explicit Btrfs root-reset machine policy. Both capabilities and their existing contributions remain available, but neither is activated by the other or by contract registration alone.

**Blocked by:** [02: Reorganize feature ownership and discovery around the confirmed criterion](02-feature-ownership-discovery.md).
**Status:** claimed
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] Generic Persistence is usable for explicitly selected targets without Home Manager and without an assumed disk or boot topology.
- [ ] Btrfs root reset remains a separately selectable machine policy; no generic Persistence selection activates reset, Disko, boot, or rollback behavior.
- [ ] Opting in on one target changes neither unselected targets nor other users; existing class and policy contributions remain effective.
- [ ] The adapter may register global class metadata, but it remains inert until the consumer explicitly selects Persistence.
- [ ] Reuse existing class, policy, and VM evidence in a targeted way. Do not represent the standalone Btrfs VM as part of root `flake check`.
