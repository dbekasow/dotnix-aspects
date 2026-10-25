# Dotnix-Aspects

A reusable library of [dendritic](https://github.com/mightyiam/dendritic) NixOS and Home Manager aspects built on Den. Consumers import its native Den namespace and activate features by including aspects in host and user compositions. Optional bundles under root `profiles/` are conveniences, not mandatory tiers.

## Feature catalog and discovery

Feature sources live under root `features/`. Small features can stay in one file; multi-part owners such as Helix, DMS, Niri, Firefox, and Tmux keep related parts and integrations local. Each module declares its public `dotnix.*` aspect names explicitly; filesystem names do not define public namespace paths. Optional profile modules live separately under root `profiles/` and are assembled explicitly.

`modules/expose.nix` discovers feature modules only by scanning `features/` with the pinned import-tree default: directory scans select `.nix` files and exclude paths containing relative `/_`. `default.nix` does not stop recursive scanning. This is a filename filter, not module-shape validation or a security boundary: explicitly supplied files bypass the filter, changing scan roots changes which paths are relative, and `initFilter` replaces the default predicate. Keep helpers outside discovery or under an owner-local `_private/` path and import them explicitly.

## Usage

Add the library and Den as flake inputs. Import Den's flake module and the exported namespace in the consumer's native Den entry point. The public library output is `denful.dotnix`; consumers do not receive wrapped module aliases or an independent host builder.

```nix
# modules/parts.nix — same entry point used by templates/dotnix
{ inputs, den, ... }:
{
  imports = [
    inputs.den.flakeModule
    (inputs.den.namespace "dotnix" [ inputs.dotnix true ])
    inputs.dotnix.flakeModules.devTools
  ];

  den.quirks.popup-launcher = {
    description = "Enabled popup launcher records shared by selected user-scope aspects";
  };

  den.default.includes = [
    den.batteries.flake-scope
    den.batteries.hostname
  ];
}
```

Compose host and user behavior through Den entities and aspects, as in the executable template at `templates/dotnix/modules/hosts/myHost/configuration.nix` and `templates/dotnix/modules/users/myUser/default.nix`:

```nix
{ dotnix, ... }:
{
  den.hosts.x86_64-linux.myHost.users.myuser.classes = [ "homeManager" ];

  den.aspects.myHost = {
    provides.myuser.includes = [ dotnix.myuser ];
    includes = with dotnix; [ core network boot ];
    nixos.system.stateVersion = "26.11";
  };

  dotnix.myuser = {
    includes = with dotnix; [ core-home terminal ];
    homeManager.home.stateVersion = "26.11";
  };
}
```

The example illustrates the native entry/entity contract; real hosts also need hardware, disk, identity, and secret configuration. The library exposes `flakeModules.devTools` as a flake-parts module for its devshell, pre-commit, treefmt, and agenix-rekey tooling. In a consumer importing it, use `nix develop`, `nix fmt`, and `nix flake check`. Regenerate the root flake from its `flake-file` declarations with `nix run .#write-flake`; this is separate from the vault commands `nix run .#generate` and `nix run .#rekey`. Den's native output integration creates NixOS and Home Manager outputs.

Or start from the consumer template:

```console
nix flake new my-config -t github:dbekasow/dotnix-aspects
```

### Namespace and classes

`denful.dotnix` includes namespace-owned aspect definitions and custom class declarations. Import it through Den's namespace helper so the consumer merges class schemas and aspect providers into its own Den evaluation. Select features in Den aspects and entities; namespace discovery alone never activates them. Declare the `popup-launcher` Quirk in the consumer entry point as shown above: Den's namespace exports aspects and classes, not Quirk declarations. Selected Tmux and Herdr aspects share enabled launcher data only within the same user; each renders its own keys and runtime behavior.

## Composition rules

- `core` is standalone — no other tier is required. A WSL host running `core` + `development` evaluates and works.
- **Profiles are optional compositions.** Select host-system aspects on host entities and personal Home Manager features on user entities. For host-owned Home Manager behavior, route deliberately with a Den policy activated in the host's `includes`; host `homeManager` class content does not automatically enter user homes.
- **State history belongs to its owner.** Set `system.stateVersion` in each host and `home.stateVersion` for each HM user to their existing installed values; Den does not infer or advance them.
- **Host axis vs. user axis.** Consumers select aspects on `den.hosts.<system>.<host>` and user entities; Den's native output integration creates NixOS and Home Manager outputs. `desktop` is a reusable include bundle with the graphical socket and GUI applications.
- **Select a shell and greeter explicitly.** Import NixOS `desktop-shell`, then `dms` with HM `dms` for a DMS session, or HM `noctalia` for Noctalia. HM `desktop` adds graphical applications; HM `desktop-shell` selects only the Niri socket. Noctalia's Niri bindings require the HM Niri context. Select exactly one NixOS greeter (`dms-greeter` or `noctalia-greeter`); both own greetd's default session. The HM Niri aspect imports Niri's options provider; remove direct `inputs.niri.homeModules.niri` imports wherever `homeManager.niri`, `desktop`, or `desktop-shell` is imported to avoid duplicate option declarations.
- Registering an aspect does not activate it. Import `development` only for the chosen toolchain; Workmux/Tuicr Tmux bindings require both their tool aspect and enabled Tmux. Prefix `o` opens TUI popups; Prefix `w` opens Workmux's agents menu. The K9s popup follows `programs.k9s.enable`.
- Herdr is an explicit Tmux alternative: import `terminal-herdr` instead of `terminal` for a user who wants Herdr. Existing `terminal` and `term-ux` imports keep Tmux, Sesh, and Zellij; selecting Herdr does not change any consumer composition automatically.
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

Persistence follows the same scope separation: selected `systemPersistence` contributions route to the host's OS class, while selected `homePersistence` contributions route only to the relevant user's Home Manager class. `impermanence` explicitly activates these routing policies. For PipeWire, select `pipewire` on the host for audio services and in the intended user's scope for `.local/state/wireplumber`; do not import the entire host aspect tree into that user's home. Unselected features and unrelated users receive no contribution. Excluding the routing policies leaves the Impermanence baseline available without routing feature contributions. Run `nix eval --impure --file tests/broad-compositions.nix` to check selected, unselected, unrelated-user and routing-disabled cases.

`mail` is an opt-in bundle; include it only for users who read mail. Select `dms`/`dms-greeter` or `noctalia`/`noctalia-greeter` explicitly on hosts that need a graphical session. New bundles should appear with their first real consumer, not from theory.

Personal identities also belong in the consumer's Home Manager class: set `programs.git.settings.user`, `programs.rbw.settings.email`, and, when selecting `maildir`, `programs.notmuch.settings.user.name` and `programs.notmuch.settings.user.primary_email` through their native options. Keep each `accounts.email.accounts.<name>.address` distinct; a Git, vault or primary mail address does not replace other account addresses. The retained `tests/broad-compositions.nix` fixture checks these independent identities and Home Manager activation evaluation.

## Channel choice

The consumer owns its nixpkgs channel. Set `dotnix.inputs.nixpkgs.follows = "nixpkgs"` in the consumer flake to make the library and its dependent inputs follow that channel. This is a flake-level choice; no per-host channel selector is provided by this library.

A local `path:/home/denis/projects/dotnix-aspects` input is development-only and not portable. Nix hashes the entire directory, including `.git`, untracked and ignored files; never keep private files in that library tree. After library changes, refresh only that input with `nix flake update dotnix`, or test current code with `--no-write-lock-file --override-input dotnix path:/home/denis/projects/dotnix-aspects`. Plain `nix flake lock` does not refresh an existing local snapshot.

## Secrets & paths (consumer contract)

Secret identities, vault files, certificates, wallpapers, and other host/user resources belong to the consumer repository, not the library input. Activate `den.batteries.flake-scope` as shown above: resource-owning aspect functions capture the consumer's `inputs.self`, while dependency imports retain the library's inputs. Set identities and secret-manager references through native consumer options. No wrapper or custom `dotnix` option namespace is required.

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

**Den-native outputs** — the consumer evaluates Den host and user entities and imports `denful.dotnix` through `den.namespace`. This library defines reusable aspects and profiles; it does not build hosts or inject profiles.

## License

MIT
