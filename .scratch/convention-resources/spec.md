# Conventional resource layout

The library wires host CAs and host/home agenix-rekey resources from a
conventional consumer repository layout. Every wiring is a `mkDefault`;
native option overrides win.

## Layout

```
modules/hosts/<host>/certificates/*.crt
modules/hosts/<host>/secrets/{,generated/,local/}
modules/hosts/<host>/secrets/ssh_host_ed25519_key.pub
modules/users/<user>/secrets/{,generated/,local/}
modules/users/<user>/secrets/home-key.pub
```

## Decisions

- Supersedes the no-path-inference criterion of
  `den-flake-file-redesign` issue 06 for these path resources; the
  explicit-override scenarios of `tests/broad-compositions.nix` keep
  proving that native options still win.
- Consumer-owned identities (`masterIdentities`,
  `extraEncryptionPubkeys`) stay explicit.
- Home rekey does not require host-side age-rekey on the same target.
- Derived directories (`generated/`, `local/`) follow the merged
  `secretsDir`, so overriding the base directory relocates them.
