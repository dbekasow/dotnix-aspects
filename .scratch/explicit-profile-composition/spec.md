# Explicit profile composition and a coherent consumer template

Status: ready-for-agent

Design authority: [ADR 0005](../../docs/adr/0005-keep-machine-and-personal-selections-explicit.md).
The user confirmed the target design and the testing seams. This specification
is ready for implementation planning; neither this status nor publication
authorizes implementation, activation, or consumer migration.

## Problem Statement

Consumers need to reuse configuration across an author's private and work
machines, family desktop machines, and headless servers without inheriting
unrelated machine or occupant decisions. The current profile layer separates
host, home, and account selections, but some convenience bundles still hide
boot and storage policy, a personal application remainder, and agent tooling.

Selecting a workstation currently also selects a particular bootloader,
disk layout, persistence, root reset, tuning, location services, and hardware
authentication support. Merely removing the storage members is insufficient:
the shared power feature itself assumes a resume device and machine-specific
sleep and thermal policy. The personal desktop application bundle and redundant
desktop selectors also obscure which applications a consumer actually wants.

The development and terminal bundles implicitly select AI or agent-related
features. Meanwhile, the desired general review tool is Hunk rather than Tuicr,
and the review entry should work consistently in Tmux and Herdr instead of
being a Tmux-only shortcut. The consumer template also carries application
launch keys without selecting the corresponding applications.

These are selection and ownership problems, not a need for another profile
framework or occupant archetypes.

## Solution

Keep the existing role-qualified, optional, domain-oriented profiles. Make
machine-specific boot, storage, tuning, location, and authentication choices
explicit in each consumer host. Make personal application mixes and AI or agent
features explicit consumer selections. Retain a useful general development
bundle and replace its review tool with Hunk from the existing package source.

Provide the same selected Hunk entry in the existing shared Tmux and Herdr
popup menu. Keep the Herdr terminal variant as subtraction from the shared
terminal profile, without suppressing a now-independent Workmux selection.

Publish a small, coherent consumer template that explicitly selects Ghostty,
Firefox, and Thunderbird, owns its application launch keys, and demonstrates
Btrfs/LUKS, a bootloader, and persistence without enabling root reset by default.
Keep other application preferences and the separate live consumer migration
outside this effort.

## User Stories

