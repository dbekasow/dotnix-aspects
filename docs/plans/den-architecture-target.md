# Den aspect library: approved target architecture

Status: approved design target; implementation is not authorized by this document. The directory names below are illustrative. Ownership boundaries and behavior contracts are normative; no exact filenames or per-class split are required.

The canonical behavioral contract is the [local composition spec](../../.scratch/den-flake-file-redesign/spec.md). This note records its structural design, representative mappings from current source, and the bounded native-hierarchy probe evidence.

## Illustrative source layout

```text
library/
  default.nix
  integration/
    consumer.nix
    contracts/
      persistence.nix
      popup-launcher.nix
  features/
    audio/
      pipewire.nix
    identity/
      accounts.nix
      vault/
      security-key.nix
    storage/
      persistence.nix
      btrfs-root-reset.nix
    session/
      niri/
      dms/
      noctalia/
    terminal/
      shells/
      multiplexers/
      popups/
    containers/
    development/
    mail/
    web/
      firefox/
        default.nix
        integrations/
          niri.nix
  profiles/
    host/
    home/
tooling/
  devshell.nix
  pre-commit.nix
  treefmt.nix
lib/ # private shared helpers, not feature-discovery entries
templates/
  minimal/
  workstation/
docs/
  recipes/
tests/
```

This sketch is not a mandate to create each directory or split every feature. A small feature can remain one file; a complex feature can own local helpers and optional integrations. Paths are examples, not export contracts. Do not create empty symmetry directories.

## Ownership and layer decisions

### Library assembly and consumer contract

- Keep one public Den aspect namespace. Its native nested aspect catalog exposes `dotnix.host.*`, `dotnix.home.*`, and `dotnix.account.*` selection conventions. These paths express intended role and ownership; they do not turn Den's native scope behavior into a general isolation guarantee.
- Export an inert `flakeModules.default` consumer adapter. It registers Den integration, the namespace, and library-owned global contracts, including the popup-launcher Quirk and relevant class metadata. Registration alone enables no programs, services, Home Manager configuration, persistence, or other feature behavior.
- Keep namespace import separately usable and inert. Namespace import alone does not register global Quirks. Consumers needing library-owned global contracts use the adapter or explicitly register those contracts; do not describe namespace import as contract registration.
- Keep optional `flakeModules.devTools` separate from feature inventory and consumer integration. It is repository/optional consumer tooling, not part of normal feature selection.
- Keep assembly, consumer adapter, and generation/bootstrap responsibilities separate. Source grouping must not cause recursion between the library producer, consumer adapter, and generator. The generated flake remains generated; the current source lock and inputs are not changed by this design.

### Feature and profile ownership

- Organize source by feature/domain responsibility, not a mandatory file per class. Co-locate the coherent host, home, account, persistence contribution, feature input, and optional integrations that belong to a feature. Keep a simple feature small; let complex features own local helper files.
- Supported home selections are transitively free of OS/account changes and host providers. Host selections do not silently select user homes. Account selections affect only explicitly selected accounts. These are required properties of supported selection entry points, not assumptions inferred from directory names.
- Profiles are optional and transitively role-pure. A profile may compose features for a role but cannot silently cross that role boundary.
- Keep a separate repository/consumer tooling layer, private helpers, consumer templates/recipes, and existing tests. Source discovery consumes only module-shaped feature entry files; private helper/data files are outside discovery or explicitly filtered. Do not invent a registry or DSL merely to encode the taxonomy.
- Remove the incoherent core catch-all as ownership becomes explicit. Group mail across terminal and desktop when that is a coherent domain. Keep role out of the filesystem except where role-pure profiles make selection clearer; architecture is not a cosmetic folder reshuffle.

### Inputs, resources, and integrations

- Feature inputs remain beside and library-captured by their owning feature. Consumer-resource inputs remain explicit and resolve through native options, not guessed paths under a fixed consumer repository layout. Namespace export does not forward input declarations. Unused feature inputs are acceptable; no dependency registry or input factory is needed.
- Basic account selection does not set Fish as default shell, generate passwords, or assume vault conventions. Those behaviors remain explicit optional features, integrations, or recipes.
- Put optional backend integration with the feature that owns it and require explicit selection. Firefox-specific Niri rules belong to Firefox's optional integration, not global Niri. DMS integration remains local to DMS. Do not require one global integrations directory for every feature/backend pair or accidentally enable a backend.
- Consumer-owned values such as age/rekey resources, Stylix images, and certificate files are configured through native feature options. Reusable feature logic must not infer them from hardcoded host/user repository paths.

