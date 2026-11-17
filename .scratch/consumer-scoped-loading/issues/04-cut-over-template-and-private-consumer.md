# 04: Cut over the template and private Consumer

**What to build:** Replace the public Consumer entry point directly. The published Consumer template and the private `dotnix` Consumer use the same source-only interface and explicit import groups, without a parallel legacy entry point.

**Blocked by:** [02: Opt into Desktop in a mixed Consumer](02-desktop-in-mixed-consumer.md); [03: Opt into DevTools without Desktop](03-devtools-without-desktop.md).

**Status:** resolved

- [x] The published Consumer template instantiates and its existing host/home configuration evaluates through the new interface. Update the current Consumer guidance and retire the old adapter without removing the Aspect library's standalone development flake.
- [x] The private Consumer generates and locks one flake. Evaluate `luffy` with Noctalia (including its existing greeter) and Denis's `terminal-herdr` home profile, alongside the `roger` ISO output and DevTools. Desktop features do not spill over to the headless target; `roger` keeps its existing terminal choice. Do not select `denis-repos` on `luffy`; verify that exactly one primary email account is configured and that Git and RBW resolve their identities without changing an existing explicit override.
- [x] Preserve the Consumers' intended host, home, and account selections, resources, and state versions; translate existing aspect references only as required. Inspect and preserve the private Consumer's local lockfile changes and do not upgrade unrelated inputs.
- [x] Run the existing formatting and flake checks after integration. Reuse the earlier Base, Desktop and DevTools evidence rather than adding another matrix. Report what evaluated and what built separately; do not activate any system.

## Answer

The legacy adapter is retired. The public template uses the source-only group directories and the standalone flake has its own entry. Template commit `784faed` and the private companion commit `3cb8495` lock the same source anchor `e03e3e0`. The private migration preserved all existing non-source pins and did not modify the live private checkout or its original lock edits.

The published template instantiated and its writer left its flake and lock unchanged. With a local Git override to the pinned source, the template system, `luffy` system and Home Manager, `roger` ISO, and DevTools outputs evaluated. `luffy` selects Noctalia, its existing greeter and Herdr, without selecting `denis-repos`; exactly one primary email account is configured, and both Git and RBW retain their explicit identity overrides. `roger` remains headless. No system or ISO closure was built or activated, and no vault command was run.

Both review axes were addressed: the CI template build uses the PR’s standalone dependency lock, the migration instructions cover all former follows, source scope names were corrected, and two GUI packages were moved out of Base into explicit Desktop selections. The existing Consumer generation test passed its Base, DevTools, and Desktop lifecycle, then standalone formatting and the built x86_64-linux flake checks passed. Cold fetching of the Consumer source pins still requires publishing the exact public source anchor; verification did not push either branch.
