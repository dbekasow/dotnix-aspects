# 13: Select agent tools and Handy independently

**What to build:** Make agent tools and Handy consumable as independent feature selections. Library-owned inputs and required unfree/overlay prerequisites remain explicitly assigned to the responsible feature and consumer.

**Blocked by:** [02: Reorganize feature ownership and discovery around the confirmed criterion](02-feature-ownership-discovery.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] LLM agents, AI tools, Workmux, Repomix, Tuicr, and Handy retain their existing individually selectable capabilities.
- [x] Required inputs are captured by the feature; unfree and overlay prerequisites are explicit and are not hidden by a global fixture overlay.
- [x] Handy remains exclusively owned by this ticket, not duplicated as a desktop application integration from ticket 18; its desktop integration remains locally selectable and does not automatically start a backend service.
- [x] A standalone selection requires no implicit host-access expansion. Static risk notes are not presented as verified runtime failures or as new permission claims.
- [x] Preserve existing native options and feature boundaries; do not replace the absence of a broad agent matrix with blanket individual tests.

## Comments

### Integration acceptance

- Independent focused review `b2084e71-8dcc-4d0`: approved, no findings.
- Defect and fix: the broad fixture injected NUR, llm-agents and Niri overlays globally, which masked a real public-consumer failure. A focused overlay-free consumer evaluation reproduced `undefined variable 'llm-agents'` while selecting Handy. `features/ai-tools.nix` and `features/handy.nix` now resolve `let packages = pkgs.llm-agents or inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};` and take every package from that set instead of an ambient overlay attribute.
- Deterministic package precedence: a consumer-provided `pkgs.llm-agents` wins; otherwise the library-captured `inputs.llm-agents` supplies the packages. This is the ordinary override precedence already used by Workmux and Tuicr, not a second registry or a compatibility alias.
- Handy service split: the desktop selection (`dotnix.handy`) keeps package, keybind and impermanence wiring and starts no backend. The former systemd unit moved to the explicit opt-in `dotnix.handy-service`; selecting the desktop feature alone no longer starts a background process.
- Docs reclassification: `docs/plans/den-flake-file-assessment.md` now states the overlay-free failure was reproduced as an evaluation failure and reclassifies the earlier Handy concern as evaluation evidence, without erasing the original finding.
- `nix eval --impure --json --file tests/broad-compositions.nix`: exit 0, 48 checks, all true, including the new `agentToolsResolveWithoutGlobalOverlay` (zero overlays, no `allowUnfree`, beads/workmux/repomix/tuicr/handy present, no `handy` systemd service) and `handyServiceRequiresExplicitSelection`.
- `nix eval --impure --file tests/headless-composition.nix` reported `headless and workstation composition checks passed`; `nix eval --impure --json --file tests/niri-dms.nix` exited 0 with all 33 assertions true.
- `nix flake check --no-build --no-write-lock-file` passed (exit 0, `all checks passed!`). `typos --force-exclude --format brief --hidden .` exited 0. `nix fmt -- --ci` reported 0 changed files and left `git status --porcelain` empty.
- Source `flake.nix` and `flake.lock` are unchanged against integration tip `73076375d84557fcf2992421f4e9d029a0526392`; lock SHA-256 remains `6f9c06db3f8a4211e10a99998c20c27c3307d8a4eedd9a69d3fed9b0af2f0e47`, equal to the captured source value. No input, follow or pin change.
- Evidence covers evaluation only: no build, activation, runtime or disk-operation proof. All five acceptance criteria are fulfilled and the ticket was resolved after successful integration evaluation. The original-checkout digest was not re-run by the merger.
