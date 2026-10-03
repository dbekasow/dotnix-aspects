# Dotnix-Aspects

A reusable library of [dendritic](https://github.com/mightyiam/dendritic) NixOS and Home Manager aspects, built on [flake-parts](https://flake.parts/).

Every `.nix` file is a flake-parts module. Aspects register themselves in module classes (`flake.modules.nixos.*`, `flake.modules.homeManager.*`, `flake.modules.generic.*`). Tiers (`modules/aspects/<tier>.nix`: `core`, `base`, `system`, `server`, `desktop` = `desktop-shell` + `desktop-apps`, `development`, `terminal` = `term-shell` + `term-ux` + `term-cli` + `term-monitoring` + `term-nix` + `term-secrets`, `mail`) compose aspects into importable bundles, and the host/user factory in `modules/parts/configuration.nix` maps the `dotnix.hosts` namespace to `nixosConfigurations`.

## Aspects

All aspects live under `modules/aspects/`. Each file is a flake-parts module contributing to NixOS, Home Manager, or both. Adding or removing a file changes only the capabilities it provides.

| Category       | Classes   | Description                                                    |
| -------------- | --------- | -------------------------------------------------------------- |
| `core/`        | NixOS, HM | Nix, users, secrets, theming, SSH, security, locale, fonts     |
| `system/`      | NixOS     | Boot, disk layout, networking, audio, bluetooth, power         |
| `desktop/`     | NixOS, HM | Compositor, shell, greeter, portals, apps, terminals           |
| `development/` | NixOS, HM | Editor, LSPs, Git, containers, Kubernetes, AI, automation      |
| `term/`        | HM        | Shells, prompt, multiplexer, file tools, monitoring, Nix tools |

## Usage

Add this flake as an input and pick an entry point — one per consumer type, all defined in `modules/expose.nix`. Every entry is a flake-parts module: enabling is importing.

| Consumer                   | Import                                                      | You get                                                                                                                                          | Boundary                                                                                                                  |
| -------------------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| flake-parts + factory      | `inputs.dotnix.flakeModule`                                 | Full product: aspects + tiers, `dotnix.hosts.<host>` factory → `nixosConfigurations`, age-rekey apps, home-manager wiring, template registration | None — the template path                                                                                                  |
| flake-parts, own assembly  | `inputs.dotnix.flakeModules.aspects`                        | Aspect registry (`flake.modules.nixos/homeManager.*`) + tiers, without the `dotnix` options namespace or `nixosConfigurations` writer            | Assemble hosts yourself (own `nixosSystem`, nix-darwin); factory-bound aspects below need the wrapper module              |
| Plain NixOS / Home Manager | `inputs.dotnix.nixosModules.fish` or `homeManagerModules.*` | Every aspect as a standard flake output — no flake-parts on your side                                                                            | `dotnix`-bound aspects below need `nixosModules.dotnix` + `dotnix.host` entries; vault branches stay inactive (see below) |
| Dev tooling                | `inputs.dotnix.flakeModules.devTools`                       | devshell, pre-commit, treefmt — the library's dev stack                                                                                          | Import together with `flakeModule`: pre-commit hooks treefmt, devshell reads the agenix-rekey package from the age part   |

The factory entry in full:

```nix
# flake.nix
{
  inputs = {
    dotnix.url = "github:dbekasow/dotnix-aspects";
    dotnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      inputs.dotnix.flakeModule # import the aspects library
    ];
    # ...
  };
}
```

Or start from the consumer template:

```console
nix flake new my-config -t github:dbekasow/dotnix-aspects
```

### dotnix-bound aspects

Most aspects are plain drop-in modules; the remaining ones use the factory or collector options.

- **Factory-bound** — read `dotnix.members`/`dotnix.hostname`/`dotnix.vaultReady`, options the factory injects via the wrapper module (exposed as `nixosModules.dotnix`). Plain consumers import that wrapper and provide `dotnix.members`/`dotnix.hostname` themselves: `users`, `users-profile`, `age`, `age-rekey`, `certificates`, `nh`, `yubikey-pam`, `docker`, `git-credentials`, `dms-greeter`.
- **Collector-bound** — write into the `dotnix.tmux` options that the `tmux-bindings` aspect declares; import it alongside: `tmux-popups`, `sesh`, `workmux`, `tuicr`.
- **Self-contained group** — declares its own `dotnix.git` options: `git-repos`.

For the new API, replace runtime `dotnix.host.members` with `dotnix.members`; `dotnix.hosts.<name>.members` remains the factory input. The generic `profile` now holds only `fullname` and `email`: remove `profile.username`/`profile.theme` assignments and configure SSH login keys through native `users.users.<name>.openssh.authorizedKeys.keys`. Preserve existing keys when migrating a caller.

Vault-gated branches additionally require the host identity layout from [Secrets & paths](#secrets--paths-consumer-contract) to live under the flake that runs the factory. Via a plain module import that path resolves inside this library, so the vault stays off and evaluation stays green.

## Composition rules

- `core` is standalone — no other tier is required. A WSL host running `core` + `development` (without `system`) evaluates and works.
- **`core` is not injected.** The factory maps `dotnix.hosts.<hostname>` entries verbatim to `nixpkgs.lib.nixosSystem`; hosts declare their tiers themselves. Import `core` to get the home-manager wiring (`nixos.home-manager`).
- **State history belongs to its owner.** Set `system.stateVersion` in each host and `home.stateVersion` for each HM user to their existing installed values; the factory neither infers nor advances them.
- **Host axis vs. user axis.** Hosts import NixOS tiers through `dotnix.hosts.<name>.modules`; user profiles import HM tiers through `homeManager.<user>` (see `modules/users/<user>/default.nix`). `desktop` is the one tier on both axes with different reach: on the host it pulls the NixOS socket (`desktop-shell`), in a user profile it pulls the socket **plus** the GUI applications (`desktop-shell` + `desktop-apps`).
- **Select a shell and greeter explicitly.** Import NixOS `desktop-shell`, then `dms` with HM `dms` for a DMS session, or HM `noctalia` for Noctalia. HM `desktop` adds graphical applications; HM `desktop-shell` selects only the Niri socket. Noctalia's Niri bindings require the HM Niri context. Select exactly one NixOS greeter (`dms-greeter` or `noctalia-greeter`); both own greetd's default session.
- Registering an aspect does not activate it. Import `development` only for the chosen toolchain; Workmux/Tuicr Tmux bindings require both their tool aspect and enabled Tmux.
- The `impermanence` aspects assume the btrfs-on-LUKS layout provided by the `disko` aspect; their `/persist` fragments only activate when the `impermanence` aspect is imported.
- Impermanence audit one-liner: `grep -rn 'home.persistence' modules/`

## Tiers vs. groups

`modules/aspects/profiles/core.nix` (the tier aggregator) and `modules/aspects/core/` (the group directory) share a name but play different roles: **tiers are composition layers** (what a host imports), **groups are thematic shelves** (where aspects live). Tiers import across groups — e.g. the `core` tier pulls the `fish` shell aspect from `term/shell/`, because every work profile needs a shell. Full group↔tier alignment is neither intended nor useful.

## Persona import lines

Proven composition lines (host `modules` + user-profile HM imports):

| Profile               | Host line                                                        | User line                          |
| --------------------- | ---------------------------------------------------------------- | ---------------------------------- |
| WSL work host         | `[ <wsl-hw> core development ]`                                  | `[ terminal development ]`         |
| Workstation           | `[ <hw> core system desktop-shell dms dms-greeter development ]` | `[ terminal development desktop ]` |
| VPS / headless server | `[ <vps-hw> core server ]`                                       | `[ terminal development ]`         |
| VM / container        | `[ <core ]`                                                      | —                                  |

`server` composes `base`, which supplies generic boot behavior and journald only. It does not select a bootloader or root disk: each server must provide both explicitly, along with its hardware, networking, and any desired work/admin `core` profile. Laptop performance tuning and systemd-boot selection belong to `system`, not `server`. Run `nix eval --impure --file tests/headless-composition.nix` to evaluate the neutral server composition and verify that workstation tuning remains in `system`.

`base` is an inherited boot socket — `system` and `server` pull it, nobody imports it directly. `mail` is an exclusion bundle: pull it only for users who read mail, so non-mailers don't inherit the mail timers. Swap `dms`/`dms-greeter` for `noctalia`/`noctalia-greeter` on hosts that prefer the alternative shell. New tiers appear with their first real consumer, not from theory.

## Channel choice

The fleet-wide pin follows the consumer: `dotnix.inputs.nixpkgs.follows = "nixpkgs"` in the consumer's flake redirects the library's nixpkgs — and every tool input following it — to the consumer's channel. Point your `nixpkgs` input at a stable branch and every host builds on it.

Mixed fleets pick a channel per host:

```nix
# consumer flake.nix
inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

# host module

dotnix.hosts.vps.nixpkgs = inputs.nixpkgs-stable.lib;
```

Caveat: the library's option surfaces are verified against unstable — a stable host may hit upstream option renames on its first pin.

## Secrets & paths (consumer contract)

agenix-rekey expects this layout in the **consumer** repo:

```
modules/hosts/<host>/secrets/ssh_host_ed25519_key.pub   # host identity
modules/hosts/<host>/certificates/*.crt                 # extra CAs (optional)
modules/users/<user>/secrets/home-key.pub               # user identity
yubikey.pub, masterkey.age                              # master identities (repo root)
```

Evaluating without these files is fine — the vault only gets declared once the host key exists; `nix run .#rekey` bootstraps it.

## Theming

DMS/matugen is the single source of truth for the shell and its ~20 matugen template targets (bar, niri, GTK, Firefox, Qt5ct/Qt6ct, terminals …), recolored from the wallpaper palette. Stylix covers the targets matugen does not (GTK apps, Firefox, icons, cursors, fonts) and owns all NixOS `qt.*` options — its plain assignments always override `mkDefault`, which is why the former `qt-theme` aspect was removed as redundant. `dms-settings.nix` holds only real deltas against the pinned DMS rev; DMS itself manages schema defaults and `configVersion`. Keep per-app theme overrides out of aspects unless matugen/stylix provably cannot cover them.

**Noctalia** is a second palette authority: it generates its own wallpaper-based palettes and must not double-theme apps — keep its built-in app templates off and let stylix own app themes. When the matugen bridge is wanted, feed matugen's output through `programs.noctalia.customPalettes` (`theme.source = "custom"`).

## Key Design Decisions

**Dendritic pattern** — Each file owns its feature across all configuration classes. Values are shared via `let`-bindings or flake-parts options, not `specialArgs`.

**Secrets with agenix-rekey** — Host and user secrets are managed through `age.rekey` with local storage mode and a master identity. Password generation is handled declaratively.

**Factory pattern** — `modules/parts/configuration.nix` maps every `dotnix.hosts.<hostname>` entry to an `nixosConfigurations.<hostname>`, wiring the user aspects listed in `members`. Core injection was deliberately removed (`880c2b1`): hosts declare their own tiers.

## License

MIT
