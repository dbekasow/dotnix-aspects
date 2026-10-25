# 06: Use Secrets and authentication with explicit consumer resources

**What to build:** Make existing secrets and authentication capabilities individually consumable with clear role and resource ownership. This includes Age/Age-Rekey, optional password generation, certificates, SSH, GnuPG/GPG Agent, rbw, and YubiKey and YubiKey-PAM support.

**Blocked by:** [05: Configure accounts without hidden shell or vault choices](05-account-selection.md).
**Status:** claimed
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] Consumers provide required resources through native options; library features do not guess repository paths or cross host, account, or home boundaries implicitly.
- [ ] Host authentication and user identity remain independently selectable; a target can select either without pulling in the other.
- [ ] Age/Age-Rekey, password generation, certificates, SSH, GnuPG/GPG Agent, rbw, YubiKey, and YubiKey-PAM retain their existing optional capabilities.
- [ ] GUI pinentry integration belongs to the appropriate feature owner and is not forced through hidden profile overrides.
- [ ] Checks use non-secret fixture values; no real secrets or credentials are provisioned, and no new resource registry is added.
- [ ] Add no artificial dependency on generator tooling or desktop support; shell-specific integrations remain with their owners.
