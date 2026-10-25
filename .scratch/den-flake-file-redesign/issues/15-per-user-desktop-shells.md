# 15: Run DMS and Noctalia for different users

**What to build:** Make DMS and Noctalia runtimes, their integrations, and per-user Polkit agents selectable per Home target. One machine can run different user runtimes; real exclusivity applies only to incompatible selections for the same target.

**Blocked by:** [14: Separate Niri support from user configuration](14-niri-scope-separation.md).
**Status:** claimed
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] Alice can select DMS and Bob Noctalia on the same host without a global desktop or home selection switching services for the other user.
- [ ] DMS, plugins, settings, Noctalia runtime, and their integrations remain assigned to their respective features; per-user Polkit is not enabled globally for all accounts.
- [ ] A real conflict on the same target fails with a clear diagnostic; different compatible targets are not blocked by global desktop exclusivity.
- [ ] Use the existing desktop fixture specifically to check the two-user composition; do not present static search results as runtime evidence. No combination matrix.
- [ ] Provide U2F resources through native options and non-secret fixture values; assume no consumer path format, and require no ticket 06 dependency for non-security-sensitive base cases.
