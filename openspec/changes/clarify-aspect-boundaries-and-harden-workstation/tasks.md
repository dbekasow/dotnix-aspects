# Tasks

## 1. Aspect structure and export contract

- [x] 1.1 (up to 2 h) Move composition files to `modules/aspects/profiles/` and group DMS/Helix/Tmux-only file families; check relative imports and assets, then run `git diff --check` and verify the change list for path/content equivalence only.
- [ ] 1.2 (up to 2 h) Extend the aspect export matrix for existing public names, classes, and subprofiles using the existing consumer fixture; build the fixture toplevel from `.github/workflows/flake-check.yml` and verify identical export names.
- [ ] 1.3 (up to 2 h) Implement `wrapMods` metadata handling using the locked nixpkgs `lib` and add regression coverage for an additional `_module.args` argument and caller `self`/input precedence; targeted evaluation must verify both contracts.

## 2. Optional desktop and Tmux composition

- [ ] 2.1 (up to 2 h) Separate DMS Niri IPC from the general Niri profile and disable Polkit independently; check the DMS option without a DMS option declaration and verify available Niri options against locked modules, then evaluate Niri-only, Niri+DMS, and Niri+Noctalia scenarios.
- [ ] 2.2 (up to 2 h) Gate Workmux/Tuicr Tmux contributions on selection of the corresponding tool and available Tmux context; extend the consumer fixture for Tmux-only, tools+Tmux, and tools-only, and ensure all three evaluations pass.
- [ ] 2.3 (up to 2 h) Complete composition changes with relevant module/fixture regressions and a concise usage note; evaluate existing broad profiles and verify that they continue to work.

## 3. Btrfs rollback and Hibernate

- [ ] 3.1 (up to 2 h) Check locked `btrfs-progs` support and the Disko-generated swapfile layout; record the permitted recursive deletion strategy, mount/compression behavior, and resume properties in the design note, without using live storage.
- [ ] 3.2 (up to 2 h) Implement rollback prerequisites, device readiness, fail-safe root mounting, and an unmount trap; targeted initrd evaluation for encrypted `cryptroot` and a directly labeled device must verify ordering before `sysroot.mount`.
- [ ] 3.3 (up to 2 h) Create disposable Btrfs VM regressions for multiple nesting levels, a path containing spaces, missing `@root-blank`, failures before root mount, and sentinel siblings `@persist`/`@nix`/`@log`/`@swap`; automated VM checks must verify data integrity and fail-closed behavior. Shell mocks alone are insufficient.
- [ ] 3.4 (up to 2 h) Update the Hibernate comment and documentation to use `btrfs inspect-internal map-swapfile -r /swap/swapfile`, a separate resume device, and a clear distinction from zram; provisioning checks must verify prerequisites and must not override host parameters.
- [ ] 3.5 (up to 2 h) Complete rollback recovery and Hibernate prerequisite documentation; documented recovery must not alter sibling subvolumes, and VM/provisioning checks must use disposable resources.

## 4. Diagnostics, milestone review, and integration

- [x] 4.1 (up to 2 h) Create a diagnostic guide covering dock sink/card/profile/port/default before and after hotplug/resume, USB audio vs. HDMI/DP, power profile, boot chain, and CPU/GPU/I/O/thermals; the sample report must redact measurements and mark audio/performance causes as unresolved without data.
- [ ] 4.2 (up to 2 h) After structure, composition, rollback, and their tests are complete, conduct exactly one independent overall review and address its findings; the review must not replace per-worker reviews or edit callers outside this repository.
- [ ] 4.3 (up to 2 h) Run heavy builds once at the milestone gate, then verify `nix fmt` produces no diff, `nix flake check` does not write the lockfile, and the existing consumer fixture passes; final diagnosis may explicitly remain unresolved due to missing host data.
- [ ] 4.4 (up to 2 h) Document the separate caller migration in `/home/denis/projects/dotnix` as an accompanying step requiring approval, without changing files, pins, or inputs there; the note must list the pin difference and namespace, DMS/greeter, Devtools, ISO, and repository changes.
