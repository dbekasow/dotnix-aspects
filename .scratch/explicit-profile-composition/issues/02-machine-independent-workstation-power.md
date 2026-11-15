# 02: Make workstation and power policy machine-independent

**What to build:** Let consumers select useful workstation equipment without inheriting boot, storage, tuning, location, or hardware-authentication policy. Supply reusable power services, and make the reference template's machine-specific choices explicit and safe to understand.

**Blocked by:** [01: Restore executable consumer contract checks](01-restore-consumer-contract-checks.md).

**Status:** resolved

**Spec:** [Canonical specification](../spec.md).

**Spec coverage:** User stories 1–8, 30–32, 35, and the power-policy migration part of 37.

**Authorization:** Publication is not implementation approval. Obtain a separate execution instruction before changing production code or tests.

**Test proportionality:** Acceptance criteria and user stories are contracts, not instructions to create one test each. Reuse existing fixtures and assertions; add only a minimal behavior check for a named regression risk that is not already covered, and state that gap briefly in the result. No duplicate coverage matrix, whole-configuration snapshots, source-text assertions, mocks of the Nix/Den module system, or additional UI/VM/runtime test layers. If those heavier techniques seem necessary, request separate approval rather than expanding this ticket. Preserve existing meaningful checks.

Extend an existing host/control fixture and compare only the power/storage options promised by this slice. Do not compare entire configurations, enumerate CPU/storage combinations, or add a new Btrfs/hibernate VM.

- [x] Workstation selects only boot-baseline, Bluetooth, network, network-Wi-Fi, PipeWire, and power. It selects no bootloader, disk layout, generic persistence, root reset, performance tuning, geolocation, or YubiKey support.
- [x] General power retains Upower, power-profiles-daemon, and its existing diagnostic tools. Remove its Intel thermald, specific resume-device, deep-sleep, sleep-permission/delay, key/lid-action, and battery-threshold/action overrides. Let platform defaults or explicit native host settings apply; do not add detection or a new hibernation switch.
- [x] An otherwise equivalent consumer control fixture proves that power and workstation introduce none of those removed policies. Explicit native host bootloader, filesystem, resume, sleep, and battery choices remain effective.
- [x] The existing performance feature remains directly selectable with its current tuning unchanged. The other removed capabilities remain individually available.
- [x] The template retains its explicit Btrfs/LUKS, bootloader, persistence, and hardware reference, but selects no root reset, tuning, geolocation, or YubiKey feature by default. Explain those as opt-in additions with prerequisites and consequences.
- [x] Keep disk geometry, encryption/enrollment mechanics, resource identities, and state versions unchanged. Removing the YubiKey feature is not a redesign of the existing Disko enrollment example.
- [x] Cover the new workstation/power contract in the regular consumer gate with a small host/control scenario and explicit overrides. Reuse the existing headless-server regression instead of duplicating it. Check emitted behavior, not include-list lengths or private helper structure.
- [x] Update the current profile and template guidance, including the warning that a host adopting this change must explicitly preserve its previous custom hibernation recipe.
- [x] Formatter, full flake checks, affected behavioral checks, and template derivation evaluation pass. A completed system closure build remains part of ticket 06; do not claim evaluation proves a completed build.

Do not migrate the live dotnix consumer, add aliases or options, change inputs/locks, or activate a system. This slice does not redesign unrelated application or compositor behavior.

## Answer

Implemented in `abc76f5`, with integration synchronization `8257af5`. Workstation now contains only the specified equipment features; power keeps its services/diagnostic tool without prescribing machine-specific policy. Equivalent control/native-override assertions extend the existing headless fixture. Template storage, enrollment and hardware remain intact; optional host choices and hibernation migration are documented.

Vertical power/workstation/template regressions failed before implementation and passed afterwards. Formatter, full built flake check, focused headless/Niri checks (48 baseline assertions) and real unchanged copied-template derivation evaluation exited 0. Exact commands and logs: `/tmp/epc-02-evidence/`. Template closure build is not claimed; it remains ticket 06. GeoClue can independently be enabled by another template component even though `host.geolocation` is not selected; documentation distinguishes this from selecting the location provider.

The coordinator inspected the production/test diffs and reran `nix fmt` plus `nix flake check --no-write-lock-file --accept-flake-config` on the combined 02/04/05 integration at `325e051` (both exit 0; `/tmp/epc-mid-format.log`, `/tmp/epc-mid-check.log`). Conflicting shared profile, check-registration and guidance edits were combined without restoring implicit selections. Runtime, activation and incompatible non-host systems are not covered.
