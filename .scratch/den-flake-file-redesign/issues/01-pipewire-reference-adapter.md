# 01: Use PipeWire as the complete reference through the new library entry point

**What to build:** Make PipeWire usable as the first complete reference through the new native role catalog and the normal adapter in a consumer composition. The adapter registers Den, the `dotnix` namespace, and library contracts such as the popup Quirk and suitable Persistence class metadata, but activates no programs, services, Home Manager configuration, or Persistence. The namespace alone registers no Quirks; optional development tools remain separate. A host-only selection remains valid without Home Manager.

**Blocked by:** None (can start immediately).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] PipeWire is available through the public host and home selections; Home PipeWire transitively brings in neither NixOS behavior, account behavior, nor a host provider.
- [x] An explicit integrated Home Manager bridge preserves separate roles. A host-only configuration can evaluate through the same library entry point without Home Manager.
- [x] Importing the namespace alone remains inert and registers no Quirk; the normal adapter registers required global contracts without activating feature behavior.
- [x] The public consumer entry point closes the known user-only host activation (#694): selected user and host targets affect only their selections; an unrelated user and host remain unchanged.
- [x] An ordinary native consumer override works. The reference demonstrates input ownership without a dedicated external PipeWire input, using a consumer fixture and the library-captured Impermanence dependency; existing Persistence contributions remain available.
- [x] One necessary regression is connected to an appropriate existing check path. No new variant or declaration-mirror matrix.

## Comments

### Implementation evidence

- RED: `nix eval --impure --json --file tests/broad-compositions.nix` failed with `Broad composition fixture failed: pipewireUserOnlySelectionDoesNotEnableHost` against the original flat PipeWire selection.
- GREEN: the same command passed after switching the consumer to `dotnix.home.pipewire`; it returned all assertions true, including no host leak, isolated host/user selections, an ordinary `mkForce` override, host-only use without Home Manager, and selected WirePlumber persistence.
- The consumer fixture imports exported `flakeModules.default`; it removes `impermanence` from consumer root inputs while selecting the library-owned persistence feature. No PipeWire input or lock change.
- `nix eval --impure --file tests/headless-composition.nix` passed. `nix eval --impure --json --file tests/niri-dms.nix` exited 0 with all assertions true.
- `nix eval --no-write-lock-file --json .#flakeModules --apply builtins.attrNames` returned `["default","devTools"]`.
- `nix flake check --no-build --no-write-lock-file` passed in the assigned worktree; this evaluated checks but did not build.
- `nix fmt -- --ci <changed Nix paths>` passed. `flake.lock` hash remains `6f9c06db3f8a4211e10a99998c20c27c3307d8a4eedd9a69d3fed9b0af2f0e47`.
- No build/runtime/activation or disk-operation evidence. The coordinator reported integration-worktree baseline `path 'a3xx41wf72v2d0y2qcsgnszgh52zji1v-modules' is not valid`; the same check passed in this assigned worktree, so the issue was not reproduced or worked around here. The ticket remains claimed pending review/integration.

### Follow-up: capture library provider

- RED: the supplied minimal consumer with `library = source` and no consumer `dotnix` failed with `attribute 'dotnix' missing` at `modules/integration/default.nix:3`; the same expression with `dotnix = source` returned PipeWire/Home Manager false.
- GREEN: the captured provider factory now returns the adapter with library source bound by producer `inputs.self`; the same consumer-key fixture returns `{"homeManager":false,"pipewire":false}`. The existing `adapterOnly` regression removes `dotnix`, adds `library = source`, and all broad-compositions assertions pass.
- `nix eval --impure --file tests/headless-composition.nix`, `nix flake check --no-build --no-write-lock-file`, and `nix fmt -- --ci` on changed Nix files passed. No input or lock changes. The ticket stays claimed pending focused review/integration.

### Integration acceptance

- Independent focused review `90f98978-a205-43b`: approved, no open findings. Approved source SHA: `a96bfe2b6dba6dcbe97f0719e302d972271ce5a8`; integrated without conflicts in merge `8ec0bf34a9ac6b1b05aaf196428cdb024647fb38`.
- In the integration worktree, `nix eval --impure --json --file tests/broad-compositions.nix` passed: all 34 values true. `nix flake check --no-build --no-write-lock-file` passed (exit 0); the earlier baseline store-path failure did not recur.
- The coordinator independently observed that a minimal consumer with a library alias is inert without Home Manager/PipeWire; namespace-only popup registration is false versus normal adapter true, without Home Manager/PipeWire. These focused observations were run by the coordinator, not rerun by the serial merger.
- Source `flake.nix` and `flake.lock` are unchanged against planning baseline `799093af9a49abb859b2822a9833ba01f9d19202`; lock SHA-256 remains `6f9c06db3f8a4211e10a99998c20c27c3307d8a4eedd9a69d3fed9b0af2f0e47`. The original checkout snapshot was verified unchanged (221 files).
- Evidence covers evaluation only: no build, runtime, activation, or disk operations. Implementation authorization follows the coordinator's approved execution context; all six acceptance criteria are fulfilled, and the ticket was resolved after successful integration evaluation.