### Cross-role examples

- Keep DMS host support separate from each user's DMS/Noctalia runtime and the per-user Polkit agent. Alice may choose DMS while Bob chooses Noctalia on one host when prerequisites are explicit. Greeter setup is host-wide and receives resources explicitly; it does not borrow the first alphabetically named user's home.
- Keep Docker host daemon configuration, account settings such as subordinate UID/GID allocation and linger, and per-user tools as distinct selections. Preserve rootful and rootless capability; do not silently redesign runtime behavior. The existing code enables auto subordinate-ID allocation and linger for all host users; it does not establish Docker group membership or additional root privileges.
- Keep generic persistence classes/routing distinct from explicit Btrfs root-reset machine policy. Preserve both capabilities without disk operations, boot redesign, or treating one storage layout as generic persistence.
- Keep compatible desktop selections composable. Fail only for a real exclusive collision on the same target, with an understandable error; do not enforce global desktop exclusivity.

### Popup data ownership

- Keep one authoritative popup record source for command, size, and required backend-specific bindings. Renderers translate the records instead of maintaining independent mandatory full app-name/key maps.
- Preserve support for apps enabled through native Home Manager options even when no corresponding feature aspect is selected. A renderer omits a candidate with no binding for its backend and emits an actionable diagnostic. It must not blindly look up a missing key or force-enable an aspect to manufacture a binding.
- This target does not assume every producer becomes decentralized, does not claim unknown backend bindings need no design, and does not justify a general mapping/pipe/feature framework for symmetry.

## Representative source evidence and target mapping

| Current evidence                                                                                                                                                                                                                                                                                                                         | What it shows                                                                                                                                                                                 | Target ownership                                                                                                                                                                                                                                           |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`modules/expose.nix`](../../modules/expose.nix)                                                                                                                                                                                                                                                                                         | Aspect discovery, `devParts`, generated flake output, input declarations, and template export meet in one assembly module.                                                                    | Separate library assembly and feature discovery from consumer adapter, repository tooling, templates, and generation/bootstrap responsibilities.                                                                                                           |
| [`modules/aspects/development/tooling/devshell.nix`](../../modules/aspects/development/tooling/devshell.nix) and [`modules/parts/devshell.nix`](../../modules/parts/devshell.nix)                                                                                                                                                        | Tooling input declaration and devshell implementation are split across the feature/tooling and `parts` layers.                                                                                | Keep optional/repository tooling distinct from feature inventory and consumer integration, with clear ownership rather than exporting it as a reusable feature by accident.                                                                                |
| [`modules/aspects/system/pipewire/pipewire.nix`](../../modules/aspects/system/pipewire/pipewire.nix)                                                                                                                                                                                                                                     | PipeWire has a NixOS implementation plus a WirePlumber home-persistence contribution in one aspect.                                                                                           | Keep coherent feature contributions together where useful, while exposing role-safe host and home selection entry points. Historical probes reproduced wrong-scope host activation from user-only selection; directory co-location alone is not isolation. |
| [`modules/aspects/system/impermanence.nix`](../../modules/aspects/system/impermanence.nix)                                                                                                                                                                                                                                               | Generic persistence classes/routing, Btrfs `@root` rollback/device assumptions, NixOS persistence, and unconditional Home Manager shared persistence are combined.                            | Keep generic persistence ownership and explicit Btrfs root-reset policy distinct, preserve both, and avoid turning storage policy into generic persistence behavior.                                                                                       |
| [`modules/aspects/core/users.nix`](../../modules/aspects/core/users.nix)                                                                                                                                                                                                                                                                 | Account setup enumerates every host user, selects Fish as default shell, and couples password/vault behavior to consumer host paths.                                                          | Separate account basics from explicitly selected shell, password-generation, and vault conventions; account selections affect only explicitly selected accounts.                                                                                           |
| [`modules/aspects/core/stylix.nix`](../../modules/aspects/core/stylix.nix) and [`modules/aspects/core/age-rekey.nix`](../../modules/aspects/core/age-rekey.nix)                                                                                                                                                                          | Reusable style/secrets features resolve consumer wallpaper and age resource files from assumed host/user repository paths.                                                                    | Resolve consumer-owned resources through native options and explicit consumer data, not a hardcoded repository convention.                                                                                                                                 |
| [`modules/aspects/desktop/apps/firefox.nix`](../../modules/aspects/desktop/apps/firefox.nix)                                                                                                                                                                                                                                             | Firefox selection also extends global `dotnix.niri` window rules.                                                                                                                             | Keep Firefox-specific Niri behavior as an optional, Firefox-owned integration.                                                                                                                                                                             |
| [`modules/aspects/desktop/shell/dms/dms.nix`](../../modules/aspects/desktop/shell/dms/dms.nix), [`modules/aspects/desktop/shell/dms/niri.nix`](../../modules/aspects/desktop/shell/dms/niri.nix), and [`modules/aspects/desktop/greeter/dms-greeter/dms-greeter.nix`](../../modules/aspects/desktop/greeter/dms-greeter/dms-greeter.nix) | DMS host module enables its systemd integration; a NixOS interaction disables the Niri Polkit agent; greeter config borrows the first alphabetically named host user's home.                  | Distinguish host support, per-user runtime, per-user Polkit handling, and host-wide greeter resources. The current source is static evidence; it is not a reproduced DMS runtime failure.                                                                  |
| [`modules/aspects/development/devops/docker/docker.nix`](../../modules/aspects/development/devops/docker/docker.nix)                                                                                                                                                                                                                     | Host Docker configuration includes rootless capability, while auto subordinate UID/GID allocation and linger are assigned across all host users; user tools and persistence are also present. | Separate host daemon, explicitly selected account settings, user tools, and persistence ownership while preserving current rootful/rootless capability. This evidence does not imply Docker group membership or extra root privileges.                     |
| [`modules/aspects/term/shell-ux/popup-launchers.nix`](../../modules/aspects/term/shell-ux/popup-launchers.nix), [`modules/aspects/term/shell-ux/herdr.nix`](../../modules/aspects/term/shell-ux/herdr.nix), and [`modules/aspects/term/shell-ux/tmux/tmux-popups.nix`](../../modules/aspects/term/shell-ux/tmux/tmux-popups.nix)         | Shared popup records coexist with separate Herdr and tmux name/key tables.                                                                                                                    | Use one authoritative record source for shared command/size and necessary backend bindings; renderers translate it and handle missing backend data safely.                                                                                                 |
| [`templates/dotnix/modules/parts.nix`](../../templates/dotnix/modules/parts.nix)                                                                                                                                                                                                                                                         | Consumer currently registers the popup-launcher Quirk; namespace import does not register the global Quirk registry.                                                                          | Move library-owned contract registration into the inert default consumer adapter, without claiming namespace import registers it or enabling features.                                                                                                     |

