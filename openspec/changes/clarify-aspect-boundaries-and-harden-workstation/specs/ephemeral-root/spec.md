# Spec Delta

## Purpose

Defines the fail-closed contract for ephemeral Btrfs root rollback and the verifiable prerequisites for Hibernate with the existing swapfile layout.

## ADDED Requirements

### Requirement: Rollback protects root when recovery baseline is missing

Mandatory root rollback SHALL check prerequisites and the baseline snapshot before modifying `@root`. If the baseline is missing or rollback fails, the root mount SHALL be blocked.

#### Scenario: Baseline snapshot missing

- **WHEN** `@root-blank` is missing before rollback
- **THEN** `@root` remains unchanged and `sysroot.mount` does not proceed

#### Scenario: Rollback fails

- **WHEN** a required rollback step fails
- **THEN** the mount point is cleaned up and boot stops before the root mount

### Requirement: Rollback safely removes nested subvolumes

Rollback SHALL remove all nested subvolumes beneath `@root` in child-before-parent order and SHALL leave independent sibling subvolumes unchanged.

#### Scenario: Nested subvolumes

- **WHEN** `@root` contains subvolumes across multiple nesting levels
- **THEN** all children are removed before their parents, before `@root` is recreated from `@root-blank`

#### Scenario: Persistent siblings

- **WHEN** `@persist`, `@nix`, `@log`, or `@swap` are siblings of `@root`
- **THEN** these subvolumes and their sentinel contents remain unchanged

#### Scenario: Paths containing spaces

- **WHEN** a child subvolume has a path containing spaces
- **THEN** it is handled as a complete path, not truncated or confused with other entries

### Requirement: Rollback waits for the actual root device

Before mounting the Btrfs top level, rollback SHALL wait for the root device appropriate to the encryption layout and SHALL complete before `sysroot.mount`.

#### Scenario: Encrypted root

- **WHEN** the layout uses `cryptroot`
- **THEN** rollback starts only after the decrypted root device is ready

#### Scenario: Unencrypted root

- **WHEN** the layout uses the labeled device directly
- **THEN** rollback waits for that device without assuming that a nonexistent `cryptroot` unit exists

### Requirement: Rollback is selected only with ephemeral-root support

The rollback service SHALL NOT be installed when the impermanence aspect is not selected. Resume-device configuration SHALL NOT be inferred or enabled unless Hibernate/power-management selection explicitly requires it.

#### Scenario: No impermanence

- **WHEN** a host does not select impermanence
- **THEN** no ephemeral-root rollback service is installed

#### Scenario: No Hibernate selection

- **WHEN** a host does not select Hibernate/power-management support
- **THEN** no implicit resume device or offset is configured

### Requirement: Resume configuration cannot race destructive rollback

Before destructive rollback can remove the swapfile or alter the root snapshot state, the implementation SHALL investigate and test whether initrd resume can be active and whether resume has completed. If safe ordering is not established, rollback SHALL fail closed rather than risk modifying a live resume source. This is a required pre-implementation investigation, not an assertion that the current system has a proven race.

#### Scenario: Resume-before-rollback ordering

- **WHEN** Hibernate is configured with a Btrfs swapfile and ephemeral-root rollback is selected
- **THEN** a disposable test verifies resume completion precedes destructive rollback, or verifies rollback is prevented until that safety condition is guaranteed

### Requirement: Hibernate offset describes the provisioned swapfile

Documentation SHALL describe the resume offset as a provisioned property of the swapfile, specify the Btrfs map command instead of `filefrag`, and identify the resume backing device separately from the offset. Zram SHALL NOT be presented as a persistent Hibernate resume target.

#### Scenario: Determine swapfile offset

- **WHEN** a host is configured for Hibernate with a Btrfs swapfile
- **THEN** the documentation refers to `btrfs inspect-internal map-swapfile -r /swap/swapfile` and requires the actual offset of that provisioned swapfile

#### Scenario: Resume device and zram

- **WHEN** resume configuration is documented
- **THEN** the backing device and offset are separate values, and zram is not treated as a persistent resume target

### Requirement: Hardware diagnostics remain evidence-based

Audio and performance documentation SHALL NOT claim that unmeasured hardware tweaks have identified or fixed a cause, and SHALL protect host values and private log data.

#### Scenario: Investigate dock audio

- **WHEN** dock audio is investigated before and after hotplug or resume
- **THEN** sink, card, profile, port, default, and dock transport are distinguished without exposing private logs or credentials

#### Scenario: Investigate performance symptoms

- **WHEN** desktop, boot, resume, load, or battery sluggishness is reproduced
- **THEN** the diagnosis specifies relevant measurements for power profile, boot chain, and CPU/GPU/I/O/thermals, and marks the cause as unresolved without measurement data
