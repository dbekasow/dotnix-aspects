# Design

## Context

See `proposal.md` for motivation and `specs/` for observable contracts. Planning scope is limited to this library repository; the separate Caller repository requires separately authorized scope. At planning revision, preserve existing dirty changes, including staged diagnostic-report deletions, the staged library lockfile change, and untracked `docs/caller-migration.md`; do not absorb or overwrite them. The import tree currently exports aspect files automatically; `modules/expose.nix` wraps function modules in an ordinary lambda. Niri bindings in `niri-bindings.nix` contain DMS IPC, while the general Niri configuration disables DMS Polkit. Workmux and Tuicr each define a Home Manager aspect and also contribute unconditionally to the shared Tmux aspect. The initrd rollback uses `btrfs subvolume list -o`, extracts paths textually, and has no trap cleanup. Hibernate documentation currently refers to `filefrag`.

## Goals / Non-Goals

**Goals:**

- Keep necessary host factory, hostname registry key, `vaultReady` public-key gate, disk variants, and Tmux/Git collectors; remove only redundant option payloads when simplification is net positive.
- Make feature ownership explicit, retain typed collectors only for genuine collection points, and provide a reusable headless path that does not assume a host identity or hardware.
- Secure destructive root rollback prerequisites, device readiness, mount error policy, and regression tests in a disposable Btrfs VM.
- Ground Hibernate and diagnostic guidance in verified tool and version limits.

**Non-Goals:**

- No global optimization or claimed fix for dock audio or desktop/boot/battery performance without host measurements.
- No changes to disk geometry, swap size, blanket NoCoW/compression options, workstation sysctl values, renderer, HDMI, or audio power-saving rules. Workstation-only sysctls may move out of the headless base without changing their workstation values.
- No live-host rollback, Hibernate, or audio experiments; no unmeasured hardware tuning; no unrelated input/lockfile updates; and no new enable framework.

## Decisions

1. **Preserve necessary API; simplify redundant payloads.** Public API changes are permitted only when removal is a net simplification. Keep `dotnix.hosts` factory behavior, hostname registry keys, `vaultReady` public-key gate, disk variants, and Tmux/Git collectors. Remove redundant profile `username`/`theme` options and duplicated runtime host payload; retain only members data in its single source of truth. Prefer native NixOS authorizedKeys over mirrored profile SSH keys where feasible. Document each intentional breaking change and migration. Composition-only files belong under `modules/aspects/profiles/`; keep DMS, Helix, and Tmux families in their feature directories; retain small standalone features and Impermanence collector directories. `[N]`/`[Nn]` may be documented; `I` is not a module-class marker. Verify imports/assets during moves.

2. **Make ownership and selection explicit.** Feature settings live with the owning feature. No new enable framework. DMS IPC follows DMS selection; guard evaluation when the DMS option is undeclared. Polkit follows the selected shell rather than being forced off. Workmux/Tuicr retain their tool aspects, but Tmux contributions require both tool selection and actual enabled Tmux context; a declared-but-disabled option does not activate Tmux. Keep imports static; do not treat a `configFile` heuristic as a guaranteed API.

3. **Preserve module semantics in the wrapper.** `wrapMods` should mirror named module-argument metadata so additional arguments such as `_module.args` are not lost through the lambda. Nixpkgs `lib.mirrorFunctionArgs` and `lib.setDefaultModuleLocation` are minimal candidates; verify their exact signatures and availability against the locked `lib` during apply. Keep shallow `//` precedence intentionally: consumer values, including `self`, win, and library values fill only missing inputs. Add no flake input.

4. **Make rollback fail closed and recursive.** Verify the device, mount, `@root`, and `@root-blank` before changing `@root`. Remove nested subvolumes using a path-safe child-before-parent algorithm; do not use `cut` or whitespace splitting. Keep siblings such as `@persist`, `@nix`, `@log`, and `@swap` outside the target set. A trap cleans up the temporary mount even on failure. The initrd unit waits for `cryptroot` in the standard encrypted layout, or for the labeled device in the plain layout; rollback runs before `sysroot.mount`, and errors block the root mount. This is intentionally fail-closed and changes behavior; document a recovery path. Official subvolume documentation states that `list -o` is not recursive; do not use `delete -R` unless support in the locked `btrfs-progs` version is verified. Run regression tests in a disposable Btrfs VM; shell mocks alone are insufficient.