These mappings explain ownership pressure, not a committed exact migration sequence or requirement to create every illustrative path. They do not optimize for low migration cost or preserve public compatibility surfaces.

## Bounded native-hierarchy probe

A scratch probe at the pinned Den revision tested a synthetic library export and a consumer-imported namespace alias. Donor definitions included host audio (NixOS PipeWire enable), home audio (Home Manager Git enable), an unselected home sibling (Home Manager Helix enable), and an account marker. The consumer selected native nested aspects through the imported namespace. No source or lockfile changes were made.

| Scenario                             | Observed result                                                                                                                                                                                                     |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Namespace only                       | Host audio false; selected user's home audio false; unselected sibling false; both account markers empty; second host audio false; untouched NixOS-only host has no Home Manager.                                   |
| Explicit host selection              | Host audio true; home audio, unselected sibling, account markers, second host audio, and Home Manager on untouched host remain unchanged/false/empty.                                                               |
| Explicit home plus account selection | Selected user's home audio true and selected account marker set; other user's home/account unchanged; host audio, unselected sibling, second host audio, and Home Manager on untouched host remain false/unchanged. |

This shows native nested selection survives export/import and selected effective options remain scoped in this synthetic design. It is bounded evidence, not proof of every real feature, proof of the new inert adapter, a Home Manager activation build, full-system evaluation, DMS runtime behavior, or permission to add a permanent hierarchy matrix. The result informs the target; the probe is not a persistent test file.

## Related records

- [Canonical composition spec](../../.scratch/den-flake-file-redesign/spec.md) — behavior, stories, implementation and testing decisions.
- [Decision record](den-flake-file-redesign.md) — confirmed goals, prior decisions, and structural supersession.
- [Architecture assessment](den-flake-file-assessment.md) and [feature research](den-feature-research.md) — pinned source observations and historical recommendations.
- [Historical ticket drafts](den-flake-file-tickets.md) — superseded, unpublished planning context only.
