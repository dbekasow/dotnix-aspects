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
- **Host axis vs. user axis.** Consumers select aspects on `den.hosts.<system>.<host>` and user entities; Den's native output integration creates NixOS and Home Manager outputs. `desktop` is a reusable include bundle with the graphical foundation and GUI applications.
- **Select Niri host support and user configuration independently.** Add `host.niri` to a host's includes for NixOS support. Select `home.niri` in a user's includes for that user's Niri settings and bindings; this imports Niri's Home Manager options provider when host support has not already supplied it. A home selection does not enable NixOS Niri. `desktop-shell` bundles graphical foundation only; `desktop` also adds graphical applications. Neither selects Niri support or configuration. Noctalia's Niri bindings require the user's `home.niri` context. Select DMS or Noctalia explicitly on intended targets, and select exactly one host greeter (`host.dms-greeter` or `host.noctalia-greeter`); both own greetd's default session. Remove direct `inputs.niri.homeModules.niri` imports wherever `home.niri` is selected to avoid duplicate option declarations.
- **Polkit transition.** Per-user Polkit agents are not yet separated. Ticket 14 removed the previous host-wide suppression of Niri's agent, so Niri and DMS agents may currently coexist for DMS users. Ticket 15 restores conflict-free per-user agent ownership while keeping authentication working for users without DMS.
- Registering an aspect does not activate it. Import `development` only for the chosen toolchain; Workmux/Tuicr Tmux bindings require both their tool aspect and enabled Tmux. Prefix `o` opens TUI popups; Prefix `w` opens Workmux's agents menu. The K9s popup follows `programs.k9s.enable`.
- Herdr is an explicit Tmux alternative: import `terminal-herdr` instead of `terminal` for a user who wants Herdr. Existing `terminal` and `term-ux` imports keep Tmux, Sesh, and Zellij; selecting Herdr does not change any consumer composition automatically.
- `host.persistence` selects generic host persistence classes, routing, and NixOS `/persist` defaults without assuming a disk or boot layout; it works without Home Manager. Select `home.persistence` in a user's includes to apply the Home Manager `/persist` baseline only to that home. Select `host.btrfs-root-reset` separately for the existing `@root`/`@root-blank` Btrfs reset policy. Root reset neither selects generic persistence nor enables Disko; the consumer supplies a compatible machine layout.
- Persistence contribution audit one-liner: `grep -rn 'home.persistence' features/`

## Reusable profiles

Profiles are optional named include bundles, not a base-to-workstation inheritance chain. Consumers can include individual aspects directly and make host system choices separately from user Home Manager choices. For example, the host may include `boot`, `network`, `disko`, `host.niri`, and `desktop-shell`, while a particular user includes `home.niri`, `desktop-shell`, `desktop-apps`, and `terminal`. To route shared host-selected Home Manager features, add an explicit Den `provides` edge; the host alone choosing an aspect does not implicitly configure a user's home.

## Host and user composition

Compose host system functions and personal Home Manager choices independently:

| Selection scope   | Typical includes                                                                                      | Ownership                                                                                                       |
| ----------------- | ----------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| Host entity       | `boot`, `network`, `disko`, `host.niri`, `desktop-shell`, `host.dms-greeter`, `host.noctalia-greeter` | Consumer chooses system behavior and hardware; disk path, secrets, and `system.stateVersion` remain host-owned. |
| Account selection | `account.users`                                                                                       | Consumer selects account foundation per named user; `account.passwords` is separate and opt-in.                 |
| Home selection    | `home.niri`, `desktop-shell`, `desktop-apps`, `development`, `terminal`                               | Consumer chooses personal Home Manager features and `home.stateVersion`; integrated Home Manager is optional.   |

`core` is an optional host feature bundle, not a prerequisite for other profiles. Its matching Home Manager feature bundle, `core-home`, reaches users only through the explicitly activated `den.policies.core-home-to-users` policy. This keeps shared host-to-home routing visible and reusable. `workstation` remains a convenience bundle; hosts can select its individual features instead. `server` provides only its intentionally small reusable behavior. `disko` supplies reusable geometry but no device default: every host importing it must set native `disko.devices.disk.main.device` to its own disk path. Run `nix eval --impure --file tests/headless-composition.nix` to verify the server remains independent of workstation tuning and disk configuration.

