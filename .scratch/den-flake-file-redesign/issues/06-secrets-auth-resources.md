# 06: Use Secrets and authentication with explicit consumer resources

**What to build:** Make existing secrets and authentication capabilities individually consumable with clear role and resource ownership. This includes Age/Age-Rekey, optional password generation, certificates, SSH, GnuPG/GPG Agent, rbw, and YubiKey and YubiKey-PAM support.

**Blocked by:** [05: Configure accounts without hidden shell or vault choices](05-account-selection.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] Consumers provide required resources through native options; library features do not guess repository paths or cross host, account, or home boundaries implicitly.
- [x] Host authentication and user identity remain independently selectable; a target can select either without pulling in the other.
- [x] Age/Age-Rekey, password generation, certificates, SSH, GnuPG/GPG Agent, rbw, YubiKey, and YubiKey-PAM retain their existing optional capabilities.
- [x] GUI pinentry integration belongs to the appropriate feature owner and is not forced through hidden profile overrides.
- [x] Checks use non-secret fixture values; no real secrets or credentials are provisioned, and no new resource registry is added.
- [x] Add no artificial dependency on generator tooling or desktop support; shell-specific integrations remain with their owners.

## Integration evidence

- Implementation authorization: the approved implementation invocation and execution rules recorded in `coordination.md` supersede the historical publication-only caveat above.
- Integrated reviewed implementation `37969093f88b91dd3ac5ac3392433600f01f0920` with merge `fde0f5a37850050a92a1658366ca5531ab46b543`.
- Independent reviews: implementation APPROVE `b8d11772-6236-4a8` at `652dc36`; reconciliation APPROVE `14996c56-078f-444` at `3796909`, including both parents and the actual core-profile/test resolution. Merge-tree probe and integration merge were conflict-free; the merger resolved no content conflicts.
- Host and home secrets/authentication resources use explicit native options, without inferred repository paths. Host authentication and user identity remain independent. Native agenix-rekey still permits optional identity generation; YubiKey PAM works without rekey. GUI pinentry is opt-in, DMS uses the native U2F authfile, and the password recipe remains available.
- Actual serial integration gates: broad compositions **73/73 true**, Niri/DMS **38/38 true**, headless/workstation composition passed; `nix flake check --no-build --no-write-lock-file`, `nix fmt`, `nix fmt -- --ci`, and `typos` all exited 0. Formatting left the implementation tree unchanged.
- Source `flake.nix` and `flake.lock` are unchanged from the pre-merge integration tip. Lock SHA-256 matches the recorded source baseline: `6f9c06db3f8a4211e10a99998c20c27c3307d8a4eedd9a69d3fed9b0af2f0e47`.
- Evidence is evaluation/formatting/spelling only, not build or runtime proof. Fixture resources are non-secret markers; no real credentials were provisioned.
