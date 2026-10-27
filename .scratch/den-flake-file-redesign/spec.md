# Den / flake-file composition spec

Status: ready-for-agent

Readiness means the design is specified; it does not approve implementation. The user approved this design and canonical spec only. Implementation requires separate approval.

## Problem Statement

This aspect library needs safe consumer composition and clear long-term feature ownership. Importing its namespace must expose reusable capabilities without activating programs, services, persistence, or user configuration. Consumers own concrete hosts, accounts, resources, and selections, so selecting a feature for one target must not silently change another target or cross host, home, and account boundaries.

The current architecture groups some unrelated concerns and mixes library assembly, consumer integration, feature implementations, and tooling. Some domain features contribute to both NixOS and Home Manager; current Den scope behavior can route a user-selected OS contribution to its host. Other concrete ownership risks include user-wide account defaults, consumer-resource paths inferred from repository conventions, desktop integration side effects, and overlapping popup catalogs. These require a structural target, not only a PipeWire selection correction.

Existing useful behavior must remain available: optional persistence, explicit Btrfs root-reset behavior, rootful and rootless container support, popup backends, and compatible desktop compositions. Consumers must be able to use reusable defaults without inheriting personal account policy, disk layout, host providers, or another user's home configuration.

## Solution

Keep one public Den aspect namespace with nested host, home, and account selection catalogs. These are library conventions over native nested aspects, not a claim that Den itself provides an isolation barrier. Supported home selections must be transitively free of OS/account changes and host providers; host selections must not silently select user homes; account selections must affect only explicitly selected accounts. Optional profiles combine features while preserving the same role boundaries and remain transitively role-pure.

Separate library assembly, inert consumer integration and global contract registration, domain features, optional role-pure profiles, repository and optional consumer tooling, private helpers, consumer templates/recipes, and tests. Feature/domain ownership determines source organization. Co-locate each coherent feature's relevant host, home, account, persistence, input, and optional integration implementations. A small feature can stay in one file; complex features may use private local helpers. No per-class file split is mandatory. Avoid a catch-all core for unrelated features, group mail across terminal and desktop where ownership is coherent, and keep role out of filesystem taxonomy except where role-pure profiles clarify selection.

Provide an inert consumer adapter as the normal integration entry point. It registers Den integration, the public namespace, and library-owned global contracts such as the popup-launcher Quirk and relevant class metadata. Registration changes no program, service, Home Manager, persistence, or other feature behavior. The namespace remains separately importable and inert; namespace import alone does not register global Quirks. Consumers that need the global contracts use the adapter or explicitly register them. Keep optional development tooling separate from both feature inventory and consumer adapter.

Keep source discovery limited to module-shaped feature entry points. Private helper and data files must not be accidentally imported as modules. Separate library source organization from generated flake/bootstrap output; do not create recursion between the library producer, consumer adapter, and generator. The generated flake remains generated, and current source inputs and lock state are unchanged by this design. Do not add a registry or DSL to encode file taxonomy.

Feature dependencies and inputs stay co-located with, and library-captured by, their owning feature. Consumer-resource inputs remain explicit consumer responsibilities and are resolved through native options, such as persistence resource declarations, image options, or certificate-file options, rather than inferred from hardcoded consumer-repository paths. Namespace export does not forward input declarations. Unused feature inputs are acceptable; do not add a dependency registry or input-management factory. Account basics do not silently choose Fish, password generation, or vault conventions; retain those as explicit optional features, integrations, or consumer recipes.

Optional backend integration belongs to the owning feature and is selected explicitly. Firefox-specific Niri behavior belongs to Firefox's optional integration, not an unrelated extension of global Niri behavior. DMS integrations remain local to DMS. Do not require a global integration directory for every feature/backend pair or enable a backend accidentally.

Model DMS-like host support separately from per-user desktop runtime and per-user Polkit agent. Alice using DMS and Bob using Noctalia may share a host when prerequisites are explicit. Greeter configuration is host-wide and receives resources explicitly; it must not borrow configuration from the first alphabetically named user. Preserve compatible desktop combinations and report real same-target exclusivity clearly without imposing one desktop globally.

