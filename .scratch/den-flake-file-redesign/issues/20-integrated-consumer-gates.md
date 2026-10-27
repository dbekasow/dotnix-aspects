# 20: Accept the integrated consumer and actual project gates

**What to build:** Complete acceptance of the integrated consumer composition with host-only and multiuser selections. Evidence must distinguish actual evaluation, build, and runtime boundaries; public feature and profile selections remain usable without private consumer changes or live activation.

**Blocked by:** [15: Run DMS and Noctalia for different users](15-per-user-desktop-shells.md), [16: Configure greeters without deriving a user home](16-explicit-greeter-resources.md), [19: Offer existing profiles as optional role-pure compositions](19-role-pure-profiles.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] Integrated checks cover host-only use without Home Manager, individual feature/optional profile selections, and a multiuser composition with explicitly selected DMS, Noctalia, and greeter cases.
- [x] Actually run existing manual broad, headless, and Niri/DMS evaluations and the affected template build; add Formatter and root `flake check` as appropriate. Root `flake check` alone does not prove these manual evaluations or standalone VM checks.
- [x] Reuse the generator lifecycle from ticket 03; do not duplicate it as a second job. Connect each necessary regression once to an appropriate existing check path.
- [x] Distinguish evaluation, build, and runtime results; make no runtime claims from evaluation and perform no live activation.
- [x] Cover the full existing capability set; leave private consumer files untouched and preserve source inputs/lock pins.
- [x] Update only necessary current child-facing documentation during this implementation. Do not close or rewrite the canonical spec or parent ticket.

## Comments

### Acceptance in progress

On integration commit `32dbce3`, broad composition evaluation returned 94/94 true, Niri/DMS returned 48/48 true, headless evaluation passed, and `bash tests/niri-dms-conflict.sh` verified the conflict diagnostic. `nix flake check --no-write-lock-file --accept-flake-config` passed its two checks on x86_64-linux. The generator lifecycle evidence from ticket 03 is reused, not run as a second job. These are evaluation and check results, not runtime evidence.

A fresh template build using the consumer's unpinned current nixpkgs (`d3b13ad75cc492690728f9307e443dec9ef9a20e`) fails during evaluation because pinned impermanence reads the removed `boot.initrd.systemd.enable` option. This is a version compatibility boundary, not a source fix or a claim that current unpinned nixpkgs is supported. A diagnostic build with the library-pinned nixpkgs (`8edc0c72e3a38faf5434e40d1f19431125fe4b30`) instead reached the assertions requiring host and home rekey recipients. The template intentionally supplies no master identities.

For the pinned acceptance build, a disposable consumer has both native `age.rekey.masterIdentities` populated with an explicit public recipient from the agenix-rekey option example and the non-existent string identity path `/nonexistent/dotnix-test-identity`. No private identity is generated, copied into the store, or used. The initial build timed out while fetching and building dependencies. A subsequent build completed successfully from the replacement worktree with the same disposable consumer and pinned nixpkgs override. Logs: `/tmp/dotnix20-build.log`, `/tmp/dotnix20-trace.log`, `/tmp/dotnix20-pinned-build.log`, and `/tmp/dotnix20-pinned-resources-build.log`. No activation or runtime test was performed.

The successful build command was:

```sh
d=$(cat /tmp/dotnix20-template-path)/fixture
nix build "$d#nixosConfigurations.myHost.config.system.build.toplevel" \
  --override-input dotnix "path:$PWD" \
  --override-input nixpkgs github:NixOS/nixpkgs/8edc0c72e3a38faf5434e40d1f19431125fe4b30 \
  --accept-flake-config --no-write-lock-file --no-link
```

The command ran in `/home/denis/projects/dotnix-aspects-acceptance`, exited 0, and built the NixOS toplevel; its log is `/tmp/dotnix20-acceptance-build.log`. The output `/nix/store/ljfxg5vij7xwasawc0vwwn207w9gpqhy-nixos-system-myHost-26.11.20261008.8edc0c7` was independently confirmed with `nix path-info`. The fixture's other inputs were resolved by its own disposable lock. This build does not activate the system, exercise runtime behavior, or establish support for the newer unpinned nixpkgs. Source inputs and the library lock remain unchanged.
