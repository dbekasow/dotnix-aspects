# 04: Use the host foundation without Home Manager

**What to build:** Provide host-side system capabilities as individually selectable consumer choices, including boot, Disko, networking, Bluetooth, power, performance, geolocation, journald, locale, security, system packages, and the existing Nix-LD host capability. Host-only configuration must remain valid without Home Manager; existing home-side facets of shared Nix tools remain explicitly available.

**Blocked by:** [02: Reorganize feature ownership and discovery around the confirmed criterion](02-feature-ownership-discovery.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] `boot`, `boot-systemd`, `disko`, `network`, `network-wifi`, `bluetooth`, `power`, `performance`, `geolocation`, `journald`, and `nix-ld` are selectable as explicit host capabilities.
- [x] `locale`, `security`, `system-packages`, `nix`, `nur`, and `nh` remain individually consumable; native substituter and key defaults belong to the Nix capability, and existing home facets of the Nix tools are preserved.
- [x] A host can evaluate its selected host capabilities without integrated Home Manager; home configuration is not activated as a hidden prerequisite.
- [x] Native options override library defaults. An unrelated host remains unchanged by a targeted host selection.
- [x] Disko remains a declarative capability; add no disk operations, boot redesign, or implicit personal system inventories. The graphical foundation belongs to ticket 14, styling to ticket 17, and Secrets/Auth to ticket 06.

## Integration evidence

Merged as `impl/den-redesign-04-host-only-foundation` (`1266ca1`) into `integration/den-flake-file-redesign` with `--no-ff`; integration HEAD after merge `9295cffa9872d5a36c636cf61fd007962c3adb45`.

Verified in the integration worktree:

- `nix eval --impure --json --file tests/broad-compositions.nix` — 40/40 assertions `true`.
- `nix eval --impure --file tests/headless-composition.nix` — `"headless and workstation composition checks passed"`.
- `nix flake check --no-build --no-write-lock-file` — `all checks passed!`.
- `typos --force-exclude --format brief --hidden .` — exit 0, no findings.
- `nix fmt -- --ci` — formatted 220 files, 0 changed; `git status --porcelain` empty afterwards.
- `git diff 5fce5ca..HEAD -- flake.nix flake.lock` — empty; `sha256sum flake.lock` equals the recorded source lock hash.

Reviewer finding on the substituter seam: the community cache was split into its own opt-in `dotnix.host.nix-community-cache` capability, which contributes only `extra-substituters` / `extra-trusted-public-keys`. An explicit canonical override yields exactly the consumer's substituters with no community URL or key present anywhere; selecting the community capability adds only the extra entries and still does not win over canonical overrides. The residual `https://cache.nixos.org/` entry comes from nixpkgs pinned defaults (`mkAfter`), not from library code.

Scope of this evidence is evaluation only: broad and headless composition evaluation, flake evaluation without builds, formatting and typo checks. No full system build, no runtime behaviour, and no disk operations were exercised. The headless-security check derivation was built earlier on the worker branch and is not a system build.
