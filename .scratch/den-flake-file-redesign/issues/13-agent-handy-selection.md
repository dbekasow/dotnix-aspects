# 13: Select agent tools and Handy independently

**What to build:** Make agent tools and Handy consumable as independent feature selections. Library-owned inputs and required unfree/overlay prerequisites remain explicitly assigned to the responsible feature and consumer.

**Blocked by:** [02: Reorganize feature ownership and discovery around the confirmed criterion](02-feature-ownership-discovery.md).
**Status:** claimed
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] LLM agents, AI tools, Workmux, Repomix, Tuicr, and Handy retain their existing individually selectable capabilities.
- [ ] Required inputs are captured by the feature; unfree and overlay prerequisites are explicit and are not hidden by a global fixture overlay.
- [ ] Handy remains exclusively owned by this ticket, not duplicated as a desktop application integration from ticket 18; its desktop integration remains locally selectable and does not automatically start a backend service.
- [ ] A standalone selection requires no implicit host-access expansion. Static risk notes are not presented as verified runtime failures or as new permission claims.
- [ ] Preserve existing native options and feature boundaries; do not replace the absence of a broad agent matrix with blanket individual tests.
