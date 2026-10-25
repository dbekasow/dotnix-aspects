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

`modules/parts.nix` is the Den entry point. It imports Den's flake module and the library namespace, declares the user-scope `popup-launcher` Quirk for Tmux/Herdr, then enables the `flake-scope` and `hostname` batteries. The host configuration registers `myHost` and gives `myuser` the `user` and `homeManager` classes; its `provides.myuser` edge routes the user aspect from `modules/users/myUser/default.nix` into that account. The user aspect explicitly selects `account.users`; integrated Home Manager remains optional through its separate class. Add `account.passwords` only to users who need generated passwords, and select host `age` and `age-rekey`; the recipe reads native `age.rekey.secretsDir`, whose default is `modules/hosts/<host>/secrets` and can be overridden. Desktop shell selection is explicit at both scopes: `desktop-shell` and `dms` are provided to `myuser` for Home Manager configuration and included by the host for NixOS configuration. To select Noctalia, replace `dms` with `noctalia` in both `provides.myuser.includes` and host `includes`; select the matching `host.noctalia-greeter` instead of `host.dms-greeter`.

## Greeter resources

Greeters are host-wide capabilities. They do not infer a user's home or require a matching user shell. The sample host supplies DMS's native `programs.dms-greeter.configHome` from its consumer-owned `greeter/home` directory. Set any extra DMS files through native `programs.dms-greeter.configFiles`. If switching to Noctalia, replace the host feature and set its native settings to consumer-owned assets:

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

## Secrets (first boot)

Secret identities, vault files, certificates, wallpapers, and other host/user resources belong in this consumer repository. A fresh clone evaluates without host key material; the vault is declared only once the host key exists. To set up real secret management:

1. Set consumer master identities in `modules/hosts/myHost/configuration.nix`.
2. Put the host key at `modules/hosts/myHost/secrets/ssh_host_ed25519_key.pub` and the user key at `modules/users/myUser/secrets/home-key.pub`.
3. Run `nix run .#generate` to generate the vault, then `nix run .#rekey` to rekey it into `secrets/{generated,local}/`.

The committed master identity is a public placeholder for demonstration only. Replace it and configure real identities before managing secrets; never add private keys to this repository.

## Adding a host

1. Copy `modules/hosts/myHost/` and rename it.
2. Register the host and user classes under `den.hosts.<system>.<name>` and compose features under `den.aspects.<name>` in `configuration.nix`.
3. Replace `hardware.nix`, disk device, identities and state version with the actual host's configuration.

## Adding a user

1. Copy `modules/users/myUser/` and rename it.
2. Rename the `dotnix.myuser` aspect key in `default.nix` to match `provides.<name>` in the host aspect.
3. Select `account.users` in that aspect and add the `user` class to the account; add `homeManager` only when integrated Home Manager is wanted.
4. Add `account.passwords` to that named user's includes only when generated passwords are wanted; select host `age` and `age-rekey`.
5. Set the user's native Home Manager identity options and existing `home.stateVersion`.

## License

MIT
