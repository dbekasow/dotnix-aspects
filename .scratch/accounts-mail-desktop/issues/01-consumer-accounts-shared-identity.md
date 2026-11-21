# 01: Demonstrate consumer-owned accounts and shared identity

Status: ready-for-agent
Type: task

**Source:** [Canonical specification](../spec.md). Acceptance scenarios: A1, A2.

**What to build:** Provide a coherent consumer reference that connects an explicitly selected OS account and home to one primary email identity. Git and rbw inherit that identity without redundant entry, while consumers retain independent overrides and may use an identity-only account without operating mail services.

**Blocked by:** None (can start immediately after separate execution approval).

## Acceptance criteria

- [ ] The reference demonstrates the complete account/home/identity selection path, with no occupant-specific configuration in the reusable library.
- [ ] Only the explicitly selected account and configuration target receive the home configuration; a second account or target does not inherit it accidentally.
- [ ] Changing the primary account's name/address changes the existing Git/rbw defaults; explicit native overrides remain effective.
- [ ] An identity-only primary account evaluates without requiring enabled mail clients, synchronization, or mail-server credentials.
- [ ] Focused evaluation checks cover selection isolation, shared defaults, explicit overrides, and the identity-only case; reference guidance explains the behavior.

## Boundaries and execution approval

Use the existing identity model and native options. Do not invent a separate identity registry, alter mail-client authentication, or reintroduce consumer selections into shared profiles.

Publication and triage readiness do not authorize execution or activation. An
unresolved or negative prerequisite proof does not unblock implementation. If a
required user decision, test environment, hardware, or approval is missing,
report that prerequisite rather than claiming completion.

## Comments
