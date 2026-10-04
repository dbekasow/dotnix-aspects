# Dotnix-Aspects

A reusable library of [dendritic](https://github.com/mightyiam/dendritic) NixOS and Home Manager aspects built on Den. Consumers import its native Den namespace and activate features by including aspects in host and user compositions. Optional bundles under `modules/aspects/profiles/` are conveniences, not mandatory tiers.

## Aspects

All aspects live under `modules/aspects/`. Each file contributes Den aspects for NixOS, Home Manager, or both. Adding or removing a file changes only the capabilities it provides.

| Category       | Classes   | Description                                                    |
| -------------- | --------- | -------------------------------------------------------------- |
| `core/`        | NixOS, HM | Nix, users, secrets, theming, SSH, security, locale, fonts     |
| `system/`      | NixOS     | Boot, disk layout, networking, audio, bluetooth, power         |
| `desktop/`     | NixOS, HM | Compositor, shell, greeter, portals, apps, terminals           |
| `development/` | NixOS, HM | Editor, LSPs, Git, containers, Kubernetes, AI, automation      |
| `term/`        | HM        | Shells, prompt, multiplexer, file tools, monitoring, Nix tools |

## Usage

Add library as a flake input, then import exported namespace in the consumer's Den module. The public library output is `denful.dotnix`; consumers do not receive wrapped module aliases or an independent host builder.

```nix
{ inputs, dotnix, ... }:
{
  imports = [
    inputs.den.flakeModule
    (inputs.den.namespace "dotnix" [ inputs.dotnix true ])
  ];

  den.aspects.my-host.includes = [ dotnix.core dotnix.desktop-shell ];
}
```

The library exposes `flakeModules.devTools` as native flake-parts module for consumers that want its devshell, pre-commit, treefmt, and agenix-rekey tooling. Import that module into a flake-parts composition; Den host and user outputs still come from Den's native output integration.

Or start from the consumer template:

```console
nix flake new my-config -t github:dbekasow/dotnix-aspects
```

### Namespace and classes

`denful.dotnix` includes namespace-owned aspect definitions and custom class declarations. Import it through Den's namespace helper so the consumer merges class schemas and aspect providers into its own Den evaluation. Select features on `den.hosts` or user-profiles with `includes`; library discovery alone never activates them.

## Composition rules

- `core` is standalone — no other tier is required. A WSL host running `core` + `development` evaluates and works.
- **Profiles are optional compositions.** Select host-system aspects on host entities and personal Home Manager features on user entities. For host-owned Home Manager behavior, route deliberately with a Den policy activated in the host's `includes`; host `homeManager` class content does not automatically enter user homes.
- **State history belongs to its owner.** Set `system.stateVersion` in each host and `home.stateVersion` for each HM user to their existing installed values; Den does not infer or advance them.
- **Host axis vs. user axis.** Consumers select aspects on `den.hosts.<system>.<host>` and user entities; Den's native output integration creates NixOS and Home Manager outputs. `desktop` is a reusable include bundle with the graphical socket and GUI applications.
- **Select a shell and greeter explicitly.** Import NixOS `desktop-shell`, then `dms` with HM `dms` for a DMS session, or HM `noctalia` for Noctalia. HM `desktop` adds graphical applications; HM `desktop-shell` selects only the Niri socket. Noctalia's Niri bindings require the HM Niri context. Select exactly one NixOS greeter (`dms-greeter` or `noctalia-greeter`); both own greetd's default session. The HM Niri aspect imports Niri's options provider; remove direct `inputs.niri.homeModules.niri` imports wherever `homeManager.niri`, `desktop`, or `desktop-shell` is imported to avoid duplicate option declarations.
- Registering an aspect does not activate it. Import `development` only for the chosen toolchain; Workmux/Tuicr Tmux bindings require both their tool aspect and enabled Tmux.
- Herdr is an explicit Tmux alternative: import `terminal-herdr` instead of `terminal` for a user who wants Herdr. Existing `terminal` and `term-ux` imports keep Tmux, Sesh, and Zellij; selecting Herdr does not change any caller profile automatically.
- The `impermanence` aspects assume the btrfs-on-LUKS layout provided by the `disko` aspect; their `/persist` fragments only activate when the `impermanence` aspect is imported.
- Impermanence audit one-liner: `grep -rn 'home.persistence' modules/`

## Reusable profiles

Profiles are optional named include bundles, not a base-to-workstation inheritance chain. Consumers can include individual aspects directly and make host system choices separately from user Home Manager choices. For example, the host may include `boot`, `network`, and `disko`, while a particular user includes `desktop-shell`, `desktop-apps`, and `terminal`. To route shared host-selected Home Manager features, add an explicit Den `provides` edge; the host alone choosing an aspect does not implicitly configure a user's home.

## Host and user composition

Compose host system functions and personal Home Manager choices independently:

| Selection scope | Typical includes                                                | Ownership                                                                                                       |
| --------------- | --------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| Host entity     | `boot`, `network`, `disko`, `desktop-shell`, `noctalia-greeter` | Consumer chooses system behavior and hardware; disk path, secrets, and `system.stateVersion` remain host-owned. |
| User entity     | `desktop-shell`, `desktop-apps`, `development`, `terminal`      | Consumer chooses personal Home Manager features and `home.stateVersion`.                                        |

`core` is an optional host feature bundle, not a prerequisite for other profiles. Its matching Home Manager feature bundle, `core-home`, reaches users only through the explicitly activated `den.policies.core-home-to-users` policy. This keeps shared host-to-home routing visible and reusable. `workstation` remains a convenience bundle; hosts can select its individual features instead. `server` provides only its intentionally small reusable behavior. `disko` supplies reusable geometry but no device default: every host importing it must set native `disko.devices.disk.main.device` to its own disk path. Run `nix eval --impure --file tests/headless-composition.nix` to verify the server remains independent of workstation tuning and disk configuration.

`mail` is an opt-in bundle; include it only for users who read mail. Select `dms`/`dms-greeter` or `noctalia`/`noctalia-greeter` explicitly on hosts that need a graphical session. New bundles should appear with their first real consumer, not from theory.

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

**Den-native outputs** — the consumer evaluates `den.hosts` and imports `denful.dotnix` through `den.namespace`. This library defines reusable aspects and profiles; it does not build hosts or inject profiles.

## License

MIT
