# Den / flake-file composition spec

Status: ready-for-agent

This is the canonical local spec. Readiness describes specification state only; implementation requires separate user approval. This spec defines consumer behavior, not a prescribed source layout or exact Den API.

## Problem Statement

Feature maintainability and safe composition are coequal goals for this aspect library. Importing the library should expose reusable capabilities without activating programs, services, persistence, or user configuration. Consumers own concrete hosts, users, and feature selections, so selecting a feature for one target must not silently affect another target.

The current pinned Den behavior violates that boundary: selecting PipeWire for one integrated Home Manager user also activates its NixOS configuration on the host. Existing successful evaluations do not catch this leak. A global user-isolation setting is not a safe shortcut: the counterprobe also removed integrated Home Manager and own-user routing.

Input ownership and generated-flake behavior need equally precise contracts. Library-captured dependencies and consumer-owned inputs resolve through different paths; generation also interacts with lockfiles and auto-follow behavior. Existing capabilities, including optional persistence, Btrfs root rollback, popup behavior, and compatible desktop composition, must remain available without forcing unrelated behavior or storage assumptions onto consumers.

## Solution

Provide reusable aspects and optional, domain-oriented profiles. Consumers own concrete hosts, users, selections, and personal defaults. Selecting a feature affects only its declared scope; a home selection does not silently enable host behavior or affect another user's home, and a host selection does not implicitly configure every user's home. System-wide prerequisites are explicit, and missing prerequisites fail clearly where they can be checked reliably.

Keep Den's namespace as the single export surface. Keep related feature contributions local and together unless a split is needed to enforce scope or isolate genuinely different behavior. Reuse existing Den, NixOS, Home Manager, and flake-file mechanisms behind a small consumer-facing interface. Do not add wrappers, alias exports, mandatory profile tiers, dependency registries, input-management factories, or abstractions for parity. Selective inclusion of unused feature inputs is not a prerequisite.

Existing NixOS and Home Manager module options remain the normal customization surface. Defaults are overridable unless a technical requirement justifies a force. Profiles are optional domain combinations, not required inheritance tiers. Preserve existing capabilities; public compatibility is not guaranteed, but removals or materially changed behavior require an explicit decision. Supported targets are NixOS and Home Manager integrated into NixOS; NixOS hosts do not need Home Manager to use host-only features. Standalone Home Manager and nix-darwin are outside this support commitment.

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

## Implementation Decisions

- Before broader migration, the first implementation slice must prove four contracts in one small consumer evaluation: correct feature selection, host/user isolation, one overridable ordinary PipeWire default, and input ownership. The supported library home-selection entry point carries no OS-class contribution. Prefer explicit host/home selection surfaces and co-locate implementations where practical. This contract does not cover arbitrary consumer-authored OS modules placed in user scope. If the pinned version cannot express the boundary without an unapproved input update, stop for a decision.
- Use PipeWire as the first scope reference. A user-only selection must not activate host PipeWire; explicit host-only selection may activate host PipeWire without affecting a non-selected host or unrelated user's home. Observe the selected user's existing WirePlumber persistence route and one ordinary consumer override of a hardware-volume or codec-tuning default. Keep ordinary priority unless that representative override requires otherwise.
- Keep library-captured dependency ownership distinct from consumer-provided inputs. PipeWire has no dedicated external feature input: the reference consumer owns its Den/NixOS/integrated Home Manager setup and explicit persistence selection, while the persistence aspect owns its declared Impermanence dependency. Record this provenance in the same small evaluation; it does not prove external captured-input lifecycle behavior. Direnv is the supplementary library-captured dependency lifecycle example because its dependency is absent from consumer root inputs. Keep the existing flake-scope dependency where needed; it supplies pipeline context, not a rewrite of lexical dependency capture. Do not claim universal dependency forwarding or add a dependency/input-management factory.
- Den's named providers and policies are not general OS-class isolation barriers. The global user-isolation setting is not a drop-in fix: the counterprobe removed integrated Home Manager and own-user routing. Do not add a generic scope-guard framework or gratuitous pipes to solve this feature boundary.
- Retain existing optional persistence classes and routes. Separate generic persistence from explicit Btrfs root rollback and its storage assumptions only as needed. Preserve both capabilities; do not redesign boot, storage, or defaults, and do not perform disk operations or activation.
- Keep the explicit consumer popup-launcher Quirk declaration: namespace import does not register `den.quirks`. Do not add a setup-module export, classes, or Pipes without a concrete need.
- Keep compatible desktop applications composable. Reject only a demonstrated exclusive collision on the same target; do not enforce a global one-desktop rule or require an exact diagnostic string.
- Keep Den and flake-file versions pinned. The current flake-file auto-follow behavior depends on existing input-file state; inspect and test that state before changing explicit follows. Do not change inputs or the lockfile as part of this spec.

## Testing Decisions

The public consumer-flake interface is the seam. Use composition evaluation and the template-generation CLI lifecycle as observation modes. Reuse existing broad-composition, desktop, persistence, and VM coverage plus the template consumer build; add only scenarios that expose distinct failures.

