# 16: Configure greeters without deriving a user home

**What to build:** Use DMS and Noctalia greeters as host-wide capabilities with explicitly provided configuration homes and assets. Greeter resources do not depend on account alphabetical order or a user's home shell selection.

**Blocked by:** [14: Separate Niri support from user configuration](14-niri-scope-separation.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] Greeter configuration is an explicit host selection; required configuration homes and assets come from consumer resources, not from an automatically selected user home.
- [x] The greeter does not depend on the first alphabetical account and remains independent of each account's home shell or desktop runtime.
- [x] DMS and Noctalia greeters retain their existing declarative configuration and Persistence contributions.
- [x] Changing one greeter target changes no unrelated homes; provide resources through native options instead of repository-path assumptions.

## Comments

### Integration verification

Merged reviewed HEAD `27ed0613949c8b2635cc2756873b5189be782eba` into integration with conflict-free merge `d7a2b50392360afe0ac5724bee6071c04d5a6fb1`. Reviewer `f66bd8d2-3063-46d` approved the feature, subsequent recipe fix `ddd57ef`, and final documentation-only reconciliation `27ed061`; all findings were resolved before integration.

DMS accepts consumer-owned resources through native `programs.dms-greeter.configHome` and `programs.dms-greeter.configFiles`. Noctalia accepts consumer settings and wallpaper assets through native `services.displayManager.noctalia-greeter.settings`. Neither greeter infers the first alphabetical account or borrows a user's home. Integration evaluations cover account renaming/home changes, Fish versus Nushell invariance, operation without Home Manager, unchanged unrelated homes, and preserved DMS `/var/lib/dms-greeter` Persistence contribution. Noctalia retains its native declarative configuration. The corrected Noctalia-switch recipe removes DMS-only `programs.dms-greeter.*` assignments, including the sample `configHome`, before setting Noctalia resources.

Actual integration gates ran serially, once, on the merged result:

- Broad compositions: **80/80 true** (`nix eval --impure --json --file tests/broad-compositions.nix`).
- Niri/DMS: **38/38 true** (`nix eval --impure --json --file tests/niri-dms.nix`).
- Headless: `headless and workstation composition checks passed` (`nix eval --impure --json --file tests/headless-composition.nix`).
- `nix flake check --no-build --no-write-lock-file`: exit 0.
- `nix fmt`, then `nix fmt -- --ci`, then `typos`: each exit 0; no formatting diff.
- Source `flake.nix` and `flake.lock` match their premerge contents. Lock SHA-256 matches the recorded source guard: `6f9c06db3f8a4211e10a99998c20c27c3307d8a4eedd9a69d3fed9b0af2f0e47`.

Evidence is evaluation-only: no system/package build or runtime validation is claimed. Gate logs are retained under `/tmp/pi-merge-16/`.
