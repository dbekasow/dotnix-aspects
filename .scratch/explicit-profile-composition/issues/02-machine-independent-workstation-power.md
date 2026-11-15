# 02: Make workstation and power policy machine-independent

**What to build:** Let consumers select useful workstation equipment without inheriting boot, storage, tuning, location, or hardware-authentication policy. Supply reusable power services, and make the reference template's machine-specific choices explicit and safe to understand.

**Blocked by:** [01: Restore executable consumer contract checks](01-restore-consumer-contract-checks.md).

**Status:** claimed

**Spec:** [Canonical specification](../spec.md).

**Spec coverage:** User stories 1–8, 30–32, 35, and the power-policy migration part of 37.

**Authorization:** Publication is not implementation approval. Obtain a separate execution instruction before changing production code or tests.

**Test proportionality:** Acceptance criteria and user stories are contracts, not instructions to create one test each. Reuse existing fixtures and assertions; add only a minimal behavior check for a named regression risk that is not already covered, and state that gap briefly in the result. No duplicate coverage matrix, whole-configuration snapshots, source-text assertions, mocks of the Nix/Den module system, or additional UI/VM/runtime test layers. If those heavier techniques seem necessary, request separate approval rather than expanding this ticket. Preserve existing meaningful checks.

Extend an existing host/control fixture and compare only the power/storage options promised by this slice. Do not compare entire configurations, enumerate CPU/storage combinations, or add a new Btrfs/hibernate VM.

- [ ] Workstation selects only boot-baseline, Bluetooth, network, network-Wi-Fi, PipeWire, and power. It selects no bootloader, disk layout, generic persistence, root reset, performance tuning, geolocation, or YubiKey support.
- [ ] General power retains Upower, power-profiles-daemon, and its existing diagnostic tools. Remove its Intel thermald, specific resume-device, deep-sleep, sleep-permission/delay, key/lid-action, and battery-threshold/action overrides. Let platform defaults or explicit native host settings apply; do not add detection or a new hibernation switch.
- [ ] An otherwise equivalent consumer control fixture proves that power and workstation introduce none of those removed policies. Explicit native host bootloader, filesystem, resume, sleep, and battery choices remain effective.
- [ ] The existing performance feature remains directly selectable with its current tuning unchanged. The other removed capabilities remain individually available.
- [ ] The template retains its explicit Btrfs/LUKS, bootloader, persistence, and hardware reference, but selects no root reset, tuning, geolocation, or YubiKey feature by default. Explain those as opt-in additions with prerequisites and consequences.
- [ ] Keep disk geometry, encryption/enrollment mechanics, resource identities, and state versions unchanged. Removing the YubiKey feature is not a redesign of the existing Disko enrollment example.
- [ ] Cover the new workstation/power contract in the regular consumer gate with a small host/control scenario and explicit overrides. Reuse the existing headless-server regression instead of duplicating it. Check emitted behavior, not include-list lengths or private helper structure.
- [ ] Update the current profile and template guidance, including the warning that a host adopting this change must explicitly preserve its previous custom hibernation recipe.
- [ ] Formatter, full flake checks, affected behavioral checks, and template derivation evaluation pass. A completed system closure build remains part of ticket 06; do not claim evaluation proves a completed build.

Do not migrate the live dotnix consumer, add aliases or options, change inputs/locks, or activate a system. This slice does not redesign unrelated application or compositor behavior.
