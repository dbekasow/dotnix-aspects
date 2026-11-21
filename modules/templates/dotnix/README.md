# dotnix

NixOS configuration using [dotnix-aspects](https://github.com/dbekasow/dotnix-aspects).

## Overview

| Hostname | Hardware | Users  | Notes |
| -------- | -------- | ------ | ----- |
| myHost   | —        | myUser | —     |

## Structure

```
modules/
  hosts/
    myHost/
      configuration.nix   # Den host entity and host aspect composition
      greeter/              # consumer-owned greeter configuration and assets
      hardware.nix         # hardware-specific aspects
  users/
    myUser/
      default.nix          # Den user aspect and Home Manager settings
  parts.nix                # source-only library input and explicit import groups
flake.nix                  # generated from flake-file declarations
flake.lock
```

`modules/parts.nix` imports named modules from the source-only `dotnix` input. This template registers `home`, `desktop`, `managedSecrets`, and `yubikey`; `vault-tools` includes the repository tooling and the optional vault commands. Group imports register features; only the host and home selections apply them. The host configuration registers `myHost` and gives `myuser` the `user` and `homeManager` classes; its `provides.myuser` edge routes the user aspect from `modules/users/myUser/default.nix` into that account. The user aspect explicitly selects `account.users`; integrated Home Manager remains optional through its separate class. Host and home Age/Rekey aspects are selected separately and wire their `age.rekey` resources from the conventional consumer layout. Add `account.passwords` only to users who need generated passwords; it stays inactive until the host's secret directories and public key are configured. The example explicitly opts into `home.gpg-agent-gui`; `home.graphical` does not force GUI pinentry.

`host.dms` selects the desktop shell for this host and all of its integrated homes. `host.graphical` and `host.niri` supply their home defaults to `myuser`; the SSH and XDG baseline comes from `host.home-manager`, included by `host.core`. The user aspect selects `home.ghostty`, `home.firefox`, and `home.thunderbird` individually. Those modules supply their Niri launch keys when Niri is selected; `host.graphical` also supplies the Thunar launcher. Set native bindings only to override the defaults. To switch shells, replace `host.dms` with `host.noctalia` in host `includes`; there is no corresponding home selection to update. To switch greeters as a separate choice, see the example below.

## Greeter resources

Greeters are host-wide capabilities. They do not infer a user's home or require a matching user shell. The sample host supplies DMS's native `programs.dms-greeter.configHome` from its consumer-owned `greeter/home` directory. Set any extra DMS files through native `programs.dms-greeter.configFiles`. When switching to Noctalia, replace `host.dms-greeter` with `host.noctalia-greeter` and remove DMS-only `programs.dms-greeter.*` assignments from the host's `nixos` settings, including the sample `configHome` assignment in `configuration.nix`; these options are undeclared without the DMS greeter. Then set Noctalia's native settings to consumer-owned assets:

```nix
services.displayManager.noctalia-greeter.settings.appearance.wallpaper = {
  path = builtins.toString ./greeter/wallpaper.svg;
  fill_mode = "crop";
};
```

## Usage

Review `modules/hosts/myHost/configuration.nix` before building or activating. Replace the example disk device, state versions, hardware and user identity with values for your consumer. This example has no primary mail account, so it sets Git authorship and the rbw email explicitly. Remove those settings if both tools should inherit them from an existing primary mail account. Configure the conventional rekey resources before managing real secrets. The template contains no master identity, and the sample disk path is not safe to use as-is.

```console
nix develop
nix fmt
nix flake check
nix build .#nixosConfigurations.myHost.config.system.build.toplevel
```

## Storage, power, and optional host features

The host explicitly selects `host.boot-systemd`, `host.disko`, and `host.persistence`: the example uses systemd-boot and a Btrfs layout inside LUKS, with `/persist` for selected persistent state. Review the layout and replace the sample disk before use. Disko's existing example enables FIDO2 enrollment without a client PIN and recovery-key enrollment; removing the optional `host.yubikey` feature does not disable or redesign that enrollment. Provision compatible credentials and a recovery path before installing, and review the Disko configuration before any destructive disk operation.

Root reset is **not** selected by default. To opt in, add `host.btrfs-root-reset` to the host includes only after verifying a working systemd initrd and the expected Btrfs filesystem labeled `nixos`, with `@root` and an `@root-blank` snapshot. The reset deletes and recreates `@root` on boot; arrange persistence and backups for everything that must survive. It neither selects Disko nor generic persistence.

Other optional host additions are independent:

- `host.performance` applies laptop-oriented VM sysctl, zram, and trim tuning; review those choices against the machine and workload before selecting it.
- `host.geolocation` selects GeoClue as the location provider and configures BeaconDB and gammastep; review the network location policy before selecting it. Other selected components may independently enable the GeoClue service.
- `host.yubikey` enables PC/SC and YubiKey udev support. Authentication via `host.yubikey-pam` is separate and needs an appropriate native U2F authfile or NixOS default mapping; review its host-wide PAM effects before enabling it.

`host.power` supplies general power services, not a hibernation recipe. When migrating a host that relied on the former workstation defaults, explicitly configure its native resume device, any swapfile resume offset and sleep mode, and its desired systemd sleep, logind key/lid, and Upower battery policy. Validate those values and the machine's hibernation support rather than copying another host's device or offset.

## Secrets and authentication

The consumer owns secret identities, vault directories, certificates and YubiKey mappings. The library wires them from a conventional layout: `modules/hosts/<host>/certificates/*.crt`, `modules/hosts/<host>/secrets/{,generated/,local/}` with `ssh_host_ed25519_key.pub`, and `modules/users/<user>/secrets/{,generated/,local/}` with `home-key.pub`. Every wiring is a `mkDefault`; set the native `age.rekey` and `security.pki.*` options to deviate. Master identities stay consumer-owned and empty in the template.

Use native options for additional resources in `modules/hosts/myHost/configuration.nix`, for example `security.pki.certificateFiles` and `security.pam.u2f.settings.authfile`. Select `host.yubikey-pam` only when PAM U2F is wanted; it does not need agenix-rekey or desktop support. Add `account.passwords` only when generated account passwords are wanted and the conventional host secrets layout provides a public key. Set `age.identityPaths` in the host or home module that owns each identity.

The template includes no usable credentials or master identities. Supply valid consumer-owned identities before deploying or managing real secrets; never add private keys or real credentials to this repository. Run `nix run .#generate` and `nix run .#rekey` only after supplying resources appropriate for your consumer.

The template owns its direct `nixpkgs` input and locks it alongside the dependencies of its named imports. The `dotnix` pin must point to a revision providing those imports. After changing input declarations or adding or removing a group, run `nix run .#write-flake` and then `nix flake lock`. Remove selections from a group before removing its import. Run `nix flake update dotnix` to update the library source independently.

## Adding a host

1. Copy `modules/hosts/myHost/` and rename it.
2. Register the host and user classes under `den.hosts.<system>.<name>` and compose features under `den.aspects.<name>` in `configuration.nix`.
3. Replace `hardware.nix`, disk device, identities and state version with the actual host's configuration.

## Adding a user

1. Copy `modules/users/myUser/` and rename it.
2. Rename the `dotnix.myuser` aspect key in `default.nix` to match `provides.<name>` in the host aspect.
3. Select `account.users` in that aspect and add the `user` class to the account; add `homeManager` only when integrated Home Manager is wanted.
4. Add `account.passwords` to that named user's includes only when generated passwords are wanted; configure native host `age.rekey` directories and public key.
5. Set the user's native Home Manager `age.identityPaths` and master identities; `age.rekey` resource paths come from the conventional layout. Then set existing `home.stateVersion`.

## License

MIT
