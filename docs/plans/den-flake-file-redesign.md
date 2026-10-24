# Den and flake-file redesign: decision record

Status: shared understanding confirmed and planning phase approved by the user, including the Pareto test strategy. This document is not an approved implementation spec. Historical OpenSpec changes are evidence only; deleted files are not restored by this plan.

## Goals

- Serve the author's own configurations first, while remaining reusable without private assumptions.
- Prioritize feature maintainability and safe composition.
- Adopt Den and flake-file mechanisms only when their benefit is demonstrated; feature coverage is not a goal.

## Boundaries

- The library provides reusable features and optional profiles.
- Concrete hosts, users, and personal selections belong to consumers.
- Supported targets are NixOS and Home Manager integrated into NixOS. Standalone Home Manager and nix-darwin are outside this effort's support commitment.
- Existing public interfaces may be redesigned without compatibility guarantees. This does not authorize editing separate consumer repositories.
- Existing capabilities are preserved by default. Removal or materially changed behavior requires an explicit decision.
- Existing NixOS and Home Manager options and aspect composition are the normal customization interface. Additional library options need a concrete domain requirement.
- Selected features may provide opinionated defaults that consumers can override through normal module options. Forced values require a justified technical necessity.
- Profiles are optional, domain-oriented combinations, not mandatory inheritance tiers. Shared subprofiles remain allowed.
- The initial design targets the currently pinned Den and flake-file versions. Investigate newer APIs only for concrete gaps; input updates require separate justification and approval.

## Selection and isolation

- Importing the library registers available behavior; it does not activate programs, services, or user configuration.
- A feature can be selected without adopting an unrelated profile. Genuine dependencies remain allowed.
- Selecting a home feature for one user must not configure another user's home. Necessary system-wide prerequisites must be explicit in the feature contract.
- Consumers explicitly select system-wide prerequisites; user features must not silently activate host behavior. Missing prerequisites produce understandable errors where they can be checked reliably. An explicitly selected profile may assemble both sides.
- Activation isolation is mandatory. Inputs of unused features may initially be present; selective input inclusion is an investigation, not an architectural prerequisite.
- Genuinely incompatible selections must fail with an understandable error, not silently select a winner. Compatible features remain composable.

## Verification

- Consumer tests must cover intended behavior and absence of unintended behavior on unrelated targets.
- Representative negative tests must cover relevant failures for genuinely incompatible selections; do not enumerate every invalid combination.
- A successful evaluation or build alone does not prove correct targeting.
- Acceptance must demonstrate inert library import, standalone feature selection without unrelated profiles, correct targeting with unaffected unrelated users and hosts, overridable defaults, and understandable failures for reliably checkable missing prerequisites and genuinely incompatible selections.
- Flake generation must be reproducible, with no additional diff on repeated generation.
- Final gates include the project formatter, nix flake check, and the affected template consumer build. Live system activation is not required or authorized.

### Pareto test strategy

- Prioritize risk reduction and maintenance value, not option counts, coverage quotas, or a literal 80/20 test count.
- Use a small set of representative consumer scenarios to verify the central selection, composition, and host/user isolation contracts. Acceptance criteria do not imply a per-feature test matrix.
- Do not write declaration-mirroring option-value tests that merely repeat configured values. Do not retest upstream NixOS or Home Manager behavior.
- A targeted effective-option query is allowed as an observation point for a consumer contract, such as identifying which user actually receives a selected feature.
- Add regression tests for real bugs at the highest meaningful integration seam.
- Reuse existing evaluations and builds rather than duplicating checks of the same property.
- Each additional test needs a concrete failure it can usefully detect; negative tests focus on relevant failure modes rather than exhaustive invalid combinations.

## Delivery sequence

- The approved planning phase produces a source-backed architecture assessment, then a spec and prioritized implementation ticket drafts. Do not change production configuration in this phase. Review ticket granularity and blocking edges with the user before publishing tickets.
- Classify mechanisms as already appropriate, concrete improvement, targeted investigation, or deliberately unused. Verify technical claims against pinned sources rather than deciding every mechanism in advance.
- Assess historical planning for relevance without restoring deleted artifacts or maintaining conflicting plans.
- The first implementation slice must use a small reference consumer and a representative existing feature to prove selection, host/user boundaries, overridable defaults, and input ownership before broader migration. Choose the feature from code evidence.
- Implementation requires a separate approval.

## Planning artifacts

- [Architecture assessment](den-flake-file-assessment.md): current evidence, pinned dependencies, focused runtime probes, and proposed improvements.
- [Supplemental Den feature research](den-feature-research.md): composition, context, data flow, and the isolation counterprobe.
- [Consumer composition spec](../../.scratch/den-flake-file-redesign/spec.md): canonical local spec with the intended contract and Pareto verification seams.
- [Implementation ticket drafts](den-flake-file-tickets.md): proposed slices and blocking edges; not published or approved for implementation.

## Planning verification

- Source-backed assessment, supplemental research, spec, and six ticket drafts are complete. Independent review approved the corrected drafts with no remaining findings.
- The existing broad-composition evaluation passed all 30 checks. A separate focused probe reproduced user-only PipeWire selection enabling the host service, including execution of the reproduction documented in the assessment.
- The Direnv probe constructed the Home Manager activation derivation without a same-named consumer root input. The isolation counterprobe blocked the PipeWire leak but also removed expected Home Manager and own-user integration.
- Scoped Prettier checks passed for the glossary and all planning documents. No full flake check, template build, or consumer-generation lifecycle run was performed in this planning phase.
- No production implementation, source input/lock update, system activation, or consumer migration was performed. No tickets were published and no commits were created.
- Local agent guidance and the canonical local spec are published. Tracker setup is complete; implementation ticket drafts remain unpublished pending user approval of granularity and blocking edges, and implementation remains separately gated.

## Still open

- User approval of ticket granularity and dependencies before publication.
- Separate implementation approval after planning.