1. As a consumer maintainer, I want the workstation profile to describe reusable workstation equipment, so that selecting it does not choose my machine's storage model.
2. As a host owner, I want to choose my bootloader independently, so that an existing installation does not acquire a different loader through a convenience bundle.
3. As a host owner, I want to choose disk layout, persistence, and root reset independently, so that I remain responsible for installation and data-retention policy.
4. As a host owner, I want performance tuning to remain individually selectable, so that a workload-specific policy is not applied to every workstation.
5. As a host owner, I want location services and YubiKey support to be explicit selections, so that general equipment selection does not imply those policies.
6. As a maintainer of different hardware, I want general power management without Intel, deep-sleep, or encrypted-resume assumptions, so that the same feature can be reused on different machines.
7. As a host owner, I want platform defaults to govern sleep, power-key, lid, and battery actions unless I override them, so that the library does not invent another universal power policy.
8. As an owner of a hibernating machine, I want to supply its native resume and power configuration explicitly, so that preserving hibernation is a deliberate migration choice.
9. As a consumer maintainer, I want to compose Alacritty, Ghostty, Anki, and Handy individually, so that a personal application remainder is not presented as a general desktop requirement.
10. As a consumer maintainer, I want one clear graphical foundation selector per role, so that I do not have to distinguish redundant desktop aliases from graphical behavior.
11. As an occupant who develops software, I want a convenient editor, version-control, automation, and review bundle, so that making agent tools explicit does not require rebuilding the whole toolchain by hand.
12. As an occupant, I want AI tools and repository packing to require explicit selection, so that general development does not opt me into an agent-oriented workflow.
13. As an occupant using Pi, I want its reusable persistence contribution to remain selectable, so that making it explicit does not remove that capability from the library.
14. As an occupant reviewing changes, I want Hunk to replace Tuicr in the development bundle, so that I use my chosen review tool without selecting an agent workflow.
15. As a consumer maintainer, I want Hunk from the already declared numtide package source, so that this replacement needs neither a new input nor a different package provenance.
16. As an occupant, I want to select Hunk independently of development, so that I can review changes without the rest of that toolchain.
17. As an occupant using either Tmux or Herdr, I want the same review entry in the shared popup menu, so that changing multiplexers does not change how I reach review.
18. As an occupant without Hunk selected, I want no Hunk popup entry, so that menus do not advertise an unavailable tool or leak another user's selections.
19. As an occupant, I want the direct cr abbreviation to start Hunk, so that review also works outside a multiplexer.
20. As an occupant, I want a single shared popup access path rather than a separate Tmux review shortcut, so that the two multiplexer workflows remain consistent.
21. As an occupant adopting Hunk, I want its own defaults rather than a speculative translation of Tuicr configuration, so that unsupported comment or export semantics are not promised.
22. As a Tmux user, I want Workmux to remain an explicit optional tool, so that selecting ordinary terminal ergonomics does not create an agent-pane workflow.
23. As a consumer maintainer, I want Workmux's Tmux prerequisite documented without automatic enablement or a new assertion, so that responsibility for the combination stays with my composition.
24. As a Herdr user, I want the terminal variant to exclude Tmux and Sesh without duplicating the terminal member list, so that shared terminal improvements still apply.
25. As a consumer maintainer, I want an explicitly selected Workmux not to be silently discarded by the Herdr variant, so that explicit choices remain visible even when I must satisfy their prerequisites myself.
26. As a Niri user, I want general window, workspace, and session keys without fixed application choices, so that my consumer owns which applications its keys launch.
27. As a maintainer of several occupants, I want home selections, account settings, and host selections to stay independent, so that a home tool selection does not change account privileges or affect another home.
28. As a template consumer, I want Ghostty, Firefox, and Thunderbird explicitly selected, so that its terminal, browser, and mail launch keys refer to applications it supplies.
29. As a template consumer, I want those applications without the entire personal app remainder or an office-suite bundle, so that the reference configuration stays small and understandable.
30. As a template consumer, I want an explicit Btrfs/LUKS, bootloader, and persistence example, so that the starter configuration remains concrete rather than an unrelated collection of fragments.
31. As a template consumer, I want root reset to be a documented opt-in, so that copying the reference does not prescribe discarding root contents on every boot.
32. As a template consumer, I want tuning, location, and YubiKey support documented as optional additions, so that a small reference does not silently restore the choices removed from workstation.
33. As a maintainer, I want focused consumer-level assertions in the regular check run, so that a green formatting-only check cannot hide stale behavior tests.
34. As a maintainer, I want the unchanged copied template evaluated and built against the library under test, so that replacing it with a reduced fixture cannot hide integration defects.
35. As a headless consumer maintainer, I want server composition to remain independent of workstation features, so that this redesign does not introduce desktop, disk, or power dependencies into a server.
36. As a family-computer maintainer, I want graphical applications without development or agent tools, so that profiles remain useful for different occupants without person-shaped presets.
37. As an existing consumer owner, I want breaking selector changes and power-policy consequences clearly documented, so that I can plan a separate migration without automatic edits to my configuration.
38. As an occupant, I want unrelated application settings and personal review data left alone, so that a profile redesign does not become an unrequested preferences or data migration.

## Implementation Decisions

### Existing composition model

- Preserve the host, home, and account catalogs and their independent selection
  scopes. Profiles remain optional includes-based compositions, not mandatory
  tiers, host-to-home routing, or occupant archetypes.
- Use existing features, native configuration options, and the shared popup
  mechanism. Do not add a profile framework, generic dependency enforcement,
  hardware detection, or public configuration switches for this redesign.
- Keep individual features available unless explicitly retired below. Other
  profile memberships and unrelated feature behavior remain unchanged.

### Workstation and power

- The workstation profile contains exactly the existing boot-baseline,
  Bluetooth, network, network-Wi-Fi, PipeWire, and power features.
- Bootloader, disk layout, generic persistence, root reset, performance tuning,
  geolocation, and YubiKey support are not workstation members. Consumers may
  select them explicitly for the relevant host.
- General power management retains Upower, power-profiles-daemon, and its
  existing diagnostic tools. It does not prescribe Intel thermald, a resume
  device, a deep-sleep mode, custom sleep permissions or delay, custom
  power-key or lid actions, or custom battery thresholds and actions.
  These follow platform defaults or explicit native host configuration.
