# 17: Use styling with explicit per-target resources

**What to build:** Offer Stylix host and home selections with explicit consumer resources and native options. Styling remains individually selectable without a profile, but may be part of an explicitly selected role-pure profile; do not guess consumer layouts or image paths.

**Blocked by:** [02: Reorganize feature ownership and discovery around the confirmed criterion](02-feature-ownership-discovery.md).
**Status:** claimed
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] Select host and home styling explicitly for each target; provide required images/resources through native options.
- [ ] The library does not derive a resource from an assumed consumer directory layout or fixed consumer path.
- [ ] Fonts and theme defaults remain overridable through ordinary NixOS/Home Manager options.
- [ ] Styling is usable standalone without a profile; individually selected Niri, DMS, and Noctalia features do not force it. An explicitly selected role-pure profile may deliberately combine styling; no hidden global default activates it.
- [ ] Targeted styling changes neither other hosts nor other user homes.