Keep host container-daemon configuration distinct from explicitly selected account settings such as subordinate UID/GID ranges and linger, and distinct from user tools. Preserve rootful and rootless capabilities without silently redesigning runtime behavior. Keep generic persistence classes/routing separate from explicit Btrfs root-reset machine policy; preserve both capabilities without disk operations or boot redesign.

Keep popup-launcher records in one authoritative data source, including command, size, and necessary backend-specific bindings. Renderers translate that source rather than maintaining separate mandatory full app-name/key maps. Preserve launchers for apps enabled through native Home Manager options even when no matching feature aspect was selected. A renderer omits a candidate with no binding for its backend and emits an actionable diagnostic; it must not force-enable an aspect or perform an unchecked mapping lookup. Do not claim that all producers are decentralized or that unknown bindings need no design. Do not add feature, pipe, or mapping frameworks for symmetry alone.

Support NixOS and Home Manager integrated into NixOS. Standalone Home Manager and nix-darwin are outside this support commitment. Preserve existing capabilities; public compatibility is not guaranteed. Normal NixOS and Home Manager options remain the customization surface, and defaults remain overridable unless a technical requirement justifies otherwise.

## User Stories

1. As a consumer, I want to import the library and discover its available features without activating programs, services, persistence, or user configuration, so that I can choose capabilities deliberately.
2. As a consumer, I want to select one feature without adopting an unrelated profile, so that I can compose only behavior I need.
3. As a consumer, I want to choose an optional profile that combines domain-related features, so that common combinations are convenient without making profiles a required tier.
4. As a consumer, I want to own the definitions and selections for my concrete hosts and users, so that reusable library defaults do not dictate my private topology.
5. As a consumer, I want a feature selected for one Home Manager user to configure only that user's home, so that another user's configuration remains unchanged.
6. As a consumer, I want a user feature selection not to activate its NixOS behavior on that user's host, so that home and host behavior remain isolated.
7. As a consumer, I want an explicitly selected host feature not to configure every user's home, so that host changes do not create unintended user changes.
8. As a consumer, I want to select system-wide prerequisites explicitly, so that a user feature cannot enable host behavior behind my back.
9. As a consumer, I want a clear failure when a missing prerequisite can be detected reliably, so that I can correct an incomplete selection.
10. As a consumer, I want to override opinionated defaults through normal module options, so that feature defaults can fit my system.
11. As a consumer, I want persistence contributions to affect only selected targets when the required persistence integration is selected, so that unrelated targets remain unaffected.
12. As a consumer, I want generic persistence and explicit root-reset behavior to remain separately selectable, so that I can use persistence without inheriting a disk layout or boot policy.
13. As a consumer, I want compatible desktop applications to compose and genuine exclusive behavior on one target to fail clearly, so that composition cannot silently choose a winner.
14. As a consumer, I want to use a feature with a library-captured dependency without duplicating it as a consumer root input when it needs no consumer-owned input data, so that dependency ownership stays clear.
15. As a consumer, I want to provide consumer-owned inputs and resources to features that explicitly resolve them from my configuration, so that those features use my intended data.
16. As a consumer, I want to generate a flake, evaluate the same selections before and after generation, and repeat generation without selection drift or further flake-text changes, so that generated configuration remains reproducible.
17. As a consumer, I want NixOS and integrated Home Manager to be the documented supported targets, so that I can use host-only features without Home Manager and know that standalone Home Manager and nix-darwin are not promised.
18. As an aspect library maintainer, I want each coherent feature's related contributions and selection boundary to stay local, so that changes remain easy to trace and maintain.
19. As an aspect library maintainer, I want checks to distinguish library-captured dependencies from consumer-owned inputs and prerequisites, so that failures identify which side owns each dependency.
20. As an aspect library maintainer, I want to reuse existing Den and flake-file mechanisms behind a small interface, so that the public contract stays understandable without parallel frameworks.
21. As an aspect library maintainer, I want Pareto checks at existing consumer seams to catch demonstrated selection, lifecycle, and conflict failures, so that regressions are detected without declaration-mirroring matrices.
22. As an aspect library maintainer, I want existing persistence, root rollback, popup, and compatible desktop capabilities documented and preserved, so that composition improvements do not silently remove useful behavior.
23. As a consumer, I want host, home, and account features to have distinct selection roles, so that selecting one role does not silently select behavior belonging to another.
24. As a consumer, I want an account selection to affect only the explicitly selected account, so that account policy does not spread to every user on a host.
25. As a consumer, I want host and home selections to remain independent for multiple users on one host, so that different users can choose different desktop sessions without accidental cross-user behavior.
26. As a consumer, I want the normal integration adapter to register library-owned global contracts without activating features, so that I can use shared contracts without hidden system configuration.
27. As a consumer, I want consumer-owned resources to be supplied through native configuration options, so that library features do not assume my repository layout.
28. As a consumer, I want host container-daemon behavior, account settings, and user tools to be independently selectable, so that container support preserves my intended rootful or rootless setup.
29. As a consumer, I want popup launchers for programs enabled through native Home Manager options to remain available, so that I do not need a matching library feature solely to expose an existing program.
30. As an aspect library maintainer, I want optional backend behavior to live with its owning feature, so that unrelated global features do not accumulate backend-specific configuration.
31. As an aspect library maintainer, I want feature entry points and private helpers to be distinguishable to source discovery, so that data and helper modules are not imported as public features accidentally.
32. As an aspect library maintainer, I want repository tooling and generated consumer bootstrap to remain separate from feature exports, so that consumer integration does not inherit development-only behavior.
33. As an aspect library maintainer, I want popup renderers to translate one authoritative record source with explicit missing-binding behavior, so that backend maps cannot drift or fail through unchecked lookups.
34. As an aspect library maintainer, I want source groupings to reflect domain ownership rather than cosmetic or mandatory role splits, so that related behavior remains cohesive without a catch-all module.