5. **Separate Hibernate offset from resume target.** Replace the `filefrag` reference with `btrfs inspect-internal map-swapfile -r /swap/swapfile`; the offset remains an actual property of the provisioned swapfile. Configure the resume backing device separately; zram is not a persistent resume target. Check swapfile flags, preallocation, and compression against the Disko-generated source and, if needed, a disposable image. `@swap` mount options do not prove that a filesystem-wide option was excluded on the first mount.

6. **Keep diagnosis and Caller migration explicit.** The diagnostic guide records sink/card/profile/port/default before and after hotplug or resume and distinguishes USB audio from HDMI/DP. For reproducible sluggishness, collect `powerprofilesctl get`, `systemd-analyze critical-chain`, and CPU/GPU/I/O/thermal measurements. Do not read or write live host logs; redact private values. Existing `.local/state/wireplumber` persistence and `thermald` activation, along with Nixpkgs/PipeWire revisions, are hypotheses or version differences, not proven causes. WirePlumber 0.5.18 documentation does not automatically apply to locked version 0.5.17. Audio/performance status may remain unresolved after implementation due to missing host data. This repo-local OpenSpec's `allowedEditRoots` covers only `/home/denis/projects/dotnix-aspects`; it cannot authorize Caller source edits. Track end-to-end migration as a separate session/task with explicit `/home/denis/projects/dotnix` write scope and update its pin and lockfile to the reviewed library revision, without unrelated input updates. Acceptance includes Luffy toplevel and Roger ISO checks if retained, actual existing system/Home Manager stateVersions, HM DMS integration, devTools needed by Caller, user repositories, correct pin, and a reviewed lock diff preserving unrelated changes. Do not activate live hosts. Overall completion requires caller checks.

7. **Keep server composition neutral.** A `server` or narrower `base` composition must avoid workstation performance settings and boot-systemd assumptions. Generic `core` remains an explicit work/admin profile, not a universal server baseline. Wheel login requires a password by default; passwordless wheel access is allowed only through an explicit hardware-gated opt-out. Each host/fixture explicitly supplies bootloader and root-disk configuration. Do not add a speculative VPS identity or provider-specific host.

### References

- Btrfs Swapfile: https://btrfs.readthedocs.io/en/latest/Swapfile.html — swapfile offset mapping, NOCOW/preallocation, single-device and snapshot constraints.
- Btrfs Subvolumes: https://btrfs.readthedocs.io/en/latest/btrfs-subvolume.html — `list -o` is not recursive; snapshots are not recursive; support for `delete -R` in the relevant version is unverified.
- Btrfs Administration: https://btrfs.readthedocs.io/en/latest/Administration.html — many mount options apply filesystem-wide, and the first mount establishes behavior.
- WirePlumber ALSA: https://pipewire.pages.freedesktop.org/wireplumber/daemon/configuration/alsa.html — documentation is for 0.5.18, so it differs from locked version 0.5.17.

## Risks / Trade-offs

- **Fail-closed rollback stops boot when the baseline is missing** → provide recovery instructions and VM tests for a missing snapshot and failures at each step.
- **Btrfs output and paths are error-prone** → test the recursive algorithm against real nested subvolumes, including paths with spaces; do not treat shell mocks as safety evidence.
- **Option detection may fail under module composition** → test absent DMS/Tmux option declarations in the consumer fixture and do not treat an undocumented file option as an API.
- **Nixpkgs helper may differ in the locked version** → verify its signature and export before implementation.
- **No hardware measurements are available** → explicitly mark diagnostic conclusions as unresolved and move symptom-specific code changes to a follow-up change.

## Migration Plan

1. Make file moves, intentional API migration, headless composition, and optional-integration changes in focused blocks. Use focused evaluation early; defer expensive consumer toplevel builds until the milestone gate.
2. Approve rollback only after prerequisites, mount trap, and VM regressions are in place; failure cases must block `sysroot.mount` fail-closed. Investigate and test resume-before-destructive-rollback ordering on a disposable VM before implementing a safety-sensitive interaction.
3. Complete library work and the separately scoped Caller migration, including correct pin/lock review and host-specific acceptance checks. Do not activate live hosts.
4. After structure, composition, rollback, Caller migration, and tests are complete, conduct exactly one independent full source review and address its findings.
5. Run heavy builds once at the milestone gate; then verify `nix fmt` produces no diff, `nix flake check` does not write or overwrite unrelated lock changes, and library and Caller fixtures/checks pass.
6. Diagnose the host only with redacted measurements; document status as unresolved if measurements are unavailable.

## Open Questions

The resume-versus-rollback interaction is a required pre-code investigation and disposable-VM test, not a presumed existing defect. Device/option details and locked-tool support remain concrete apply-time checks. No host or provider-specific VPS design is implied.
