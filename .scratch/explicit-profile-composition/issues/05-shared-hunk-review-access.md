# 05: Replace Tuicr with shared Hunk review access

**What to build:** Make Hunk the reusable general review tool, reachable directly and through the same selected review menu in Tmux and Herdr, without opting a home into another multiplexer or an agent workflow.

**Blocked by:** [01: Restore executable consumer contract checks](01-restore-consumer-contract-checks.md).

**Status:** resolved

**Spec:** [Canonical specification](../spec.md).

**Spec coverage:** User stories 11, 14–21, 27, and the review-tool migration part of 37.

**Authorization:** Publication is not implementation approval. Obtain a separate execution instruction before changing production code or tests.

**Test proportionality:** Acceptance criteria and user stories are contracts, not instructions to create one test each. Reuse existing fixtures and assertions; add only a minimal behavior check for a named regression risk that is not already covered, and state that gap briefly in the result. No duplicate coverage matrix, whole-configuration snapshots, source-text assertions, mocks of the Nix/Den module system, or additional UI/VM/runtime test layers. If those heavier techniques seem necessary, request separate approval rather than expanding this ticket. Preserve existing meaningful checks.

Check selected and unselected homes plus the two actual menu renderers at the existing consumer seam. Reuse role-isolation coverage, avoid Cartesian combinations of shells, tools, and multiplexers, and do not create an interactive terminal driver.

- [x] Add the public home.hunk feature for modem-dev Hunk, sourced from the existing numtide/llm-agents.nix package provider using the established package selection conventions. Do not choose direct nixpkgs Hunk, add a new input, or update a pin.
- [x] Development selects Hunk instead of Tuicr. Retire the Tuicr feature, its managed configuration, and its old review binding without aliases; keep all other development members unless independently changed by ticket 04.
- [x] Direct Hunk selection works independently of development, Tmux, or Herdr and does not enable either multiplexer, an agent, or host overlay/cache behavior.
- [x] The direct Fish abbreviation cr invokes the selected Hunk executable. Use Hunk defaults; do not translate Tuicr-specific typed comments, theme, identity, or export configuration, and do not migrate or delete occupant-created review data.
- [x] Add exactly one selected Hunk entry with dispatch key r to the existing shared popup mechanism. Tmux and Herdr expose it through Prefix+o, then r, using the selected executable and existing popup geometry conventions.
- [x] Only the home selecting Hunk, directly or through development, receives its package and entry. Mere input or overlay package availability does not activate the feature or expose its menu item.
- [x] Remove the dedicated Tmux Prefix+r review shortcut. Do not add a separate Herdr shortcut, another popup framework, or new public enabling options.
- [x] Extend the regular consumer gate to force and inspect generated Tmux and Herdr configuration, direct home selection, selected package/abbreviation, old-binding absence, dispatch-key uniqueness, and selected versus unselected homes on the same host.
- [x] Update the review-tool, profile, and popup guidance in this slice. Keep unrelated application settings and the current native Git/RBW identity contract.
- [x] Formatter, full flake checks, affected consumer checks, and template derivation evaluation pass. Report package availability or configuration evaluation separately from a completed application/system build.

Ticket 04 is not a blocker: removing implicit agent selections and replacing the review tool are independent changes. Coordinate their shared development-profile edits without using temporary compatibility selectors or expanding this ticket into agent automation.

## Answer

Implemented on `work/epc-05` at `2079763`, integrated in `325e051`. Hunk uses the existing numtide provider and selected executable for Fish `cr` and the shared `r` popup entry. Development replaces Tuicr; its feature, managed configuration and dedicated Tmux binding are retired without touching occupant data. Selected/unselected-home tests force actual Tmux/Herdr renderers and a per-home package override.

TDD red/green evidence, formatter, full built flake check, focused review/headless/Niri checks, conflict diagnostic and unchanged copied-template derivation evaluation passed. Exact commands and logs: `/tmp/epc-05-evidence/`. Package availability/evaluation is not an application or system closure build; the real template build remains ticket 06.

The coordinator inspected the production/test diffs and reran `nix fmt` plus `nix flake check --no-write-lock-file --accept-flake-config` on the combined 02/04/05 integration at `325e051` (both exit 0; `/tmp/epc-mid-format.log`, `/tmp/epc-mid-check.log`). Conflicting shared profile, check-registration and guidance edits were combined without restoring implicit selections. Runtime, activation and incompatible non-host systems are not covered.
