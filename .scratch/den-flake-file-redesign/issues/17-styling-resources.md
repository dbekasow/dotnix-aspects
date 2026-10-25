# 17: Use styling with explicit per-target resources

**What to build:** Offer Stylix host and home selections with explicit consumer resources and native options. Styling remains individually selectable without a profile, but may be part of an explicitly selected role-pure profile; do not guess consumer layouts or image paths.

**Blocked by:** [02: Reorganize feature ownership and discovery around the confirmed criterion](02-feature-ownership-discovery.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] Select host and home styling explicitly for each target; provide required images/resources through native options.
- [x] The library does not derive a resource from an assumed consumer directory layout or fixed consumer path.
- [x] Fonts and theme defaults remain overridable through ordinary NixOS/Home Manager options.
- [x] Styling is usable standalone without a profile; individually selected Niri, DMS, and Noctalia features do not force it. An explicitly selected role-pure profile may deliberately combine styling; no hidden global default activates it.
- [x] Targeted styling changes neither other hosts nor other user homes.

## Integration evidence

Merged as `57109e38a1851956ae8cc08fa81b8402bf1f8ee9`.

- Host and home styling are separate selectors (`dotnix.host.stylix` and `dotnix.home.stylix`). The previously inferred wallpaper path is gone; a consumer supplies the image through the native `stylix.image` option on the target, and the fixtures prove that a consumer without the assumed layout no longer resolves to a guessed path.
- Theme and font defaults use overridable defaults, so an ordinary consumer assignment wins; that was demonstrated by evaluation rather than asserted.
- Target isolation holds: host styling does not reach any home, home styling touches neither hosts nor sibling homes, and standalone Niri, DMS and Noctalia selections do not force styling. A deliberately selected role-pure profile may still compose it.
- Firefox keeps working without Stylix; its Stylix integration only applies when those options exist.
- This ticket required several reconciliations because parallel tickets extended the same test file. Each was resolved as a union - styling fixtures, Niri role isolation and the overlay-free home-Niri fixture, Docker side-effect assertions, and the earlier accounts, shell, development and agent assertions all survive - and each reconciliation was reviewed separately.

Verification: 69 broad-composition assertions all true, 37 Niri/DMS assertions true, headless composition passed, flake evaluation passed with no build, formatting produced no changes, typography check clean, and source `flake.nix`/`flake.lock` unchanged with the recorded lock hash.

Evaluation only: no build, activation or runtime proof is claimed.
