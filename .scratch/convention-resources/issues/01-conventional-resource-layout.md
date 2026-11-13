# 01: Conventional resource layout for certificates and secrets

**What to build:** The library defines and wires a conventional consumer
repository layout for host CAs and host/home agenix-rekey resources.
`dotnix.host.certificates` collects every `*.crt` below
`modules/hosts/<host>/certificates/`; `dotnix.host.age-rekey` and
`dotnix.home.age-rekey` default `secretsDir`, `generatedSecretsDir`,
`localStorageDir` and `hostPubkey` to the conventional locations. All
defaults are `mkDefault`, so native option overrides still win. This
supersedes the no-path-inference part of
[`06-secrets-auth-resources`](../../den-flake-file-redesign/issues/06-secrets-auth-resources.md)
for these path resources; consumer-owned identities
(`masterIdentities`, `extraEncryptionPubkeys`) stay explicit, and host
authentication / home identity stay independently selectable.

**Status:** ready-for-agent — execution approved in session 2026-11-13.
**Spec/authorization:** [Canonical spec](../spec.md).

### Acceptance criteria

- [x] `host.certificates` trusts `*.crt` from
      `modules/hosts/<host>/certificates/` by default, ignores other
      extensions, and treats a missing directory as "no extra CAs".
- [x] `host.age-rekey` defaults `secretsDir`, `generatedSecretsDir` and
      `localStorageDir` to `modules/hosts/<host>/secrets{,/generated,/local}`
      and reads `hostPubkey` from `secretsDir/ssh_host_ed25519_key.pub` when
      present.
- [x] `home.age-rekey` defaults to
      `modules/users/<user>/secrets{,/generated,/local}` and
      `secretsDir/home-key.pub`, without requiring host-side age-rekey.
- [x] Derived directories follow the merged `secretsDir`, so overriding
      the base directory relocates `generated/` and `local/` with it.
- [x] Every conventional default is `mkDefault`; explicit native option
      values win (existing explicit-override scenarios keep proving it).
- [x] `tests/broad-compositions.nix` covers a conventional-layout
      scenario in addition to the explicit-override and empty scenarios.
- [x] README documents the layout contract and the override rule.

### Integration evidence

- `nix eval --impure --json --file tests/broad-compositions.nix`: 108/108
  checks true, including the new `conventionalResourcesAreWired` and
  `conventionalDirsFollowSecretsDirOverride`; every pre-existing
  explicit-override and empty scenario stayed green unchanged.
- `nix flake check --no-build --no-write-lock-file`, `nix fmt`,
  `nix fmt -- --ci`, and `typos` all exited 0.
- Evidence covers evaluation and formatting only: no build, activation,
  or runtime proof. Fixture resources stay non-secret presence markers.
- Implementation detail: include functions carry a `name` so den's
  key-based dedup collapses repeated applications; class modules receive
  the consumer tree through `_module.args.consumerSelf` because pipeline
  arguments (`inputs`) do not reach class-module scope.
