# 06: Start and recover one coherent Niri/Noctalia session

Status: ready-for-agent
Type: task

**Source:** [Canonical specification](../spec.md). Acceptance scenarios: D1, D2.

**What to build:** Make an explicitly selected consumer session start Niri with one Noctalia shell after password authentication, and recover the shell within verified security bounds without terminating applications.

**Blocked by:** [05: Prove fail-closed Noctalia lock recovery](05-prove-fail-closed-lock-recovery.md)

## Acceptance criteria

- [ ] The authenticated greeter starts Niri/Noctalia as the default session without automatic login or a second session-selection step.
- [ ] Exactly one desktop shell owns the session; DMS and Noctalia do not run as competing shells.
- [ ] Required session services start and stop with the intended graphical session; logging out leaves no unintended session-owned services running.
- [ ] Login starts a fresh desktop rather than generally restoring previous apps/windows/workspaces.
- [ ] Apply the recovery policy proved in ticket 05: restart attempts are bounded and diagnosable, applications survive, and locked content is not exposed.
- [ ] Evaluation checks and an approved disposable-session login/logout/crash procedure demonstrate the lifecycle. Do not claim that this ticket completes the later FIDO authentication policy.

## Boundaries and execution approval

Select `host.noctalia` once for the host so its integrated homes receive that shell ([ADR 0008](../../../docs/adr/0008-one-desktop-shell-per-host.md)). Keep compositor, greeter, and personal application selections explicit and consumer-owned; do not repeat the shell selection per integrated home. Do not introduce arbitrary application autostart, broad session restoration, or activation on the user's active desktop without separate approval.

Publication and triage readiness do not authorize execution or activation. An
unresolved or negative prerequisite proof does not unblock implementation. If a
required user decision, test environment, hardware, or approval is missing,
report that prerequisite rather than claiming completion.

## Comments