## Implementation Decisions

- Use one Den namespace with nested `dotnix.host.*`, `dotnix.home.*`, and `dotnix.account.*` catalogs. These are library selection conventions over native nested aspects, not a Den isolation guarantee. Each supported entry point must meet its declared role boundary transitively.
- Add an inert `flakeModules.default` consumer adapter for Den integration, namespace import, and library-owned global contract registration. Keep namespace import alone inert and separate from Quirk registration. Keep `flakeModules.devTools` optional and separate from feature inventory and consumer integration.
- Organize source around domain features and ownership layers. Co-locate coherent implementations, their library-captured inputs, persistence contributions, and optional feature-owned integrations. Small features may remain one file; helpers may be local for complex features. No mandatory per-class split, global integration hierarchy, taxonomy registry, or helper framework.
- Restrict discovery to module-shaped entry points. Keep private helpers/data outside automatic feature discovery or filter them explicitly. Keep generated flake/bootstrap responsibilities distinct from library source and consumer adapter, with no recursion. Do not update source inputs or lock state as part of the design.
- Resolve consumer-owned resources through native options. Do not infer resources from fixed paths in consumer repositories. Keep Fish defaults, password generation, and vault conventions outside basic account selection unless consumers explicitly select their corresponding feature/integration/recipe.
- Keep optional integration behavior explicit and with its owning feature. Preserve DMS host support, per-user DMS/Noctalia runtime choices, per-user Polkit handling, and greeter resources as separate responsibilities. Preserve both rootful/rootless container support and separate host daemon, account, and user-tool selections. Preserve generic persistence and explicit Btrfs root reset separately.
- Use one popup record source for command, size, and required backend bindings. Renderers translate it. Direct native Home Manager program enablement remains discoverable without selecting a matching aspect. A candidate missing a backend binding is omitted from that renderer with an actionable diagnostic, not an unchecked lookup, forced aspect inclusion, or an assumed universal producer model.
- Preserve current feature capabilities and compatible selections. Reject only genuine same-target exclusive conflicts. Do not impose global desktop exclusivity or redesign disk, boot, or container runtime behavior.

## Testing Decisions

