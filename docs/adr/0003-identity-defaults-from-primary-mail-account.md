# Identity defaults come from the primary mail account

Status: accepted

`home.git` and `home.rbw` default their identity options to the consumer's
primary `accounts.email` account: `programs.git.settings.user` takes its
name from the account's `realName` and its email from the address,
`programs.rbw.settings.email` takes the address. Explicit per-feature
settings override the defaults; relying on them without a primary account
fails evaluation.

## Considered Options

- **Distinct identities only** (previous doctrine): every consumer sets each
  application identity explicitly, and a Git, vault, or mail address never
  substitutes another. Safest separation, but every consumer repeats the same
  address once per feature, and a missing `programs.rbw.settings.email`
  surfaced as an opaque evaluation error deep inside a Home Manager build
  (`home.terminal` includes `term-secrets`, so every terminal consumer
  inherited the requirement silently).

- **Silent rbw deactivation, empty-string defaults, or loud assertions when
  no primary account exists**: all add guard machinery for a state the
  consumer controls anyway; relying on the defaults then simply fails.

## Consequences

`accounts.email.accounts.<name>` doubles as the identity registry: a bare
account with `primary = true` and no mail configuration is valid and triggers
no mail-stack assertions. Consumers with genuinely distinct addresses keep
them by setting the native options explicitly. The terminal profile keeps
`term-secrets`: a consumer that selects it without any identity gets a loud
assertion instead of a silent inheritance or a silent no-op.
