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
  parts.nix                # Den namespace, batteries and dev tools
flake.nix
```

`modules/parts.nix` is the Den entry point. It imports Den's flake module and the library namespace, declares the user-scope `popup-launcher` Quirk for Tmux/Herdr, then enables the `flake-scope` and `hostname` batteries. The host configuration registers `myHost` and gives `myuser` the `user` and `homeManager` classes; its `provides.myuser` edge routes the user aspect from `modules/users/myUser/default.nix` into that account. The user aspect explicitly selects `account.users`; integrated Home Manager remains optional through its separate class. Host and home Age/Rekey aspects are selected separately and use native `age.rekey` resources defined in their owning consumer modules. Add `account.passwords` only to users who need generated passwords; it stays inactive until the host's secret directories and public key are configured. The example explicitly opts into `home.gpg-agent-gui`; `desktop-shell` does not force GUI pinentry.

Desktop shell selection is explicit at both scopes: `desktop-shell` and `dms` are provided to `myuser` for Home Manager configuration and included by the host for NixOS configuration. To select Noctalia, replace `dms` with `noctalia` in both `provides.myuser.includes` and host `includes`, select `host.noctalia-greeter` instead of `host.dms-greeter`, and remove DMS-only `programs.dms-greeter.*` assignments from the host's `nixos` settings. Greeter resources remain host-owned; see the example below.

## Greeter resources

Greeters are host-wide capabilities. They do not infer a user's home or require a matching user shell. The sample host supplies DMS's native `programs.dms-greeter.configHome` from its consumer-owned `greeter/home` directory. Set any extra DMS files through native `programs.dms-greeter.configFiles`. When switching to Noctalia, replace `host.dms-greeter` with `host.noctalia-greeter` and remove DMS-only `programs.dms-greeter.*` assignments from the host's `nixos` settings, including the sample `configHome` assignment in `configuration.nix`; these options are undeclared without the DMS greeter. Then set Noctalia's native settings to consumer-owned assets:

```nix
services.displayManager.noctalia-greeter.settings.appearance.wallpaper = {
  path = builtins.toString ./greeter/wallpaper.svg;
  fill_mode = "crop";
};
```

## Usage

Review `modules/hosts/myHost/configuration.nix` before building or activating. Replace the example disk device, state versions, hardware, user identity, and throwaway master identity with values for your consumer. The sample disk path is not safe to use as-is.

```console
nix develop
nix fmt
nix flake check
nix build .#nixosConfigurations.myHost.config.system.build.toplevel
```

## Secrets and authentication

The consumer owns secret identities, vault directories, certificates and YubiKey mappings. Library features do not derive paths from host or account names. The host and home examples each set their own native `age.rekey` directories, public key and master identities. Choose paths that fit your repository; no fixed `modules/hosts/<host>/secrets` layout is required.

Use native options for additional resources in `modules/hosts/myHost/configuration.nix`, for example `security.pki.certificateFiles` and `security.pam.u2f.settings.authfile`. Select `host.yubikey-pam` only when PAM U2F is wanted; it does not need agenix-rekey or desktop support. Add `account.passwords` only when generated account passwords are wanted and host rekey resources are configured. Set `age.identityPaths` in the host or home module that owns each identity.

The template includes no usable credentials or master identities. Supply valid consumer-owned identities before managing secrets; never add private keys or real credentials to this repository. Run `nix run .#generate` and `nix run .#rekey` only after supplying resources appropriate for your consumer.

## Adding a host

1. Copy `modules/hosts/myHost/` and rename it.
2. Register the host and user classes under `den.hosts.<system>.<name>` and compose features under `den.aspects.<name>` in `configuration.nix`.
3. Replace `hardware.nix`, disk device, identities and state version with the actual host's configuration.

## Adding a user

1. Copy `modules/users/myUser/` and rename it.
2. Rename the `dotnix.myuser` aspect key in `default.nix` to match `provides.<name>` in the host aspect.
3. Select `account.users` in that aspect and add the `user` class to the account; add `homeManager` only when integrated Home Manager is wanted.
4. Add `account.passwords` to that named user's includes only when generated passwords are wanted; configure native host `age.rekey` directories and public key.
5. Configure the user's native Home Manager `age.identityPaths` and `age.rekey` options independently, then set existing `home.stateVersion`.

## License

MIT
