# 10: Use the popup catalog with both backends

**What to build:** Make the popup launcher usable with one authoritative library-owned data source and explicit backend selection. Tmux and Herdr renderers use the same launcher data without taking Zellij/Sesh capabilities from their owners.

**Blocked by:** [02: Reorganize feature ownership and discovery around the confirmed criterion](02-feature-ownership-discovery.md).
**Status:** ready-for-agent
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] Launcher records define the command, size, and required backend keys once; Tmux and Herdr renderers translate this source instead of maintaining parallel complete required mappings.
- [ ] Programs enabled through native Home Manager options remain discoverable, even when no same-named Aspect is selected.
- [ ] If a backend key is missing, the renderer omits the candidate and provides an actionable diagnostic; do not perform an unchecked lookup or force a feature.
- [ ] Preserve existing scratch, directory, and menu behavior and ordinary native overrides.
- [ ] Zellij and Sesh retain their existing ownership; backend selection does not require Fish selection when absolute program files are available.
