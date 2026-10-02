# Dotnix-Aspects

A reusable library of [dendritic](https://github.com/mightyiam/dendritic) NixOS and Home Manager aspects, built on [flake-parts](https://flake.parts/).

Every `.nix` file is a flake-parts module. Aspects register themselves in module classes (`flake.modules.nixos.*`, `flake.modules.homeManager.*`, `flake.modules.generic.*`). Tiers (`modules/aspects/<tier>.nix`: core, system, server, desktop, development, terminal, bootstrap) compose aspects into importable bundles, and the host/user factory in `modules/parts/configuration.nix` maps the `dotnix` namespace to `nixosConfigurations`.

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

| Consumer                   | Import                                                      | You get                                                                                                                                    | Boundary                                                                                                                  |
| -------------------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| flake-parts + factory      | `inputs.dotnix.flakeModule`                                 | Full product: aspects + tiers, `dotnix.<host>` factory → `nixosConfigurations`, age-rekey apps, home-manager wiring, template registration | None — the template path                                                                                                  |
| flake-parts, own assembly  | `inputs.dotnix.flakeModules.aspects`                        | Aspect registry (`flake.modules.nixos/homeManager.*`) + tiers, without the `dotnix` options namespace or `nixosConfigurations` writer      | Assemble hosts yourself (own `nixosSystem`, nix-darwin); factory-bound aspects below need the wrapper module              |
| Plain NixOS / Home Manager | `inputs.dotnix.nixosModules.fish` or `homeManagerModules.*` | Every aspect as a standard flake output — no flake-parts on your side                                                                      | `dotnix`-bound aspects below need `nixosModules.dotnix` + `dotnix.host` entries; vault branches stay inactive (see below) |
| Dev tooling                | `inputs.dotnix.flakeModules.devTools`                       | devshell, pre-commit, treefmt — the library's dev stack                                                                                    | Import together with `flakeModule`: pre-commit hooks treefmt, devshell reads the agenix-rekey package from the age part   |

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

16 of the 130 aspect files reference the `dotnix` options namespace; the rest are plain drop-in modules.

- **Factory-bound** — read `dotnix.host`/`dotnix.hostname`/`dotnix.vaultReady`, options the factory injects via the wrapper module (exposed as `nixosModules.dotnix`). Plain consumers import that wrapper and fill `dotnix.host`/`dotnix.hostname` themselves: `users`, `users-profile`, `age`, `age-rekey`, `certificates`, `nh`, `yubikey-pam`, `docker`, `git-credentials`, `dms-greeter`.
- **Collector-bound** — write into the `dotnix.tmux` options that the `tmux-bindings` aspect declares; import it alongside: `tmux-popups`, `sesh`, `workmux`, `tuicr`.
- **Self-contained group** — declares its own `dotnix.git` options: `git-repos`.

Vault-gated branches additionally require the host identity layout from [Secrets & paths](#secrets--paths-consumer-contract) to live under the flake that runs the factory. Via a plain module import that path resolves inside this library, so the vault stays off and evaluation stays green.

## Composition rules

- `core` is standalone — no other tier is required. A WSL host running `core` + `development` (without `system`) evaluates and works.
- **`core` is not injected.** The factory maps `dotnix.<hostname>` entries verbatim to `nixpkgs.lib.nixosSystem`; hosts declare their tiers themselves. Import `core` to get the home-manager wiring (`nixos.home-manager`).
- The `impermanence` aspects assume the btrfs-on-LUKS layout provided by the `disko` aspect; their `/persist` fragments only activate when the `impermanence` aspect is imported.
- Impermanence audit one-liner: `grep -rn 'home.persistence' modules/`

## Tiers vs. groups

`modules/aspects/core.nix` (the tier aggregator) and `modules/aspects/core/` (the group directory) share a name but play different roles: **tiers are composition layers** (what a host imports), **groups are thematic shelves** (where aspects live). Tiers import across groups — e.g. the `core` tier pulls the `fish` shell aspect from `term/shell/`, because every work profile needs a shell. Full group↔tier alignment is neither intended nor useful.

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

## Key Design Decisions

**Dendritic pattern** — Each file owns its feature across all configuration classes. Values are shared via `let`-bindings or flake-parts options, not `specialArgs`.

**Secrets with agenix-rekey** — Host and user secrets are managed through `age.rekey` with local storage mode and a master identity. Password generation is handled declaratively.

**Factory pattern** — `modules/parts/configuration.nix` maps every `dotnix.<hostname>` entry to an `nixosConfigurations.<hostname>`, wiring the user aspects listed in `members`. Core injection was deliberately removed (`880c2b1`): hosts declare their own tiers.

## License

MIT
