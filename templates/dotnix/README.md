# dotnix

NixOS configuration using [dotnix-aspects](https://github.com/dbekasow/dotnix-aspects).

## Overview

### Hosts

| Hostname | Hardware | Users  | Notes |
| -------- | -------- | ------ | ----- |
| myHost   | —        | myUser | —     |

## Structure

```
modules/
  hosts/
    myHost/
      configuration.nix   # host definition (modules, members)
      hardware.nix         # hardware-specific modules
  users/
    myUser/
      default.nix          # user definition (modules, profile)
  parts.nix                # imports the dotnix flakeModule
flake.nix
```

## Usage

```bash
# Apply system configuration
nh os switch -H myHost
```

## Secrets (first boot)

A fresh clone evaluates without key material — the vault only gets declared
once the host key exists. To bootstrap the real secrets workflow:

1. Set your master identities in the host module
   (`modules/hosts/myHost/configuration.nix`):

   ```nix
   age.rekey.masterIdentities = [
     { identity = ./yubikey.pub; pubkey = "age1yubikey1…"; }
     { identity = ./masterkey.age; pubkey = "age1…"; }
   ];
   ```

2. Put the host key at `modules/hosts/myHost/secrets/ssh_host_ed25519_key.pub`
   and the user key at `modules/users/myUser/secrets/home-key.pub`.
3. Run `just rekey` — it generates and rekeys the vault into
   `secrets/{generated,local}/`.

## Adding a host

1. Copy `modules/hosts/myHost/` and rename it
2. Adjust modules and members in `configuration.nix`
3. Replace `hardware.nix` with the actual hardware config

## Adding a user

1. Copy `modules/users/myUser/` and rename it
2. Set `fullname`, `email` and desired modules in `default.nix`
3. Add the username to the relevant host's `members` list

## License

MIT
