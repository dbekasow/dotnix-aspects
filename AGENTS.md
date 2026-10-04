# Repository Guide

## Scope and mental model

This repository is a reusable dendritic NixOS/Home Manager aspect library built on
flake-parts. It is not the consumer's host configuration. Every `.nix` file under `modules/` is a flake-parts module; root and template
`flake.nix` files are flake entry points. `modules/expose.nix` defines the public entry points.

Defining an aspect under `flake.modules.<class>.<name>` registers it; that alone does
not activate it on a host. Composition happens when a consumer imports the aspect, a
tier, or a profile. In this repository's public API:

- `inputs.dotnix.flakeModule`: full factory product.
- `flakeModules.aspects`: registry and tier surface.
- `flakeModules.devTools`: development tooling.
- `nixosModules` / `homeManagerModules`: plain-module aliases.

Preserve these boundaries. Import-tree discovery is not host activation.

## Where changes belong

- Put reusable behavior beside its feature under `modules/aspects/`. Follow existing
  thematic groups and feature folders; groups are shelves, not a required mirror of
  tiers.
- Put composition modules with profiles under `modules/aspects/profiles/`. Tiers and
  profiles assemble reusable aspects; they should not hide feature implementation.
- Keep related platform/class contributions together when that makes the feature easier
  to understand. Do not split every feature into class-specific files by rule.
- Keep each aspect self-contained: an aspect's impermanence contribution
  lives inside the aspect's own file as a sibling
  `flake.modules.<class>.impermanence` attribute (see `firefox.nix`,
  `herdr.nix`), not in a separate contributor file.
- `[Nn]` documentation markers are optional. `I` is not a module class. Use current
  neighbors and the active change plan for naming details.
- Add an option only for real per-host/per-user variation or a genuine collection
  point. Prefer existing module options and composition over speculative enable flags,
  wrappers, or abstractions.
- Keep public aspect names and classes stable unless a requested change explicitly
  migrates them. Check registry and composed consumer behavior.

## Safe changes

- Start from the named file or behavior. Trace definitions, imports, and consumers
  before editing; use README examples and existing fixtures instead of guessing.
- Make the smallest coherent change. Inspect `git status` first and preserve unrelated
  dirty work. Never revert, stage, or rewrite pre-existing changes as cleanup.
- Commit each completed, verified OpenSpec task with a conventional commit containing
  only task-owned files. Preserve unrelated changes already staged in the index; use
  path-scoped commits, not an unqualified `git commit`.
- Do not add host secrets, private keys, personal data, or default access to private
  resources. Keep secret-dependent behavior gated by the existing consumer contract.
- Do not update flake inputs or `flake.lock` without explicit approval. Avoid changing
  caller repository `/home/denis/projects/dotnix`; it is separately pinned and
  currently uses `c30726e7`.
- Never run Disko, format disks, activate/switch a live host, or perform live rollback.
  Storage and boot tests must use disposable resources. Audio or performance causes
  require measurements; do not infer or claim a cause without data.

## OpenSpec

Write all OpenSpec artifacts in English, including prose, headings, and keywords.

Current change: `openspec/changes/clarify-aspect-boundaries-and-harden-workstation/`.
The user has authorized applying this change; implement its checked-off tasks under
that request. One independent source review follows the large implementation
milestone, not individual file moves. The user separately requested a review of this
`AGENTS.md` now.

## Efficient workflow and checks

1. Read relevant modules, callers, and applicable OpenSpec tasks. Inventory definitions
   and uses before designing anything.
2. For uncertain paths or ownership, ask a Scout; for external/version-specific
   behavior, use a Researcher. Use one Worker for a coherent implementation. Do not
   spawn agents for trivial edits.
3. Keep context and cost low: inspect relevant files, prefer focused evaluation/tests,
   use direct project commands, and avoid repeating expensive builds. Report exactly
   what ran and its result.
4. Run the narrowest meaningful check first. For Nix changes, evaluate affected
   compositions and the existing consumer fixture where relevant. Final gate: `just fmt`,
   `just check` (`nix flake check`), and the consumer fixture/build from
   `.github/workflows/flake-check.yml` when exported behavior changes. Do not claim
   unrun checks.

Project commands:

- `just fmt` runs `treefmt`.
- `just check` runs `nix flake check`.
- `just update [input]` updates flake inputs; explicit approval is required.
- CI builds the template consumer's
  `nixosConfigurations.myHost.config.system.build.toplevel` against this checkout.
