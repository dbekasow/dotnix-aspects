# Migrate a mixed consumer to named imports

Keep one flake and lockfile. In the consumer's `modules/parts.nix`, replace the Base, Desktop, and DevTools path imports with the following. Keep the existing source-only `dotnix` declaration, moving its pin to a revision that provides the public entry point. Preserve the consumer's other flake-parts settings.

```nix
{ inputs, ... }:
let
  modules = import inputs.dotnix;
in
{
  imports = with modules; [ home desktop managedSecrets yubikey devtools ];
}
```

For a setup like the private reference consumer:

- Keep the desktop host's Desktop selections and the headless host's existing host selections, including its explicit YubiKey support. The shared lockfile still contains Desktop inputs, but importing `desktop` does not select Desktop on either host.
- Where `host.core` previously provided Age implicitly, add `host.age`. Keep existing `host.age-rekey` selections. Where `home.core` previously provided Age/Rekey, add `home.age` and `home.age-rekey` in the same home composition. The imports register these capabilities; the explicit selections preserve the previous configuration.
- Keep the existing account classes, account and PAM selections, shell and greeter choices, tool identity values, and secret resources. This import migration does not change authentication or migrate an encrypted identity. If you previously imported `vault-tools`, replace it with `devtools`. The vault shell packages and app names are unchanged.

In a disposable consumer, regenerate with `nix run .#write-flake`, then run `nix flake lock`. Evaluate both the graphical and headless targets against that one lock before adopting the change. The library's [consumer-generation check](../tests/consumer-generation.sh) demonstrates this without private files or host activation.

[ADR 0008](adr/0008-one-desktop-shell-per-host.md) is a separate change: after adopting host-level shell inheritance, an integrated home no longer needs to duplicate its host's shell selection. For example, keep `host.noctalia` and the existing greeter on the desktop host, and remove the redundant `home.noctalia` from its integrated home composition. Leave the headless host unchanged.
