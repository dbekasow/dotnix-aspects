# 19: Offer existing profiles as optional role-pure compositions

**What to build:** Continue offering all existing profile capabilities as optional compositions of existing features. Profiles remain conveniently named choices, not mandatory tiers, catch-all features, or owners of consumer decisions.

**Blocked by:** [03: Exercise the generated consumer and optional tooling end to end](03-consumer-generation-tooling.md), [04: Use the host foundation without Home Manager](04-host-only-foundation.md), [05: Configure accounts without hidden shell or vault choices](05-account-selection.md), [06: Use Secrets and authentication with explicit consumer resources](06-secrets-auth-resources.md), [07: Select Persistence independently from the Btrfs root reset](07-persistence-root-reset.md), [08: Select Docker separately for host, account, and home](08-docker-targeted-selection.md), [09: Select shells and login shells independently](09-shell-selection.md), [10: Use the popup catalog with both backends](10-popup-backends.md), [11: Combine small CLI capabilities independently](11-cli-feature-selection.md), [12: Use Git, Helix, and development tools without host side effects](12-development-feature-selection.md), [13: Select agent tools and Handy independently](13-agent-handy-selection.md), [14: Separate Niri support from user configuration](14-niri-scope-separation.md), [17: Use styling with explicit per-target resources](17-styling-resources.md), [18: Use desktop applications with explicitly selected integrations](18-desktop-app-integrations.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] All 19 existing profile capabilities remain optional and are composed of individually selectable features; introduce neither new mandatory tiers nor new catch-all features.
- [x] Every profile remains transitively role-pure and overrides no consumer decisions; host, home, and account selections remain explicit.
- [x] Hidden GUI pinentry overrides from the former desktop-shell profile are assigned to the responsible Secrets/Auth feature selection, not duplicated in profile implementation.
- [x] Existing graphical foundation profiles do not silently select DMS/Noctalia runtimes or greeters; consumers select these explicitly. Explicitly selected role-pure shell profiles may still combine Fish or Nushell without waiting for tickets 15 and 16.
- [x] Profiles remain purely optional compositions; individual features continue to work without a profile.

## Integration evidence

- Implementation `038cf898714f5f151c9d0baa27c199cd18fe1e4c` independently approved by reviewer `39aba5d6-bb9d-41d`; integrated in merge `56095dd48f236bbb26c8d3a64a6a386b52c1aac0`.
- All 19 existing profile capabilities remain available as optional role-qualified compositions. Desktop and graphical-foundation profiles expose separate host and home selections; GNOME services and home persistence are separated without deleting either capability. No compatibility aliases or additional composition framework were introduced.
- Review covered every profile before and after the change, transitive role isolation, representative host-only use without Home Manager, unrelated-home/account isolation, and native overrides. Graphical foundations select neither desktop-shell runtimes nor greeters; GUI pinentry remains an explicit authentication-feature choice. Individually selected features remain usable without profiles.
- The original merger stopped before completing ticket metadata. The coordinator recovered the clean integration tree and reran all gates serially: broad compositions **94/94 true**, Niri/DMS **48/48 true**, headless evaluation and the actual DMS/Noctalia conflict-diagnostic regression passed. `nix flake check --no-build --no-write-lock-file`, `nix fmt`, `nix fmt -- --ci`, and `typos` all exited 0. Recovery logs are stored outside the repository under the execution directory's `logs/recover19/`.
- Source `flake.nix`, `flake.lock`, and the canonical parent spec remain unchanged. Evidence is evaluation and static validation only; build acceptance remains with ticket 20. No activation or runtime proof is claimed.
