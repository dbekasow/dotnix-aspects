# Dotnix-Aspects

A reusable library of [dendritic](https://github.com/mightyiam/dendritic) NixOS and Home Manager aspects, built on [flake-parts](https://flake.parts/).

Every `.nix` file is a flake-parts module. Aspects register themselves in module classes (`flake.modules.nixos.*`, `flake.modules.homeManager.*`, `flake.modules.generic.*`). Tiers (`modules/aspects/<tier>.nix`: core, system, desktop, development, term) compose aspects into importable bundles, and the host/user factory in `modules/parts/configuration.nix` maps the `dotnix` namespace to `nixosConfigurations`.

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

Add this flake as an input and import its `flakeModule`. See `modules/expose.nix` for what the import pulls in: the aspects, the tiers and the product parts (flake-parts option, factory, age-rekey, home-manager wiring, template registration). Dev tooling (devshell, pre-commit, treefmt) is opt-in via `flakeModules.devTools`. The host/user schema (`dotnix` namespace) and how `nixosConfigurations` are assembled live in `modules/parts/configuration.nix`.

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
