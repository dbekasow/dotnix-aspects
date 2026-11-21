# Keep tool identities independent of mail

Status: accepted; implemented. Supersedes [ADR 0003](0003-identity-defaults-from-primary-mail-account.md).

Changing the primary mail account must not silently change Git authorship or the vault account. Consumers may explicitly share an address or reference their primary mail account when those identities should move together.
