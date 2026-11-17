# 04: Cut over the template and private Consumer

**What to build:** Replace the public Consumer entry point directly. The published Consumer template and the private `dotnix` Consumer use the same source-only interface and explicit import groups, without a parallel legacy entry point.

**Blocked by:** [02: Opt into Desktop in a mixed Consumer](02-desktop-in-mixed-consumer.md); [03: Opt into DevTools without Desktop](03-devtools-without-desktop.md).

**Status:** ready-for-agent

- [ ] The published Consumer template instantiates and its existing host/home configuration evaluates through the new interface. Update the current Consumer guidance and retire the old adapter without removing the Aspect library's standalone development flake.
- [ ] The private Consumer generates and locks one flake. Evaluate `luffy` with Noctalia (including its existing greeter) and Denis's `terminal-herdr` home profile, alongside the `roger` ISO output and DevTools. Desktop features do not spill over to the headless target; `roger` keeps its existing terminal choice.
- [ ] Preserve the Consumers' intended host, home, and account selections, resources, and state versions; translate existing aspect references only as required. Inspect and preserve the private Consumer's local lockfile changes and do not upgrade unrelated inputs.
- [ ] Run the existing formatting and flake checks after integration. Reuse the earlier Base, Desktop and DevTools evidence rather than adding another matrix. Report what evaluated and what built separately; do not activate any system.
