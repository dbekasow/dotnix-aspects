# Design

## Context

See `proposal.md` for motivation and `specs/` for observable contracts. The import tree currently exports aspect files automatically; `modules/expose.nix` wraps function modules in an ordinary lambda. Niri bindings in `niri-bindings.nix` contain DMS IPC, while the general Niri configuration disables DMS Polkit. Workmux and Tuicr each define a Home Manager aspect and also contribute unconditionally to the shared Tmux aspect. The initrd rollback uses `btrfs subvolume list -o`, extracts paths textually, and has no trap cleanup. Hibernate documentation currently refers to `filefrag`.

## Goals / Non-Goals

**Goals:**

- Preserve public module exports and separate composition through existing aspect selection.
- Secure destructive root rollback prerequisites, device readiness, mount error policy, and regression tests in a disposable Btrfs VM.
- Ground Hibernate and diagnostic guidance in verified tool and version limits.

**Non-Goals:**

- No global optimization or claimed fix for dock audio or desktop/boot/battery performance without host measurements.
- No changes to disk geometry, swap size, blanket NoCoW/compression options, sysctls, renderer, HDMI, or audio power-saving rules.
- No live-host rollback, Hibernate, or audio experiments; caller-code changes; input/lockfile updates; or new enable/shell abstractions.

## Decisions

1. **Compose without changing exports.** Collect composition-only files under `modules/aspects/profiles/`; preserve automatic aspect exports and public names, classes, and subprofiles. Keep the DMS, Helix, and Tmux file families within their respective feature directories; verify relative imports and assets during moves. Retain small standalone features and Impermanence collector directories. `[N]`/`[Nn]` may be documented; `I` is not a module-class marker. Rather than making general Niri aspects depend on DMS, place the DMS-specific IPC contribution in the DMS integration path. Keep Niri Polkit disabled at all times; determine during apply whether an override is needed in the DMS NixOS context by checking existing module options, not by inventing option paths.

2. **Derive optionality from existing selection.** Existing `programs.dank-material-shell.enable` indicates DMS selection. Integration guards must also allow evaluation when the DMS option is undeclared. Keep imports static; do not treat a `configFile` heuristic as a guaranteed API. Workmux/Tuicr retain their tool aspects; each Tmux contribution activates only when the tool is selected and Tmux context is available, using missing-option guards rather than a new enable framework. Existing broad profiles must continue to work unchanged.

3. **Preserve module semantics in the wrapper.** `wrapMods` should mirror named module-argument metadata so additional arguments such as `_module.args` are not lost through the lambda. Nixpkgs `lib.mirrorFunctionArgs` and `lib.setDefaultModuleLocation` are minimal candidates; verify their exact signatures and availability against the locked `lib` during apply. Keep shallow `//` precedence intentionally: consumer values, including `self`, win, and library values fill only missing inputs. Add no flake input.

4. **Make rollback fail closed and recursive.** Verify the device, mount, `@root`, and `@root-blank` before changing `@root`. Remove nested subvolumes using a path-safe child-before-parent algorithm; do not use `cut` or whitespace splitting. Keep siblings such as `@persist`, `@nix`, `@log`, and `@swap` outside the target set. A trap cleans up the temporary mount even on failure. The initrd unit waits for `cryptroot` in the standard encrypted layout, or for the labeled device in the plain layout; rollback runs before `sysroot.mount`, and errors block the root mount. This is intentionally fail-closed and changes behavior; document a recovery path. Official subvolume documentation states that `list -o` is not recursive; do not use `delete -R` unless support in the locked `btrfs-progs` version is verified. Run regression tests in a disposable Btrfs VM; shell mocks alone are insufficient.

5. **Separate Hibernate offset from resume target.** Replace the `filefrag` reference with `btrfs inspect-internal map-swapfile -r /swap/swapfile`; the offset remains an actual property of the provisioned swapfile. Configure the resume backing device separately; zram is not a persistent resume target. Check swapfile flags, preallocation, and compression against the Disko-generated source and, if needed, a disposable image. `@swap` mount options do not prove that a filesystem-wide option was excluded on the first mount.

6. **Keep diagnosis and caller migration separate.** The diagnostic guide records sink/card/profile/port/default before and after hotplug or resume and distinguishes USB audio from HDMI/DP. For reproducible sluggishness, collect `powerprofilesctl get`, `systemd-analyze critical-chain`, and CPU/GPU/I/O/thermal measurements. Do not read or write live host logs; redact private values. Existing `.local/state/wireplumber` persistence and `thermald` activation, along with Nixpkgs/PipeWire revisions, are hypotheses or version differences, not proven causes. WirePlumber 0.5.18 documentation does not automatically apply to locked version 0.5.17. Audio/performance status may remain unresolved after implementation due to missing host data. The external caller `/home/denis/projects/dotnix` remains outside this change's scope; its pin `c30726e7…` differs from library HEAD `ed56662a…`. Document the required host namespace/DMS/greeter/Devtools/ISO/repository migration as a separately approved accompanying step, not as an executable task here.

### Referenzen

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

1. Make file moves and optional-integration changes in small, independently verifiable blocks; evaluate existing public names and profiles in the consumer fixture.
2. Approve rollback only after prerequisites, mount trap, and VM regressions are in place; failure cases must block `sysroot.mount` fail-closed.
3. After the structure, composition, rollback, and test milestone is complete, conduct exactly one independent full review and address its findings.
4. Run heavy builds once at the milestone gate; then verify `nix fmt` produces no diff, `nix flake check` does not write the lockfile, and the existing consumer fixture passes.
5. Perform external caller migration only after separate approval. Later, diagnose the host using redacted measurements; document status as unresolved if measurements are unavailable.

## Open Questions

No open planning decisions. Device/option details and locked-tool support are concrete apply-time checks, not deferrals of safety requirements.