- In particular, the feature must not arrange automatic hibernation. This does
  not introduce a new switch or globally prohibit an explicitly configured
  host from using hibernation.
- Keep the existing performance feature's tuning unchanged and individually
  selectable; its redesign is not part of this work.

### Application and development selection

- Retire the desktop-apps bundle and both role-qualified desktop selectors.
  Do not keep compatibility aliases. Graphical foundation selectors and
  individual application features remain available.
- Personal application compositions belong to the consumer. Keep office,
  browsers, mail, core, shells, and the terminal sub-bundles except for the
  explicitly specified membership changes.
- Remove the home llm-agents, ai-tools, and repomix selections from development.
  Remove Workmux from terminal UX. Their individual features remain available;
  removing an implicit selection is not deletion of the capability or its
  package input.
- Development retains its other editor, VCS, and automation selections and
  replaces Tuicr with Hunk. Retire the Tuicr feature rather than introducing
  a second default review tool or a compatibility alias.

### Hunk and shared review access

- The selected review tool is modem-dev Hunk. Publish the role-qualified
  home.hunk feature and source its package from the existing
  numtide/llm-agents.nix package provider, consistent with existing package
  selection conventions. Do not use a direct nixpkgs Hunk selection, add an
  input, or update an input pin to accomplish this.
- A home may select Hunk independently of development or either multiplexer.
  Its selection must not automatically enable Tmux, Herdr, an agent, or host
  overlay/cache settings.
- The direct Fish abbreviation cr invokes Hunk. Use Hunk's defaults rather than
  attempting to translate Tuicr's theme, typed comments, identity configuration,
  export introduction, or other tool-specific settings.
- Register one Hunk review entry with dispatch key r in the existing shared
  popup mechanism. It is available through Prefix+o, then r in Tmux and Herdr,
  and only for a home selecting Hunk, directly or through development.
- Render the selected package's executable through the existing popup adapters;
  do not depend on an unrelated globally installed binary. Keep existing popup
  geometry conventions and duplicate-key validation.
- Remove the old dedicated Tmux Prefix+r review binding. Do not add a new
  separate Herdr-only shortcut or a new popup framework.
- Unselected homes receive no Hunk package or menu entry. Do not infer selection
  merely because the package exists in an input or an overlay.

### Workmux and the terminal variant

- Ordinary terminal and terminal-UX composition no longer select Workmux.
  Ordinary terminal composition still selects Tmux and Sesh.
- The Herdr terminal variant continues to reuse terminal and add Herdr while
  excluding Tmux and Sesh. Remove Workmux from its exclusions once Workmux is
  no longer pulled in by the shared terminal tree.
- Document that Workmux requires Tmux for its intended workflow. Do not add an
  assertion, silently deactivate an explicit Workmux selection, or enable Tmux
  automatically. Existing conditional Tmux bindings remain conditional.
- Selecting the Herdr variant alone yields no Workmux. Selecting Workmux
  explicitly beside that variant remains effective, even though the consumer
  is responsible for the documented prerequisite. This does not change the
  authoritative Tmux and Sesh exclusions.
- Consumers wanting both multiplexers continue to compose the ordinary
  terminal profile with the Herdr feature rather than trying to override the
  Herdr variant's authoritative exclusions with another include.

### Niri and the consumer template

- Move application-specific Niri launch bindings to the consumer. The reusable
  Niri feature retains general window-management, workspace, and session keys
  without assuming particular terminal, browser, mail, or file-manager choices.
- The template explicitly selects Ghostty, Firefox, and Thunderbird as individual
  home features. It does not select an entire office bundle or restore the
  removed personal app remainder for their sake.
- The template owns matching application launch bindings. Any retained
  file-manager binding must also refer to an application supplied by its
  selections. General Niri behavior and independent host/home selection remain
  intact; do not enable host compositor support merely through a home choice.
- Keep the existing Niri, DMS, greeter, and hardware reference rather than
  redesigning the desktop stack simultaneously.
- Keep the explicit Btrfs/LUKS, bootloader, and persistence example. Root reset,
  performance tuning, geolocation, and YubiKey support are not selected by
  default; document them as optional additions with their prerequisites and
  consequences. Do not change disk geometry, encryption/enrollment mechanics,
  or the reference hardware as part of this profile effort.
