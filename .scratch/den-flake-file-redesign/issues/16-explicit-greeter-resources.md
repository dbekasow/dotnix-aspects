# 16: Configure greeters without deriving a user home

**What to build:** Use DMS and Noctalia greeters as host-wide capabilities with explicitly provided configuration homes and assets. Greeter resources do not depend on account alphabetical order or a user's home shell selection.

**Blocked by:** [14: Separate Niri support from user configuration](14-niri-scope-separation.md).
**Status:** claimed
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] Greeter configuration is an explicit host selection; required configuration homes and assets come from consumer resources, not from an automatically selected user home.
- [ ] The greeter does not depend on the first alphabetical account and remains independent of each account's home shell or desktop runtime.
- [ ] DMS and Noctalia greeters retain their existing declarative configuration and Persistence contributions.
- [ ] Changing one greeter target changes no unrelated homes; provide resources through native options instead of repository-path assumptions.
