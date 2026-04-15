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
