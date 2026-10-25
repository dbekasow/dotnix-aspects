# 15: Run DMS and Noctalia for different users

**What to build:** Make DMS and Noctalia runtimes, their integrations, and per-user Polkit agents selectable per Home target. One machine can run different user runtimes; real exclusivity applies only to incompatible selections for the same target.

**Blocked by:** [14: Separate Niri support from user configuration](14-niri-scope-separation.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] Alice can select DMS and Bob Noctalia on the same host without a global desktop or home selection switching services for the other user.
- [x] DMS, plugins, settings, Noctalia runtime, and their integrations remain assigned to their respective features; per-user Polkit is not enabled globally for all accounts.
- [x] A real conflict on the same target fails with a clear diagnostic; different compatible targets are not blocked by global desktop exclusivity.
- [x] Use the existing desktop fixture specifically to check the two-user composition; do not present static search results as runtime evidence. No combination matrix.
- [x] Provide U2F resources through native options and non-secret fixture values; assume no consumer path format, and require no ticket 06 dependency for non-security-sensitive base cases.

## Answer

Merged reviewed implementation `e8dcd0c741fc5cf180a27f13679464ec4d56e67d` as
`dfb9a19a51ab9a27ca0de965c6bd3ac25e5e1d6b` after a conflict-free merge-tree probe.
Review chain: `951cd636` approved the original implementation except its conflict
diagnostic; `08e6acdc` approved fix `3d398d0` with the actual stderr regression;
`b331e1b3` approved DMS/native-security union `8323a71` and the final docs-only
merge `e8dcd0c`. No remaining review findings.

Serial integration verification passed:

- Broad compositions: 80/80 true; Niri/DMS fixture: 48/48 true.
- Headless composition evaluation passed.
- `bash tests/niri-dms-conflict.sh` verified the specific evaluation diagnostic:
  `DMS and Noctalia cannot both be selected for the same Home Manager target.`
  The invalid same-home composition fails with that diagnostic, not a masked
  duplicate-key error.
- `nix flake check --no-build --no-write-lock-file`, `nix fmt`,
  `nix fmt -- --ci`, and `typos` passed. Formatting produced no changes.

The existing two-user fixture verifies Alice's DMS and Bob's Noctalia per-home
isolation, disabled host DMS runtime, and per-user Polkit ownership: the DMS user
omits the Niri agent while the non-DMS user retains it. Native U2F options accept
public fixture resources without requiring secrets or a consumer path convention;
non-security base cases remain independent of that resource setup.

Evidence is evaluation-only: no runtime authentication or activation proof is
claimed. Source `flake.nix` and `flake.lock` are unchanged from the premerge tip;
the lock SHA-256 matches the recorded source guard
`6f9c06db3f8a4211e10a99998c20c27c3307d8a4eedd9a69d3fed9b0af2f0e47`.
The canonical parent spec remains unchanged.
