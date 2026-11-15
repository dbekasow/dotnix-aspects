# 04: Make agent tooling and Workmux explicit selections

**What to build:** Let occupants use ordinary development and terminal profiles without implicitly choosing AI tools or an agent-pane workflow, while preserving those capabilities as explicit selections and keeping Herdr/Tmux composition predictable.

**Blocked by:** [01: Restore executable consumer contract checks](01-restore-consumer-contract-checks.md).

**Status:** claimed

**Spec:** [Canonical specification](../spec.md).

**Spec coverage:** User stories 11–13, 22–25, 27, and the explicit-tool migration part of 37.

**Authorization:** Publication is not implementation approval. Obtain a separate execution instruction before changing production code or tests.

**Test proportionality:** Acceptance criteria and user stories are contracts, not instructions to create one test each. Reuse existing fixtures and assertions; add only a minimal behavior check for a named regression risk that is not already covered, and state that gap briefly in the result. No duplicate coverage matrix, whole-configuration snapshots, source-text assertions, mocks of the Nix/Den module system, or additional UI/VM/runtime test layers. If those heavier techniques seem necessary, request separate approval rather than expanding this ticket. Preserve existing meaningful checks.

Use one focused two-user composition plus the explicit-Workmux case as needed; reuse existing role-isolation assertions. Group related positive/negative observations in those fixtures rather than making a separate fixture for every tool or criterion.

- [ ] Development no longer selects home.llm-agents, home.ai-tools, or home.repomix. Their individual features remain available, including the Pi persistence contribution; do not confuse persistence-only behavior with installing an agent.
- [ ] Terminal UX no longer selects Workmux. Keep its other existing members and keep ordinary terminal composition's Tmux and Sesh selections.
- [ ] The Herdr terminal variant still reuses terminal, adds Herdr, and excludes Tmux and Sesh. Remove its Workmux exclusion because Workmux is no longer selected by the shared terminal tree.
- [ ] A Herdr-only terminal fixture receives no Workmux. A deliberately explicit Workmux selection beside terminal-herdr remains installed/configured rather than silently discarded; it does not re-enable Tmux or add a new prerequisite assertion.
- [ ] Keep existing Workmux Tmux bindings conditional. Document Tmux as the intended-workflow prerequisite without automatically enabling it, asserting it, or promising runtime success for an unsupported combination.
- [ ] Development preserves its other general toolchain behavior. Do not require the Hunk replacement to land first: ticket 05 owns the independent review-tool replacement.
- [ ] Extend the regular consumer gate to inspect effective packages and selected persistence contributions, ordinary versus Herdr terminal output, and the explicit-Workmux case.
- [ ] A two-user fixture shows Herdr exclusions do not remove another user's ordinary Tmux/Sesh selection. Relative to an equivalent control, home selections do not change account shells, extra groups, or the host's user set. Supply native fixture identities where required rather than changing the Git/RBW identity contract.
- [ ] Update current composition guidance with explicit tool selections, documented Workmux prerequisites, and the distinction between terminal-herdr and terminal plus Herdr when both multiplexers are wanted.
- [ ] Formatter, full flake checks, affected consumer checks, and template derivation evaluation pass. Do not defer this slice's tests or guidance to integration.

No individual AI/agent capability, existing package input, or occupant data is deleted by removing an implicit selection. Do not add compatibility aliases, an agent profile hierarchy, new inputs/locks, or live-consumer edits.