Docker selections are independent: `dotnix.host.docker` enables the rootful daemon and rootless capability, `dotnix.account.docker` opts only that account into subordinate-ID allocation and linger, and `dotnix.home.docker` adds LazyDocker and Dive. Account settings do not add Docker group membership or grant extra root privileges. Selecting the daemon or `development` does not persist rootless state; select `dotnix.home.docker-persistence` for each intended account, with `host.home-manager`, `host.persistence` routing, and `home.persistence`, when `.local/share/docker` should survive cleanup. Selecting a Docker aspect does not select `development`.

Persistence follows the same scope separation: selected `systemPersistence` contributions route to the host's OS class, while selected `homePersistence` contributions route only to the relevant user's Home Manager class. `host.persistence` activates these routing policies and the NixOS `/persist` baseline; select `home.persistence` separately in each intended user's includes for that home's Home Manager baseline. Neither class registration nor `host.btrfs-root-reset` activates generic persistence. The root-reset policy adds only the Btrfs rollback service and initrd support; it does not enable Disko or generic persistence. For PipeWire, select `pipewire` on the host for audio services and in the intended user's scope for `.local/state/wireplumber`; do not import the entire host aspect tree into that user's home. Unselected features and unrelated users receive no contribution. Excluding the routing policies leaves the explicitly selected Persistence baselines available without routing feature contributions. Run `nix eval --impure --file tests/broad-compositions.nix` to check selected, unselected, unrelated-user and routing-disabled cases.

`mail` is an opt-in bundle; include it only for users who read mail. Select `dms`/`host.dms-greeter` or `noctalia`/`host.noctalia-greeter` explicitly on hosts that need a graphical session. New bundles should appear with their first real consumer, not from theory.

Personal identities also belong in the consumer's Home Manager class: set `programs.git.settings.user`, `programs.rbw.settings.email`, and, when selecting `maildir`, `programs.notmuch.settings.user.name` and `programs.notmuch.settings.user.primary_email` through their native options. Keep each `accounts.email.accounts.<name>.address` distinct; a Git, vault or primary mail address does not replace other account addresses. The retained `tests/broad-compositions.nix` fixture checks these independent identities and Home Manager activation evaluation.

## Channel choice

The consumer owns its nixpkgs channel. Set `dotnix.inputs.nixpkgs.follows = "nixpkgs"` in the consumer flake to make the library and its dependent inputs follow that channel. This is a flake-level choice; no per-host channel selector is provided by this library.

A local `path:/home/denis/projects/dotnix-aspects` input is development-only and not portable. Nix hashes the entire directory, including `.git`, untracked and ignored files; never keep private files in that library tree. After library changes, refresh only that input with `nix flake update dotnix`, or test current code with `--no-write-lock-file --override-input dotnix path:/home/denis/projects/dotnix-aspects`. Plain `nix flake lock` does not refresh an existing local snapshot.

## Secrets and authentication (consumer resources)

Secret identities, vault files, certificates and YubiKey mappings belong to the consumer. These features do not inspect `inputs.self` or infer paths from host/account names. Select host and home behavior separately, then set the native options for each target:

Greeters are host-wide and do not inspect account ordering, Home Manager selections, or user shells. For DMS, provide consumer-owned configuration homes and optional files through native `programs.dms-greeter.configHome` and `programs.dms-greeter.configFiles`. For Noctalia, provide consumer settings and assets through native `services.displayManager.noctalia-greeter.settings`, including direct wallpaper paths when needed. Selecting either host greeter leaves user homes unchanged; see the consumer template's greeter resource example.