- Use the public consumer-flake seam and existing evaluation and disposable generation CLI modes. Reuse existing broad-composition, desktop, persistence, VM, and template build coverage where relevant; do not duplicate checks already proving the same contract.
- Before broader implementation, use one full PipeWire reference example to prove selection, host/user isolation, one ordinary consumer override, and input/prerequisite ownership. Include user-only and explicit host-only behavior, an unrelated user, and a non-selected host. Use targeted effective-option observations of consumer targeting and the override contract; do not mirror declarations or impose a fixed count of observed fields.
- Use the existing compact native-hierarchy probe as bounded design evidence only. It showed that native nested selection survived export/import and kept the selected effective options scoped in a synthetic design. It is not a permanent hierarchy matrix, full feature proof, Home Manager activation build, or runtime proof.
- Keep one disposable Direnv lifecycle scenario for captured-input behavior: evaluate stable selections before/after generation and second generation, observe lockfile and auto-follow state, and keep it independent of private sibling consumers. Do not claim evaluation proves build or runtime behavior.
- Validate the identified two-user desktop risk using the existing desktop fixture. Add or extend a persistent regression only when an uncovered failure or risk justifies it; do not create a user/backend matrix. Reuse existing desktop and persistence checks, VM coverage, and template build.
- Add a test only when it targets a stated failure and existing checks miss it. Prefer evidence-backed focused evaluation or reproduction where appropriate. Do not add option-value declaration mirrors, tests per moved file, hierarchy snapshots, coverage quotas, exhaustive combination matrices, generic testing frameworks, duplicate build jobs, or a VM build per feature.
- Keep necessary existing project gates. Evaluation, build, and runtime evidence remain distinct; do not waive correctness or report one as proof of another.

## Out of Scope

- Production Nix changes or implementation approval in this documentation-only design publication.
- Changes to library source input pins or its lockfile, changes to real external/consumer repositories, and remote operations are out of scope. Approved disposable lifecycle fixtures may create or update only their own generated flake, inputs, and lock state. No commits/staging, live activation, disk operations, or boot/storage redesign.
- Public compatibility guarantees, compatibility shims, and migration-cost optimization. Long-term simplicity and clear ownership remain design goals.
- Standalone Home Manager or nix-darwin support, private host/account inventories, or consumer-specific repository paths and resource conventions.
- Automatically enabling programs, services, Home Manager behavior, persistence, account defaults, optional backend integrations, or desktop choices from library import or contract registration.
- A dependency registry, input-management factory, taxonomy DSL, universal integration framework, mandatory per-class module split, global desktop exclusivity rule, feature/pipe/mapping framework for symmetry, or test framework for architectural hierarchy.
- Publishing or approving implementation tickets in this documentation task. Earlier ticket drafts remain historical and must be replaced if implementation planning is later requested; implementation remains separately gated.

## Further Notes

The [approved target architecture](../../docs/plans/den-architecture-target.md) contains the illustrative directory sketch, ownership decisions, representative source mappings, and bounded native-hierarchy probe results. The [decision record](../../docs/plans/den-flake-file-redesign.md), [architecture assessment](../../docs/plans/den-flake-file-assessment.md), and [supplemental feature research](../../docs/plans/den-feature-research.md) preserve earlier evidence and note which recommendations are superseded. The prior [ticket draft](../../docs/plans/den-flake-file-tickets.md) is historical, not a current backlog. See the [local issue-tracker guidance](../../docs/agents/issue-tracker.md).

The native-hierarchy probe used a synthetic exported library namespace and consumer-imported alias. Namespace-only selection left host audio, home audio, an unselected sibling, account markers, and a second NixOS-only host unchanged. Explicit host selection enabled host audio without changing home or other hosts; explicit home/account selection affected only the selected user's home and account marker. This establishes bounded native nested selection behavior in the synthetic setup, not proof for all real features or runtime activation.

Historical source and probe evidence remains bounded to the pinned Den and flake-file revisions documented in the linked assessment and research. The earlier PipeWire and isolation probes remain relevant evidence, but neither proves the new adapter, full real feature behavior, a Home Manager activation build, or a DMS runtime. The current task approves the design/spec only; no production implementation or runtime verification is claimed.