- First-slice proof: use one compact consumer evaluation for feature selection, host/user isolation, one ordinary override, and input provenance. Check user-only, host-only, selected-user, unrelated-user, and non-selected-host behavior. The negative assertion against wrong-scope host activation is required. Observe one effective hardware-volume or codec-tuning value changed by the consumer; do not mirror declarations. Record in the same fixture that PipeWire has no dedicated external feature input, the consumer owns the Den/NixOS/integrated Home Manager setup and explicit persistence selection, and the persistence aspect owns its declared Impermanence dependency.
- Captured-input lifecycle: add one complementary Direnv scenario using a disposable template bootstrap, generated flake, evaluation of stable selections, and a second generation. Confirm no selection drift or additional flake-text diff; observe lockfile writes and auto-follow state. Keep it independent of private sibling consumers. Do not infer input propagation from declaration placement.
- Persistence and desktop: reuse current persistence evaluations and VM regression coverage; verify generic persistence remains optional and explicit root-reset behavior retains its existing capability. Add no VM build per feature. Reuse the desktop composition suite and add one negative observation for a real exclusive same-target conflict; require an understandable failure, not exact wording.
- Project gates: reuse the existing flake check and affected template toplevel build. Wire the compact routing contract once into the normal check path; do not duplicate checks or suites. Run formatter only on scoped changed files after implementation.
- Pareto limits: do not add declaration-mirroring option tests, per-feature or invalid-combination matrices, coverage quotas, duplicate builds, or a VM build per feature. Effective-option observations are allowed only to prove an actual consumer contract. Evaluation does not prove runtime behavior; a build does not prove hardware behavior or system activation.

### Acceptance Criteria

- Importing the namespace alone leaves feature behavior inert.
- A single user selection configures that user, not another user or the NixOS host; explicit host selection has its declared host effect and does not bleed to a non-selected host or user.
- The PipeWire first-slice evaluation reproduces the old failure before implementation, rejects wrong-scope activation, preserves intended host/user persistence behavior, demonstrates one ordinary consumer override, and records feature-input and prerequisite ownership before broader migration.
- Features remain selectable without unrelated profiles, and profiles remain optional combinations. System-wide prerequisites are explicit; missing prerequisites fail clearly when reliably detectable.
- Existing capabilities remain available, including generic persistence, root rollback, popup behavior, and compatible desktop combinations.
- The Direnv disposable lifecycle confirms captured-input behavior without a same-named consumer root input, stable selections through generation, and no additional diff after a second generation. Evaluation is not reported as a build or runtime proof.
- Only genuine same-target incompatibilities fail, with an understandable diagnostic.
- After implementation, scoped formatting, the existing `nix flake check`, and the affected template consumer toplevel build pass. No whole-repository formatting or cleanup is required; live system activation is neither required nor authorized.
- Ticket granularity and blocking edges receive parent-user approval before implementation tickets are published. Implementation remains separately gated by user approval.

## Out of Scope

- Production Nix changes during this planning and spec-publication phase; the behavior changes specified above require separate implementation approval.
- Flake input updates, source lockfile changes, consumer-repository changes, live activation, disk operations, and boot/storage redesign remain outside the specified implementation scope unless separately approved. Disposable lifecycle fixtures may create and update their own lockfiles.
- Compatibility guarantees for the redesigned public interface; standalone Home Manager or nix-darwin support; private host, user, or selection inventories.
- A dependency registry, input-management factory, parallel wrappers or module factories, mandatory profile tiers, selective input pruning as a prerequisite, exhaustive test matrices, per-feature VM builds, or generic scope-guard framework.
- Implementation-ticket publication until the user approves ticket granularity and blocking edges. Canonical local spec publication is explicitly authorized; implementation requires separate approval.
- Restoring historical deleted AGENTS or OpenSpec artifacts. The separately approved new minimal AGENTS setup is not restoration of deleted content.

## Further Notes

Readiness does not authorize implementation. The six implementation ticket drafts remain unapproved and unpublished; ticket granularity and blocking edges need user approval. Local Markdown tracker setup is complete, so there is no tracker-setup blocker. See the [local issue-tracker guidance](../../docs/agents/issue-tracker.md).

Historical evidence is bounded: the broad-composition evaluation passed 30 checks but did not expose the PipeWire scope leak; a focused probe showed user-only PipeWire selection activating the host service. The isolation counterprobe stopped that activation but also removed integrated Home Manager and own-user routing. The Direnv probe constructed an activation derivation without a same-named consumer root input; it did not prove a build or runtime behavior. No full flake check, template build, or consumer-generation lifecycle was run during planning. See the [decision record](../../docs/plans/den-flake-file-redesign.md), [architecture assessment](../../docs/plans/den-flake-file-assessment.md), [supplemental Den feature research](../../docs/plans/den-feature-research.md), and [implementation ticket drafts](../../docs/plans/den-flake-file-tickets.md).

The source research is bounded to pinned Den revision `7594405b45e0ce2d5a418fe104a26e17f6b1dd8f` and flake-file revision `4ccd0b92aee0943b94324ec4c39949df1769f123`; it is not a complete Den feature survey. No newer API, production change, input update, consumer migration, system activation, disk operation, or implementation verification is claimed.
