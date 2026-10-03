# Spec Delta

## Purpose

Defines target aspect ownership and composition, intentional public API migration, optional integrations, headless host support, and exported module behavior.

## ADDED Requirements

### Requirement: Aspect settings have one clear owner

Settings SHALL live with the feature that owns them. The public surface SHALL retain necessary `dotnix.hosts` factory behavior, hostname registry keys, the `vaultReady` public-key gate, disk variants, and Tmux/Git collectors. Redundant custom option payloads SHALL be removed when replacement with native NixOS/Home Manager options or feature-owned settings produces a net simplification. Tmux SHALL activate only when selected, not merely because a declared Tmux option exists.

#### Scenario: Host configuration

- **WHEN** a consumer registers a host through `dotnix.hosts.<hostname>`
- **THEN** the factory uses that hostname as the registry key and keeps the existing necessary member, vault public-key, and disk-variant contracts

#### Scenario: Members-only host payload

- **WHEN** host configuration needs member information
- **THEN** it uses one members-only source of truth, with no duplicated runtime `dotnix.host` payload; a single `dotnix.members` source may be used if the implementation establishes it as the sole source

#### Scenario: Authorized SSH keys

- **WHEN** user SSH keys are configured for NixOS login
- **THEN** native `users.users.<name>.openssh.authorizedKeys.keys` is preferred over mirrored `profile.sshAuthorizedKeys`, with regression coverage for the migrated contract

#### Scenario: Declared but disabled Tmux

- **WHEN** the Tmux option is declared by a tool or module but Tmux itself is disabled
- **THEN** importing the tool does not activate Tmux or its integrations

### Requirement: Redundant custom profile options are removed with migration coverage

The API SHALL remove only redundant profile options such as unused `username` and `theme`, and SHALL migrate their consumers to feature-owned or native settings. Changes are intentional breaking API changes and SHALL be documented with a migration path. Required collectors and public gates SHALL remain available.

#### Scenario: Removed redundant options

- **WHEN** a consumer migrates from removed profile `username` or `theme` options
- **THEN** it configures the owning native or feature-specific option and focused evaluation verifies behavior

#### Scenario: Preserved collectors

- **WHEN** a consumer selects Tmux or Git repository features
- **THEN** required Tmux/Git collectors remain exported and collect contributor settings

### Requirement: DMS-specific Niri integration is optional

The Niri configuration SHALL remain evaluable and usable without DMS; DMS IPC bindings SHALL take effect only when DMS is selected. Polkit ownership SHALL follow the selected shell rather than being disabled unconditionally.

#### Scenario: Niri without DMS

- **WHEN** only Niri is selected, with no DMS option
- **THEN** Niri evaluates without a missing DMS option and without active DMS IPC bindings

#### Scenario: Niri with DMS

- **WHEN** Niri and DMS are selected
- **THEN** DMS IPC bindings are available and Polkit behavior follows the selected shell's integration

#### Scenario: Niri with Noctalia

- **WHEN** Niri and Noctalia are selected, but DMS is not
- **THEN** the general Niri configuration does not depend on DMS and the Home Manager integration is class-correct

### Requirement: AI Tmux integrations follow actual selection

Workmux and Tuicr Tmux contributions SHALL take effect only when the corresponding tool and Tmux are selected. Selecting a tool without Tmux SHALL evaluate without Tmux option errors.

#### Scenario: Tmux without AI tools

- **WHEN** Tmux is selected without Workmux or Tuicr
- **THEN** no Workmux or Tuicr package references or bindings are contributed

#### Scenario: Tool and Tmux

- **WHEN** Workmux or Tuicr is selected together with Tmux
- **THEN** the corresponding Tmux integration is available and the tool is configured

#### Scenario: Tool without Tmux

- **WHEN** Workmux or Tuicr is selected without Tmux
- **THEN** the tool is configured without Tmux contributions or missing-Tmux-option errors

### Requirement: Headless VPS composition avoids workstation assumptions

The library SHALL provide an explicit reusable headless composition path, such as `core+server` or a narrower documented base. It SHALL not implicitly import workstation laptop sysctls/zram, audio, Bluetooth, UPower/thermald, Hibernate/Disko defaults, workstation boot-systemd assumptions, or automatic root disk choices. Bootstrap root and bootloader configuration SHALL be supplied by the caller or fixture. Generic `core` SHALL remain an explicit work/admin profile, not a universal server baseline.

#### Scenario: Headless server profile

- **WHEN** a consumer selects the documented headless/server composition
- **THEN** it evaluates without workstation-only performance, audio, Bluetooth, power-management, Hibernate, or automatic disk-layout settings

#### Scenario: Caller supplies boot setup

- **WHEN** a consumer evaluates the headless composition
- **THEN** root and bootloader configuration comes from explicit caller or fixture configuration

#### Scenario: Wheel password default

- **WHEN** a host uses the wheel group without an explicit hardware-gated opt-out
- **THEN** wheel login requires a password, independently of `vaultReady`

#### Scenario: Distinct placeholder hosts

- **WHEN** two distinct placeholder host registrations are evaluated against the reusable composition
- **THEN** both evaluate using independent hostname registry keys without hardware-specific identities or assumptions

### Requirement: Exported modules preserve argument contract and error provenance

Exported function modules SHALL preserve module-argument metadata and additional module arguments, preserve caller input precedence and caller `self`, and retain the original file location in export errors.

#### Scenario: Additional module argument

- **WHEN** a consumer passes an additional `_module.args` argument to an exported module
- **THEN** the module can receive that named argument

#### Scenario: Caller and library inputs

- **WHEN** the caller and library provide the same input name
- **THEN** the caller value takes precedence, caller `self` remains caller `self`, and unset inputs fall back to library values

#### Scenario: Export error location

- **WHEN** export validation reports an error for an invalid module
- **THEN** the diagnostic points to the original source file location
