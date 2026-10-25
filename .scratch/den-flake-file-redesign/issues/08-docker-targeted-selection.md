# 08: Select Docker separately for host, account, and home

**What to build:** Offer the Docker host daemon, account settings, and user tools as separate consumer selections while preserving rootful and rootless use. Existing subuid/subgid and linger contributions must no longer be applied indiscriminately to every host account.

**Blocked by:** [05: Configure accounts without hidden shell or vault choices](05-account-selection.md), [07: Select Persistence independently from the Btrfs root reset](07-persistence-root-reset.md).
**Status:** claimed
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] The host daemon, a specifically selected account, and home-side Docker tools can be selected independently.
- [ ] Subuid/subgid and linger affect only the explicitly selected account rather than every host account indiscriminately.
- [ ] Describe actual capabilities accurately: do not claim Docker group membership or root privileges unless they are explicitly configured separately.
- [ ] Rootful and rootless capabilities remain available; rootless state/Persistence is selected deliberately, not silently activated by the daemon or a developer selection.
- [ ] Do not redesign existing runtime behavior; a Docker feature does not force a Development profile.
