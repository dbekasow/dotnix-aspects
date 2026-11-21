# 05: Select the desktop shell once per host

**What to build:** Make one host selection of Noctalia or DMS supply that shell to every integrated home on that host. Remove the redundant selection from consumer examples.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] Replace the obsolete split-shell Alice/Bob expectation: both integrated homes receive the selected runtime without enabling a duplicate service; contradictory shell choices produce a clear diagnostic.
- [ ] Other hosts and standalone homes remain independent. Personal applications and greeter selection do not propagate. Reuse existing service/conflict checks; no shell-by-person matrix.
- [ ] Reconcile the older coherent-session ticket's explicit host/home selection wording with ADR 0008 without changing its login or recovery requirements.

[Review decisions and test budget](../map.md)
