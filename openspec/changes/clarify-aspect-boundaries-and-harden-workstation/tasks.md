# Tasks

## 1. Aspect structure and export contract

- [x] 1.1 (up to 2 h) Move composition files to `modules/aspects/profiles/` and group DMS/Helix/Tmux-only file families; check relative imports and assets, then run `git diff --check` and verify the change list for path/content equivalence only.
- [ ] 1.2 (up to 2 h) Extend focused consumer-fixture evaluation for the documented target API: retained public factory/gates/collectors, migrated members-only payload, intentional removals, and original export error locations. Do not require the expensive fixture toplevel build before the milestone gate; verify focused evaluation now and run the toplevel at the gate.
- [x] 1.3 (up to 2 h) Implement `wrapMods` metadata handling using the locked nixpkgs `lib` and add regression coverage for an additional `_module.args` argument and caller `self`/input precedence; targeted evaluation must verify both contracts.
- [x] 1.4 (up to 2 h) Remove only redundant custom option payloads (`username`, `theme`, duplicate runtime host payload, and mirrored SSH-key option where native NixOS authorizedKeys suffice); retain necessary factory, hostname registry key, `vaultReady` public-key gate, disk variants, and Tmux/Git collectors. Document each breaking migration and verify migrated behavior in focused fixtures.

## 2. Optional desktop and Tmux composition

- [x] 2.1 (up to 2 h) Separate DMS Niri IPC from the general Niri profile and make Polkit follow selected-shell ownership; check DMS option guards without a DMS option declaration and verify available Niri options against locked modules, then evaluate Niri-only, Niri+DMS, and class-correct Niri+Noctalia scenarios.
- [ ] 2.2 (up to 2 h) Gate Workmux/Tuicr Tmux contributions on selection of the corresponding tool and available Tmux context; extend the consumer fixture for Tmux-only, tools+Tmux, and tools-only, and ensure all three evaluations pass.
- [ ] 2.3 (up to 2 h) Complete desktop/Tmux composition changes with relevant regressions and a concise usage note; evaluate existing broad profiles and class-correct Noctalia Home Manager integration.
- [x] 2.4 (up to 2 h) Provide and document a neutral headless/server composition (or narrower base) that excludes workstation laptop sysctls/zram, audio, Bluetooth, UPower/thermald, Hibernate/Disko defaults, workstation boot-systemd assumptions, and automatic root-disk selection. Keep `core` an explicit work/admin profile and avoid server/workstation boot-systemd assumptions; fixture must provide bootstrap root and bootloader explicitly.
- [x] 2.5 (up to 2 h) Add focused checks that wheel login requires a password by default, only an explicit hardware-gated opt-out permits passwordless login, and two distinct placeholder host registrations evaluate without hardware-specific names or provider assumptions.

## 3. Btrfs rollback and Hibernate

- [ ] 3.1 (up to 2 h) Check locked `btrfs-progs` support and the Disko-generated swapfile layout; record the permitted recursive deletion strategy, mount/compression behavior, and resume properties in the design note, without using live storage.
- [ ] 3.2 (up to 2 h) Implement rollback prerequisites, device readiness, fail-safe root mounting, and an unmount trap; targeted initrd evaluation for encrypted `cryptroot` and a directly labeled device must verify ordering before `sysroot.mount`.
- [ ] 3.3 (up to 2 h) Create disposable Btrfs VM regressions for multiple nesting levels, a path containing spaces, missing `@root-blank`, failures before root mount, and sentinel siblings `@persist`/`@nix`/`@log`/`@swap`; automated VM checks must verify data integrity and fail-closed behavior. Shell mocks alone are insufficient.
- [ ] 3.4 (up to 2 h) Update the Hibernate comment and documentation to use `btrfs inspect-internal map-swapfile -r /swap/swapfile`, a separate resume device, and a clear distinction from zram; provisioning checks must verify prerequisites and must not override host parameters.
- [ ] 3.5 (up to 2 h) Complete rollback recovery and Hibernate prerequisite documentation; documented recovery must not alter sibling subvolumes, and VM/provisioning checks must use disposable resources.
- [ ] 3.6 (up to 2 h) Before implementing resume/rollback interaction, investigate and test on a disposable VM whether initrd resume can still be active when destructive rollback begins. Verify resume completion precedes rollback or enforce a fail-closed safety gate; do not assume a defect without evidence.

## 4. Diagnostics, milestone review, and integration

- [x] 4.1 (up to 2 h) Create a diagnostic guide covering dock sink/card/profile/port/default before and after hotplug/resume, USB audio vs. HDMI/DP, power profile, boot chain, and CPU/GPU/I/O/thermals; the sample report must redact measurements and mark audio/performance causes as unresolved without data.
- [ ] 4.2 (up to 2 h) After library structure, composition, rollback, Caller migration, and their tests are complete, conduct exactly one independent overall source review and address findings; do not perform the review early or edit Caller source without its separately scoped task.
- [ ] 4.3 (up to 2 h) Run heavy builds once at the milestone gate, then verify formatting, library checks, the consumer fixture, and Caller checks all pass. Confirm checks do not overwrite existing or unrelated lock changes; Caller pin/lock diff must contain only the reviewed library update and required transitive changes. Final diagnosis may remain unresolved due to missing host data.
- [ ] 4.4 (up to 2 h) Complete the library-root handoff note/checklist. Record that Caller source migration and pin/lock update are a separately tracked task/session requiring explicit `/home/denis/projects/dotnix` write scope; record its completed checks and reviewed diff only after that task runs. This task does not authorize or instruct Caller source edits from this repo-local change.
