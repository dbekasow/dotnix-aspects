# Proposal

## Why

The library mixes feature families, profiles, and implementation fragments; selecting Niri or Tmux also activates integrations for tools that were not selected. The user reports monitor audio with no sound or the wrong output through a USB-C/Thunderbolt dock, as well as sluggish desktop, boot/resume, and battery performance. In parallel, Btrfs rollback and the Hibernate contract require verified safety corrections rather than speculative optimization.

## What Changes

- Move composition modules within `modules/aspects/` under `profiles/` and group the DMS, Helix, and Tmux families spatially. Preserve public aspect names, existing subprofiles, and module classes; small feature files and Impermanence collector directories remain valid. Context markers such as `[Nn]` remain optional; `I` is not a module-class marker.
- Bind DMS-specific Niri bindings and Polkit assumptions to actual DMS selection. Workmux/Tuicr integrations must not activate solely because Tmux is imported. Do not add a new enable framework.
- Preserve export-wrapper argument metadata and error provenance without changing input precedence or caller `self`.
- Protect root rollback against a missing baseline snapshot, process nested subvolumes fully in child-before-parent order, and make device dependencies and error policy explicit. **BREAKING:** A failed mandatory rollback must not silently continue booting with an old or partially modified root; document recovery.
- Correct the Hibernate contract: use `btrfs inspect-internal map-swapfile -r` for the Btrfs offset, distinguish the actual resume device, and treat zram/RAM swap separately. Make no unverified changes to compression, swap sizing, sysctls, or audio power saving.
- Extend the existing consumer fixture for partial compositions and alternative shell selection; test Btrfs rollback in a disposable environment. Document audio/performance diagnosis and version migration; make hardware-specific tweaks only when a cause is demonstrated in a follow-up change.

## Capabilities

### New Capabilities

- `aspect-composition`: Selected aspects determine which optional integrations are active; the export wrapper preserves the module-argument and input contract.
- `ephemeral-root`: Safe, device-ordered Btrfs root rollback and a correct, documented Hibernate contract for the existing layout.

### Modified Capabilities

No existing specs; OpenSpec was newly initialized for this project. File moves and diagnostic documentation alone do not create additional runtime capabilities.

## Impact

Affected areas are `modules/aspects/`, `modules/expose.nix`, `README.md`, the existing consumer CI, and small regression tests. No new flake inputs, frameworks, or lockfile updates are planned. No Disko provisioning, formatting, live rollbacks, Hibernate execution, activation, or changes to secret material.

The external caller `/home/denis/projects/dotnix` remains pinned at `c30726e7…`, while the library under investigation is at `ed56662a…`. A separate caller migration must address the host namespace, explicit shell/greeter selection, Devtools, Roger's former ISO output, and personal repositories under `homeManager.denis`. This repository-local change documents that accompanying step but does not authorize source-code or input changes there. Existing dirty files in both repositories remain untouched.

Implementation uses a low-cost, tightly briefed worker, with automated checks for each work block. Conduct one independent review only after the major implementation milestone covering structure, composition, and rollback safety; do not review each file move separately.
