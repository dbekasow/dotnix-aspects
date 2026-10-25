# 05: Configure accounts without hidden shell or vault choices

**What to build:** Provide consumer-owned account selections so only explicitly selected accounts are affected and account foundations remain independent of home selections. Ordinary native account options and optional integrated Home Manager use remain possible; host-only accounts remain valid.

**Blocked by:** [02: Reorganize feature ownership and discovery around the confirmed criterion](02-feature-ownership-discovery.md).
**Status:** claimed
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] The consumer owns the account inventory and account selections; a selection affects only the explicitly named account.
- [ ] Account foundations require neither blanket `host.users` privileges nor a default shell, vault conventions, or a password generator as prerequisites.
- [ ] Account selection works regardless of whether Home Manager is selected for that account; integrated Home Manager use remains explicit and optional.
- [ ] Native options remain overridable, and an unrelated person on the same host remains unchanged.
- [ ] Password recipes and Secrets/Auth belong to ticket 06; the Fish login shell belongs to ticket 09. Neither is activated implicitly by account foundations.
