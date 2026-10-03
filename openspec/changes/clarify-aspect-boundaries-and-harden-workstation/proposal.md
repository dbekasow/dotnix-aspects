# Proposal

## Why

The library mixes feature families, profiles, and implementation fragments; selecting Niri or Tmux also activates integrations for tools that were not selected. The user reports monitor audio with no sound or the wrong output through a USB-C/Thunderbolt dock, as well as sluggish desktop, boot/resume, and battery performance. In parallel, Btrfs rollback and the Hibernate contract require verified safety corrections rather than speculative optimization. Current aspect settings also include redundant profile-owned option payloads, and the workstation composition lacks a reusable headless path for VPS hosts.

## What Changes

- Reorganize composition and feature files within `modules/aspects/`. Public API changes are allowed where removing redundant custom API has a net simplification benefit. Target feature-owned settings, typed collectors only where a real collection point exists, and no new enable framework. Keep necessary host factory, hostname registry key, `vaultReady` public-key gate, disk variants, and Tmux/Git collectors.
- Make DMS-specific Niri bindings conditional on DMS selection. Workmux/Tuicr integrations must not activate solely because Tmux is imported. Polkit ownership follows the selected shell; do not force it off unconditionally.
- Preserve export-wrapper argument metadata and error provenance without changing input precedence or caller `self`.
- Provide a reusable headless VPS composition path without inventing host identity, hardware, secrets, provider, or root disk layout. Keep generic `core` an explicit work/admin profile, not a universal server baseline.
- Protect root rollback against a missing baseline snapshot, process nested subvolumes fully in child-before-parent order, and make device dependencies and error policy explicit. **BREAKING:** A failed mandatory rollback must not silently continue booting with an old or partially modified root; document recovery.
- Correct the Hibernate contract: use `btrfs inspect-internal map-swapfile -r` for the Btrfs offset, distinguish the actual resume device, and treat zram/RAM swap separately. Do not change live hardware tuning.
- Extend focused composition and safety tests, including headless and fake-host evaluation. Test Btrfs rollback in a disposable environment. Document audio/performance diagnosis and version migration; hardware-specific tweaks require measured causes in a follow-up change.

## Capabilities

### New Capabilities

- `aspect-composition`: Aspect selection determines optional integrations and settings; exported module arguments and error provenance remain correct; the documented API describes intentional breaking changes and target composition.
- `ephemeral-root`: Safe, device-ordered Btrfs root rollback and a correct, documented Hibernate contract for the existing layout.

### Modified Capabilities

No existing specs; OpenSpec was newly initialized for this project. File moves and diagnostic documentation alone do not create additional runtime capabilities.

## Impact

Library implementation scope includes `modules/aspects/`, `modules/expose.nix`, `README.md`, and focused regression fixtures/tests. No new flake inputs or frameworks are planned. No Disko provisioning, formatting, live rollbacks, Hibernate execution, activation, or changes to secret material.

This repo-local change's `allowedEditRoots` covers only `/home/denis/projects/dotnix-aspects`; it does not grant write access to `/home/denis/projects/dotnix`. End-to-end completion also requires a separately tracked Caller migration task/session with its own explicit write scope authorizing `/home/denis/projects/dotnix`. That migration must pin the Caller to the reviewed library revision and update its lockfile as necessary; do not update unrelated flake inputs. Final overall completion requires Caller migration and its checks, not merely this library's handoff note.

The Caller is currently pinned at `c30726e7…`; the library baseline before this change is `ed56662a…`. Preserve existing dirty work. The separate Caller task covers Luffy/Roger namespace migration, retaining actual system and Home Manager state versions, DMS/greeter selection, HM DMS integration, caller-needed devTools, Roger ISO, user repositories, the correct library pin, and a reviewed lock diff. Acceptance includes Luffy toplevel evaluation/build and Roger ISO evaluation/build if retained. Preserve unrelated lock changes, and do not activate a live host.

Do not invent VPS identity, hardware, secrets, provider, or root disk layout. The reusable headless path must leave bootstrap root and bootloader provisioning to the caller/fixture.

Conduct one independent source review only after library and Caller implementation work reaches the milestone. Do not review each file move separately.
