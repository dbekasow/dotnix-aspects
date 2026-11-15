# 06: Verify the integrated reference consumer

**What to build:** Establish that the complete approved profile design works through the real published template and combined consumer compositions, with honest completed-build evidence rather than isolated flags or an unexecuted derivation.

**Blocked by:** [02: Make workstation and power policy machine-independent](02-machine-independent-workstation-power.md); [03: Make desktop applications and launch bindings consumer-owned](03-consumer-owned-desktop-applications.md); [04: Make agent tooling and Workmux explicit selections](04-explicit-agent-workmux-selections.md); [05: Replace Tuicr with shared Hunk review access](05-shared-hunk-review-access.md).

**Status:** resolved

**Spec:** [Canonical specification](../spec.md).

**Spec coverage:** User stories 27, 30, 33–38, plus integration of the contracts delivered by tickets 02–05.

**Authorization:** Publication is not implementation approval. Obtain a separate execution instruction before running implementation work or treating this ticket as permission to activate a system.

**Test proportionality:** Acceptance criteria and user stories are contracts, not instructions to create one test each. Reuse existing fixtures and assertions; add only a minimal behavior check for a named regression risk that is not already covered, and state that gap briefly in the result. No duplicate coverage matrix, whole-configuration snapshots, source-text assertions, mocks of the Nix/Den module system, or additional UI/VM/runtime test layers. If those heavier techniques seem necessary, request separate approval rather than expanding this ticket. Preserve existing meaningful checks.

This ticket reruns the focused checks delivered by tickets 01–05 and completes the existing real-template build gate. It must not introduce a second integrated fixture suite or broader scenario matrix. Add a cross-slice assertion only if a concrete interaction is demonstrably uncovered, and prefer adding it to an existing fixture. A build timeout is not a reason to invent a replacement test harness.

- [x] Verify all predecessor slices have their own passing behavior tests and current documentation. This ticket combines their delivered contracts; it is not permission to defer their implementation, tests, or documentation.
- [x] Instantiate the actual published consumer template against the library under test, retain its real hardware reference and unmodified host/home composition, evaluate its system derivation, and complete the system closure build.
- [x] Do not substitute the reduced consumer-generation host or a hardware stub for the template acceptance gate. Initial locks in a disposable verification consumer are acceptable; do not change production inputs, pins, or repository lockfiles.
- [x] The real template provides Ghostty, Firefox, and Thunderbird with matching consumer-owned launch bindings, retains its explicit Btrfs/LUKS/bootloader/persistence example, and has no default root-reset, performance, geolocation, or YubiKey feature selection.
- [x] Rerun the existing focused cases from the predecessor tickets for workstation policy independence, the graphical family-home selection, and headless-server independence; do not recreate them as new integration fixtures.
- [x] Confirm the combined result using the predecessor tests for selected Hunk access in Tmux/Herdr, absence of implicit AI tools/repository packing/Pi persistence/Workmux, unselected-home isolation, explicit Workmux, and native power overrides. Reuse that coverage rather than adding another matrix.
- [x] Run formatter, full flake checks with checks built, the affected headless/security/Niri checks, and template evaluation/build on the combined result. Keep all 48 intended Niri/DMS assertions, accounting for the corrected upstream option name.
- [x] Audit the current profile inventory, active library examples, popup documentation, optional-feature guidance, and breaking-selection/hibernate migration notes against the canonical spec. Do not rewrite historical records or modify the separate live consumer.
- [x] Record exact reproduction commands, environment limits, exit codes, and evidence. A dependency failure or timeout leaves this ticket incomplete; it is not a successful build or a confirmed source defect by itself.
- [x] Keep the preexisting Btrfs VM runtime gap separate and visible. This slice does not change the reset algorithm or claim root-reset runtime safety from configuration assertions, and it must not expand device permissions or perform host disk operations.
- [x] Preserve native identities, state versions, unrelated application preferences, and occupant-created data. Do not incorporate the independent target-flake/loading redesign or introduce unrelated refactors.

The earlier template build timed out after 420 seconds; the Btrfs test build timed out after 300 seconds before VM runtime. These are baseline limitations, not acceptance results. Use a suitable build budget and existing permitted infrastructure for this ticket; never activate the resulting system merely to complete verification.

## Answer

Implemented and verified in `347ce07`. All predecessor slices have passing consumer contracts and current guidance. The actual published template was copied unchanged (only its initial disposable lock added), kept the genuine Dell hardware module and native host/home composition, evaluated and completed its full system closure build (exit 0). Output: `/nix/store/vkhsw299v91y1537y7c740kqa2hzgxcm-nixos-system-myHost-26.11.20261112.2074cc6`. `nix path-info -rS` traversed 2,176 closure paths successfully. The coordinator independently confirmed the store result and compared the acceptance consumer to the published template (identical excluding lock).

Exact commands, output observations, exit codes and limits are recorded in [verification evidence](../verification.md); detailed logs are under `/tmp/epc-06-evidence/`. Formatter, full built flake check and existing headless/security/Niri/terminal/review/conflict checks exited 0. Niri retains all original 48 assertions within 52 passing assertions; one concrete combined terminal/development Hunk popup assertion extends the existing terminal fixture, not another suite. The coordinator independently reran formatter and the complete check after integration (exit 0; `/tmp/epc-06-main-format.log`, `/tmp/epc-06-main-check.log`).

Template apps/keys, explicit storage and absent optional host choices were verified on actual final outputs. No production inputs/locks, identities, state versions, preferences, live consumer or loading redesign were changed. This completed closure build is not activation or hardware/runtime evidence. `/dev/kvm` is absent and the preexisting Btrfs VM runtime gap remains open separately; no device access was widened.
