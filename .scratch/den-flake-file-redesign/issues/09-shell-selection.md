# 09: Select shells and login shells independently

**What to build:** Separate Fish and Nushell so host prerequisites, account login shells, and home configuration remain independently selectable. Related shell UX such as Atuin, Carapace, Starship, FZF, Skim, and Zoxide remains independently combinable.

**Blocked by:** [05: Configure accounts without hidden shell or vault choices](05-account-selection.md).
**Status:** claimed
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] Fish and Nushell home configurations can be activated without automatically selecting them as account login shells; set a login shell only for selected accounts.
- [ ] Required host packages/prerequisites are separate from user and home selections; host-side activation does not affect unrelated accounts.
- [ ] Atuin, Carapace, Starship, FZF, Skim, and Zoxide retain their existing selectable capabilities and are not activated wholesale by the base shell.
- [ ] Completions, prompt, and navigation behavior remain usable for existing shell combinations; native options override defaults.
- [ ] Shell selection requires neither popup/multiplexer selection nor Secrets/vault conventions.