| Capability                  | Selection                                                                                             |
| --------------------------- | ----------------------------------------------------------------------------------------------------- |
| Agenix host support         | `dotnix.host.age`                                                                                     |
| Agenix Home Manager support | `dotnix.home.age`                                                                                     |
| Host/home agenix-rekey      | `dotnix.host.age-rekey`, `dotnix.home.age-rekey`                                                      |
| System certificates         | `dotnix.host.certificates` plus native `security.pki.certificateFiles` or `security.pki.certificates` |
| OpenSSH server/client       | `dotnix.host.ssh`, `dotnix.home.ssh`                                                                  |
| GnuPG and GPG Agent         | `dotnix.host.gnupg`, `dotnix.home.gpg-agent`                                                          |
| RBW                         | `dotnix.home.rbw`                                                                                     |
| YubiKey hardware and PAM    | `dotnix.host.yubikey`, `dotnix.host.yubikey-pam`                                                      |

Set host and home `age.rekey` resources independently. For example, each target can choose its own `secretsDir`, `generatedSecretsDir`, `localStorageDir`, `hostPubkey`, `masterIdentities` and `storageMode`; no repository layout is assumed by the library. `age.identityPaths` is also a native option, set on the host or Home Manager target that owns each identity.

```nix
# Consumer host module
age.rekey = {
  secretsDir = ./. + "/secrets/hosts/myHost";
  generatedSecretsDir = ./. + "/secrets/generated/myHost";
  localStorageDir = ./. + "/secrets/rekeyed/myHost";
  hostPubkey = builtins.readFile ./secrets/hosts/myHost/host.pub;
  masterIdentities = [ ./secrets/masterkey.age ];
  storageMode = "local";
};
security.pki.certificateFiles = [ ./certificates/internal-ca.crt ];
security.pam.u2f.settings.authfile = ./secrets/u2f-mappings;
```

`dotnix.account.passwords` remains a separate per-account opt-in. It creates generated password secrets only when the consumer supplies native host rekey directories and a host public key; otherwise users remain mutable. YubiKey-PAM does not require agenix-rekey or desktop support. Its authfile is supplied through `security.pam.u2f.settings.authfile` or the NixOS PAM default. DMS uses the native U2F authfile only when one is configured.

GUI pinentry integrations are separately selectable as `dotnix.home.gpg-agent-gui` and `dotnix.home.rbw-gui`. `desktop-shell` does not select or override them; consumer module definitions can still override their native pinentry options.

## Theming

DMS/matugen is the single source of truth for the shell and its ~20 matugen template targets (bar, niri, GTK, Firefox, Qt5ct/Qt6ct, terminals …), recolored from the wallpaper palette. Stylix covers the targets matugen does not (GTK apps, Firefox, icons, cursors, fonts) and owns all NixOS `qt.*` options — its plain assignments always override `mkDefault`, which is why the former `qt-theme` aspect was removed as redundant. `dms-settings.nix` holds only real deltas against the pinned DMS rev; DMS itself manages schema defaults and `configVersion`. Keep per-app theme overrides out of aspects unless matugen/stylix provably cannot cover them.

Select `dotnix.host.stylix` on each host and `dotnix.home.stylix` in each home that needs it. Set consumer wallpapers through native NixOS or Home Manager `stylix.image` options; the feature does not infer an image from consumer repository paths. Theme and font defaults remain overridable through native Stylix options.

**Noctalia** is a second palette authority: it generates its own wallpaper-based palettes and must not double-theme apps — keep its built-in app templates off and let stylix own app themes. When the matugen bridge is wanted, feed matugen's output through `programs.noctalia.customPalettes` (`theme.source = "custom"`).

## Key Design Decisions

**Dendritic pattern** — Each file owns its feature across all configuration classes. Values are shared via `let`-bindings or flake-parts options, not `specialArgs`.

**Secrets with agenix-rekey** — Host and home secrets use separate `dotnix.host.age-rekey` and `dotnix.home.age-rekey` selections. Consumers provide their native `age.rekey` resource options; the library supplies no repository path defaults. `dotnix.account.passwords` remains a separate per-account opt-in and requires explicit host rekey resources.

**Den-native outputs** — the consumer evaluates Den host and user entities and imports `denful.dotnix` through `den.namespace`. This library defines reusable aspects and profiles; it does not build hosts or inject profiles.

## License

MIT
