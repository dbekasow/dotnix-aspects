# 19: Offer existing profiles as optional role-pure compositions

**What to build:** Continue offering all existing profile capabilities as optional compositions of existing features. Profiles remain conveniently named choices, not mandatory tiers, catch-all features, or owners of consumer decisions.

**Blocked by:** [03: Exercise the generated consumer and optional tooling end to end](03-consumer-generation-tooling.md), [04: Use the host foundation without Home Manager](04-host-only-foundation.md), [05: Configure accounts without hidden shell or vault choices](05-account-selection.md), [06: Use Secrets and authentication with explicit consumer resources](06-secrets-auth-resources.md), [07: Select Persistence independently from the Btrfs root reset](07-persistence-root-reset.md), [08: Select Docker separately for host, account, and home](08-docker-targeted-selection.md), [09: Select shells and login shells independently](09-shell-selection.md), [10: Use the popup catalog with both backends](10-popup-backends.md), [11: Combine small CLI capabilities independently](11-cli-feature-selection.md), [12: Use Git, Helix, and development tools without host side effects](12-development-feature-selection.md), [13: Select agent tools and Handy independently](13-agent-handy-selection.md), [14: Separate Niri support from user configuration](14-niri-scope-separation.md), [17: Use styling with explicit per-target resources](17-styling-resources.md), [18: Use desktop applications with explicitly selected integrations](18-desktop-app-integrations.md).
**Status:** ready-for-agent
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] All 19 existing profile capabilities remain optional and are composed of individually selectable features; introduce neither new mandatory tiers nor new catch-all features.
- [ ] Every profile remains transitively role-pure and overrides no consumer decisions; host, home, and account selections remain explicit.
- [ ] Hidden GUI pinentry overrides from the former desktop-shell profile are assigned to the responsible Secrets/Auth feature selection, not duplicated in profile implementation.
- [ ] Existing graphical foundation profiles do not silently select DMS/Noctalia runtimes or greeters; consumers select these explicitly. Explicitly selected role-pure shell profiles may still combine Fish or Nushell without waiting for tickets 15 and 16.
- [ ] Profiles remain purely optional compositions; individual features continue to work without a profile.