- Resource identities, installed state versions, and native disk-device choices
  remain consumer-owned. Do not generate credentials or touch a live system.

### Documentation and migration

- Update the profile inventory, composition examples, review-tool access, and
  template guidance to describe the implemented target rather than retired
  selectors or Tmux-only review access.
- Explain that adopting general power management does not preserve a previous
  custom hibernation recipe automatically. Hosts needing it must provide their
  native resume and power policy explicitly.
- Apply selector changes throughout library-owned executable examples and
  affected tests. Do not modify the separate live consumer as part of this
  work, and do not add aliases solely to conceal its pending migration.

## Testing Decisions

### Primary seam: the existing consumer adapter and its final outputs

The user approved small consumer fixtures through the shipped default adapter,
observed at final NixOS and Home Manager configurations and generated
multiplexer/compositor configuration. This is the main shared seam for profile,
feature, role-isolation, and menu contracts. Prefer a small reusable fixture and
focused scenarios over another test framework or restoration of the removed
broad composition suite.

Tests must assert observable behavior and meaningful absence. Do not assert
private helper shapes, source filenames, a particular number of includes, or
mere declaration of an aspect when its emitted configuration is the contract.
Use an otherwise equivalent unselected fixture as the baseline where upstream
platform defaults matter. Preserve explicit consumer overrides.

Required focused scenarios:

1. Workstation on a host with consumer-owned boot and filesystem configuration
   supplies its retained equipment while adding no disk layout, reset service,
   generic persistence baseline, performance tuning, geolocation, or YubiKey
   selection. It does not replace the consumer's loader or resume choices.
2. Power-only and workstation selections retain their intended services but do
   not introduce the removed sleep, thermal, resume, key, lid, or battery policy
   relative to the platform baseline. Explicit native host settings remain
   effective. The performance feature remains directly usable with its existing
   behavior when explicitly selected.
3. The retired desktop and Tuicr selectors are absent, while graphical,
   individual applications, retained domain bundles, Hunk, and the explicitly
   selectable AI/agent-related features remain available.
4. Development yields Hunk and its retained general toolchain without implicit
   AI tools, repository packing, Pi persistence contribution, or Workmux.
   Inspect selected configuration and persistence contributions where relevant;
   absence of a package alone cannot prove absence of a persistence-only feature.
5. Hunk works as a standalone home selection without activating a multiplexer
   or host support. The direct abbreviation uses the selected Hunk executable.
6. Tmux and Herdr homes selecting Hunk receive exactly one review entry on r;
   homes without Hunk receive none. The rendered command uses the selected
   package, and the old dedicated Tmux review binding is absent. Force the
   generated configuration so lazy evaluation cannot hide a missing argument
   or duplicate dispatch key.
7. A two-user host proves Hunk visibility and Herdr exclusions do not leak
   between homes. One home can select terminal-herdr while another retains
   ordinary terminal with Tmux and Sesh. Home selections do not alter account
   shells, extra groups, or the host's user set relative to a control fixture.
8. Terminal-herdr alone has neither Tmux, Sesh, nor Workmux; ordinary terminal
   retains Tmux/Sesh without Workmux. Explicit Workmux beside terminal-herdr
   remains installed/configured, without enabling Tmux or adding a new
   prerequisite assertion. The documented prerequisite is not replaced by a
   fabricated expectation that this unsupported combination runs successfully.
9. The reusable Niri selection retains general bindings but no fixed application
   launch keys. The template supplies the agreed application bindings itself.
   Existing independent host/home compositor and per-user shell behavior stay
   intact.
10. Headless server composition remains independent of workstation hardware,
    graphical configuration, and disk selection. A graphical family-home
    composition needs no development or agent selection.

Prior art exists in the headless composition, headless security, and Niri/DMS
fixtures, as well as the review's two-user terminal fixture. Reuse their public
entity and output patterns, not private helper implementation or historical
claims that a fixture once passed.

### Secondary seam: the unchanged copied consumer template

Instantiate the published template against the current library checkout, using
its real hardware reference and unmodified host/home composition. Evaluate its
system derivation and complete a build of its system closure. Do not replace its
host configuration with the reduced consumer-generation fixture or substitute
a hardware stub for this acceptance gate.

