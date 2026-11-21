# 01: Demonstrate consumer-owned accounts and independent tool identities

Status: ready-for-agent
Type: task

**Source:** [Canonical specification](../spec.md). Acceptance scenarios: A1, A2.

**What to build:** Provide a coherent consumer reference that shows explicit OS account and home selection alongside separate mail, Git and rbw identities. Consumers can explicitly share a value between them without the library inferring tool identities from primary mail, as decided in [ADR 0009](../../../docs/adr/0009-keep-tool-identities-independent-of-mail.md).

**Blocked by:** None (can start immediately after separate execution approval).

## Acceptance criteria

- [ ] The reference demonstrates the complete account/home/identity selection path, with no occupant-specific configuration in the reusable library.
- [ ] Only the explicitly selected account and configuration target receive the home configuration; a second account or target does not inherit it accidentally.
- [ ] Changing the primary account's name or address leaves explicitly configured Git and rbw identities unchanged unless the consumer links them to that mail account.
- [ ] Native Git and rbw identity settings work without a mail account, enabled mail clients, synchronization, or mail-server credentials.
- [ ] Focused evaluation checks cover selection isolation and independent tool identities; reference guidance explains how to reuse an address explicitly.

## Boundaries and execution approval

Use the native Home Manager options. Do not invent a separate identity registry, alter mail-client authentication, or reintroduce consumer selections into shared profiles.

Publication and triage readiness do not authorize execution or activation. An
unresolved or negative prerequisite proof does not unblock implementation. If a
required user decision, test environment, hardware, or approval is missing,
report that prerequisite rather than claiming completion.

## Comments
