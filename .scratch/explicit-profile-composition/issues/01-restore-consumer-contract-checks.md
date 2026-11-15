# 01: Restore executable consumer contract checks

**What to build:** Make the existing consumer behavior checks trustworthy again and run them through the normal flake check gate, so later profile changes start from an executable, green behavioral baseline rather than formatting-only checks.

**Blocked by:** None (can start immediately).

**Status:** claimed

**Spec:** [Canonical specification](../spec.md).

**Spec coverage:** User story 33 and the known-baseline testing requirements.

**Authorization:** Publication is not implementation approval. Obtain a separate execution instruction before changing production code or tests.

**Test proportionality:** Acceptance criteria and user stories are contracts, not instructions to create one test each. Reuse existing fixtures and assertions; add only a minimal behavior check for a named regression risk that is not already covered, and state that gap briefly in the result. No duplicate coverage matrix, whole-configuration snapshots, source-text assertions, mocks of the Nix/Den module system, or additional UI/VM/runtime test layers. If those heavier techniques seem necessary, request separate approval rather than expanding this ticket. Preserve existing meaningful checks.

This is baseline repair and check wiring, not a reason to author another set of behavioral scenarios or a generic test runner.

- [ ] Correct the five obsolete Niri finalConfig accesses to the pinned upstream's finalConfigFile interface without weakening the existing expectations. The original Niri/DMS fixture completes all 48 baseline assertions.
- [ ] Run the existing relevant headless, headless-security, and Niri/DMS consumer contracts through the regular flake check gate, not only manually invoked scripts. Preserve formatter, generated-flake consistency, and existing pre-commit checks.
- [ ] Use the shipped default consumer adapter and final NixOS/Home Manager outputs as the common testing seam. Keep any adaptation small and reusable; do not introduce a test framework or restore the removed broad suite.
- [ ] Show the existing Niri regression failing before its correction and passing through the regular check gate afterwards. Use that real failure as the red/green evidence; do not invent fault-injection machinery or mutate production behavior to prove the test runner.
- [ ] The full flake check with checks built and the existing formatter pass. Report behavioral evaluation, check builds, and any runtime execution separately.
- [ ] Document how subsequent slices extend the same focused check gate, with no input or lockfile changes.

This ticket repairs and connects the existing baseline; it does not assert that the future profile, Hunk, or template contracts are already implemented. Subsequent slices own their new behavior tests. Do not modify the separate live consumer, activate a system, or absorb the independent loading redesign.