Assert that Ghostty, Firefox, and Thunderbird are actually selected, their
launch bindings match, and the optional root-reset, tuning, geolocation, and
YubiKey features are not default selections. Preserve the explicit example
storage configuration. Avoid treating disabled enable flags alone as a complete
proof of executable absence; inspect effective package selection when that is
the relevant question.

### Execution gates and known baseline limitations

- Integrate the focused contract assertions into the regular flake check run;
  keeping them as uninvoked scripts is insufficient. Keep existing formatting,
  generated-flake consistency, and pre-commit checks.
- Run the formatter, the complete flake check with checks built, the affected
  headless and Niri/DMS tests, and the real template evaluation/build. Report
  derivation evaluation separately from completed builds and runtime tests.
- The unchanged Niri/DMS test currently refers to the obsolete finalConfig
  option. A scratch-only change of its five accesses to finalConfigFile passed
  all 48 assertions against the pinned upstream. Correct those stale test
  accesses when updating affected tests; do not weaken assertions or report
  the unmodified baseline as green.
- A timeout, unavailable dependency, or inaccessible VM capability is an open
  verification result, not a pass. Preserve reproduction commands and logs.
- No live activation, host disk operation, or expansion of device access is
  permitted by these gates. The existing Btrfs VM test is relevant evidence for
  later root-reset use, but this effort does not change its reset implementation
  or require inventing a new storage test harness.

## Out of Scope

- Implementing or activating changes merely because this spec is ready-for-agent.
- Migrating the separate dotnix consumer or automatically preserving its native
  machine policy on its behalf.
- Implementing independent target flakes, a lazy catalog, dependency-isolation
  generation, or any other part of the separate loading redesign.
- Adding, updating, or removing flake inputs, changing input pins or lockfiles,
  or making Hunk come from the separate dbekasow/llm-nix repository.
- New profile frameworks, occupant archetypes, compatibility aliases, generic
  selection/dependency enforcement, hardware detection, or new power switches.
- Redesigning the performance tuning, disk geometry, root-reset algorithm,
  encryption/enrollment behavior, desktop shell, greeter, or reference hardware.
- Changing Firefox homepages, extensions, Bitwarden policy, or other unrelated
  application defaults; changing the existing Git/RBW identity contract.
- Translating Tuicr-specific comment/export semantics into Hunk, migrating or
  deleting occupant-created review data, or adding review-agent automation.
- Adding another browser, terminal, office, learning, or dictation bundle to
  restore the removed personal app remainder indirectly.
- Fixing unrelated findings such as terminal-monitoring categorization or the
  opaque missing-identity diagnostic.

## Further Notes

- [ADR 0005](../../docs/adr/0005-keep-machine-and-personal-selections-explicit.md)
  records the confirmed design. The existing role catalogs and consumer-owned
  occupant composition remain governed by
  [ADR 0001](../../docs/adr/0001-split-aspects-into-role-catalogs.md) and
  [ADR 0002](../../docs/adr/0002-occupant-composition-stays-consumer-owned.md).
  This spec replaces the affected membership decisions in the earlier
  [profile namespace redesign](../profile-namespace-redesign/spec.md), not its
  entire namespace or composition contract.
- [ADR 0006](../../docs/adr/0006-generate-independent-target-flakes.md) describes
  a separate accepted target for loading and generation. This spec neither
  supersedes it nor depends on its unimplemented interfaces. Reconcile the
  test entry point if that work lands first without silently absorbing its
  implementation into this effort.
- Source inspection during review used library HEAD e10383d. Both locked
  nixpkgs and numtide/llm-agents.nix exposed modem-dev Hunk 0.25.0; the user
  explicitly chose the latter provider. Availability is not a reason to update
  pins, and the version number here is evidence rather than a new version lock.
- The complete library flake check passed during review. The real template
  derivation evaluated, but its build timed out after 420 seconds. The Btrfs VM
  derivation evaluated, but its build timed out after 300 seconds before runtime;
  the session had no exposed KVM device. These results are historical baseline
  evidence, not acceptance of the future implementation.
- Review artifacts were retained under `/tmp/dotnix-verification-0vX4Db/` and
  `/tmp/agents-behavior-verify.mRnmjo/`. They are temporary supporting evidence,
  not durable dependencies of the implementation or its tests.
- Only specification publication is authorized at this stage. Implementation
  approval and any ticket decomposition are separate next steps.
