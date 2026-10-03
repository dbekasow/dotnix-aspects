# Spec Delta

## Purpose

Defines how selected desktop, Tmux, and tool aspects activate optional integrations, and how exported modules preserve their arguments and caller precedence.

## ADDED Requirements

### Requirement: DMS-specific Niri integration is optional

The Niri configuration SHALL remain evaluable and usable without DMS; DMS IPC bindings SHALL take effect only when DMS is selected. Disabling the Niri Polkit agent SHALL apply independently.

#### Scenario: Niri without DMS

- **WHEN** only Niri is selected, with no DMS option
- **THEN** Niri evaluates without a missing DMS option and without active DMS IPC bindings

#### Scenario: Niri with DMS

- **WHEN** Niri and DMS are selected
- **THEN** DMS IPC bindings are available and the Niri Polkit agent remains disabled

#### Scenario: Niri with Noctalia

- **WHEN** Niri and Noctalia are selected, but DMS is not
- **THEN** the general Niri configuration does not depend on DMS

### Requirement: AI Tmux integrations follow shared selection

Workmux and Tuicr Tmux contributions SHALL take effect only when the corresponding tool is selected and Tmux context is available. Selecting a tool without Tmux SHALL evaluate without Tmux option errors.

#### Scenario: Tmux without AI tools

- **WHEN** Tmux is selected without the Workmux or Tuicr aspect
- **THEN** no Workmux or Tuicr package references or bindings are contributed

#### Scenario: Tool and Tmux

- **WHEN** Workmux or Tuicr is selected together with Tmux
- **THEN** the corresponding Tmux integration is available and the tool is configured

#### Scenario: Tool without Tmux

- **WHEN** Workmux or Tuicr is selected without Tmux context
- **THEN** the tool is configured without Tmux contributions or missing-Tmux-option errors

### Requirement: Public aspect and class contracts remain stable

Reorganizing aspect files SHALL preserve public aspect names, module classes, and subprofiles, and SHALL introduce no runtime dependencies through file moves alone.

#### Scenario: Existing aspect import

- **WHEN** a consumer selects an aspect or subprofile that was previously exported
- **THEN** the same public name and module class remain available

### Requirement: Exported modules preserve their argument contract

Exported function modules SHALL preserve module-argument metadata, additional module arguments, and precedence between caller and library inputs.

#### Scenario: Additional module argument

- **WHEN** a consumer passes an additional `_module.args` argument to an exported module
- **THEN** the module can still receive that named argument

#### Scenario: Caller and library inputs

- **WHEN** the caller and library provide the same input name
- **THEN** the caller value takes precedence, caller `self` remains caller `self`, and unset inputs fall back to library values
