# 04: Use the host foundation without Home Manager

**What to build:** Provide host-side system capabilities as individually selectable consumer choices, including boot, Disko, networking, Bluetooth, power, performance, geolocation, journald, locale, security, system packages, and the existing Nix-LD host capability. Host-only configuration must remain valid without Home Manager; existing home-side facets of shared Nix tools remain explicitly available.

**Blocked by:** [02: Reorganize feature ownership and discovery around the confirmed criterion](02-feature-ownership-discovery.md).
**Status:** claimed
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] `boot`, `boot-systemd`, `disko`, `network`, `network-wifi`, `bluetooth`, `power`, `performance`, `geolocation`, `journald`, and `nix-ld` are selectable as explicit host capabilities.
- [ ] `locale`, `security`, `system-packages`, `nix`, `nur`, and `nh` remain individually consumable; native substituter and key defaults belong to the Nix capability, and existing home facets of the Nix tools are preserved.
- [ ] A host can evaluate its selected host capabilities without integrated Home Manager; home configuration is not activated as a hidden prerequisite.
- [ ] Native options override library defaults. An unrelated host remains unchanged by a targeted host selection.
- [ ] Disko remains a declarative capability; add no disk operations, boot redesign, or implicit personal system inventories. The graphical foundation belongs to ticket 14, styling to ticket 17, and Secrets/Auth to ticket 06.
