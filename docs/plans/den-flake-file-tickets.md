# Den / flake-file implementation ticket drafts

Status: HISTORICAL / SUPERSEDED. No tickets have been published. The following six-ticket draft is retained solely as historical planning context; it is not a current implementation backlog and is not proposed for approval. Replace it with a new breakdown only if implementation planning is later authorized. Implementation remains separately gated. This repository uses [local Markdown issue tracking](../agents/issue-tracker.md); keep drafts local until then.

## Delivery rules

- Each slice lands green at its existing meaningful check. If it changes an exported surface or the generated consumer, run the existing template NixOS toplevel build before that slice lands.
- Keep checks at the highest useful consumer seam. The PipeWire routing contract is wired once; reuse existing evaluation and build suites rather than adding duplicate jobs.
- Do not create a per-feature test matrix, declaration-mirroring option tests, per-feature VM builds, exact diagnostic-string snapshots, or cleanup-only tickets.
- Ticket dependencies below are a proposal, not approved blockers. Ticket 2 remains independently runnable; do not promise parallelism for slices that may touch overlapping surfaces.

## Draft tickets

### 1. P0 — Make PipeWire selection scope-safe

**Delivered behavior:** Supported library home selection for PipeWire carries no OS-class contribution and configures that user's existing WirePlumber persistence without silently enabling host PipeWire. Prefer separate explicit host/home selection surfaces while co-locating implementations where practical. Explicit host selection can enable host PipeWire without affecting a non-selected host or unrelated user's home.

**Acceptance:**

- First reproduce the pinned-version failure with the minimal scratch consumer; capture the old user-only selection activating host PipeWire.
- After reproduction, use the [supplemental pinned-source research](den-feature-research.md) to choose the supported scope shape. Do not use the global user-isolation flag as a drop-in fix: the counterprobe also removed Home Manager integration and own-user class routing. The contract applies to supported library home-selection surfaces, not arbitrary consumer-authored OS modules placed in user scope.
- Before broader migration, one compact consumer evaluation proves all four reference contracts: intended selection, host/user isolation, one overridable ordinary PipeWire setting, and input ownership.
- Reject wrong-scope host activation; observe the intended user's persistence, unchanged unrelated user, and host-only selection against a distinct non-selected host. Override one existing hardware-volume or codec-tuning default and observe the effective value. Keep current ordinary priority unless this representative override requires lowering that default's priority; do not test every setting.
- Record provenance in the same evaluation: PipeWire has no dedicated external feature input; the consumer owns the Den/NixOS/integrated Home Manager fixture and explicit persistence selection, while the persistence aspect owns its declared Impermanence dependency. This is not external captured-input lifecycle proof; Direnv remains ticket 2. Do not add a suite or build solely for override/provenance.
- Reuse a compact projection of the broad composition fixture and wire the routing contract once into the normal check path.
- Existing template toplevel build passes if the export or generated consumer is affected.
- If the pinned Den cannot safely express the contract without an unapproved update, stop and request a decision; do not ship a misleading success-only test.

**Test value:** Closes a verified host/user isolation defect that existing host-plus-user PipeWire selection does not expose.

**Blockers:** None to start. This is the first required implementation slice. Its complete four-part reference proof gates broader migration in tickets 3 and 4 and the final profile consumer in ticket 5.

### 2. P1 — Verify captured-input lifecycle with Direnv

**Delivered behavior:** A disposable generated consumer can select Direnv using its library-captured dependency without declaring a same-named consumer root input, while preserving the selected Home Manager behavior through flake generation.

**Acceptance:**

- Use one disposable fixture with bootstrap template, generated flake, evaluation, and a second generation.
- Compare relevant selections before and after generation; require no selection drift and no additional flake text diff on the second generation.
- Observe whether evaluation constructs the activation derivation, the selected feature is enabled, and the consumer root input is absent. Do not report this as a build or runtime proof.
- Keep the fixture independent of any private sibling repository. Observe and account for lockfile writes and existing-file auto-follow behavior; do not claim declaration movement alone propagates inputs.
- Run this as one supplemental external-input lifecycle scenario, not as a feature matrix. Run the template toplevel build if the generated consumer or export changes.

**Test value:** Complements the no-dedicated-input PipeWire case with one concrete external library input and resolves a known ownership ambiguity without inventing a dependency registry.

**Blockers:** None; independent of ticket 1's selection-interface decision.

### 3. P1 — Separate generic persistence from explicit root reset

**Delivered behavior:** Existing home/system persistence contributions remain reusable and opt-in, while Btrfs root rollback and its device/subvolume assumptions remain an explicit storage behavior rather than an unavoidable side effect of generic persistence.

**Acceptance:**

- Preserve current persistence class/policy routing and existing feature contributions.
- Preserve root rollback capability and its current behavior unless a separate decision authorizes changing it; do not add storage defaults, redesign boot, perform disk operations, or activate a system.
- Reuse current persistence evaluation and VM regression coverage. Add no VM build per feature.
- Show generic persistence can be selected without silently selecting root reset, and retain a focused observation for existing root-reset behavior.
- Run the existing template toplevel build if exported selection or template behavior changes.

**Test value:** Removes a real coupling between generic persistence and machine-specific Btrfs rollback while protecting existing behavior with existing checks.

**Blockers:** Requires ticket 1's complete reference proof before this broader persistence migration starts. Coordinate implementation if selection and persistence surfaces overlap.

### 4. P1 — Reject genuinely exclusive desktop collisions

**Delivered behavior:** Compatible desktop applications remain composable; selections that assign the same exclusive Niri behavior to the same target fail with an understandable diagnostic instead of silently choosing a winner.

**Acceptance:**

- Use the existing desktop composition suite and one representative negative same-target conflict.
- Confirm compatible DMS/Noctalia-related use cases that do not conflict remain selectable; do not impose one desktop globally.
- Check that the conflict fails for the relevant reason and provides useful guidance, without pinning exact error wording.
- Keep existing Niri keybind mirror tests unless replacement coverage is established and separately authorized. Run the template toplevel build if an export or generated consumer changes.

**Test value:** Covers a concrete conflict risk at the composition seam without enumerating every desktop combination.

**Blockers:** Requires ticket 1's complete reference proof before this broader composition migration starts. Coordinate implementation if selection and desktop surfaces overlap.

### 5. P1 — Prove optional profile composition in one consumer

**Delivered behavior:** A small reference consumer composes one optional domain profile with one independently selected feature without making either a library default.

**Acceptance:**

- Demonstrate library import remains inert, a feature can be used without an unrelated profile, and profiles are optional combinations rather than required tiers.
- Keep private hosts, users, and feature selections in the consumer fixture, not in library defaults.
- Reuse ticket 1's effective PipeWire override and input-provenance observations; add no duplicate override/provenance test.
- Reuse existing composition evaluations and the template toplevel build; do not create a new VM or broad configuration matrix.

**Test value:** Verifies the intended user-facing composition model end to end after the scope boundary is stable.

**Blockers:** Depends on ticket 1's scope-safe selection contract. No dependency on tickets 2–4 unless the chosen reference composition consumes their behavior.

### 6. P2 — Close documentation and final consumer gates

**Delivered behavior:** User-facing documentation points to current verification guidance, and the completed consumer path passes the existing project gates without restoring deleted planning artifacts.

**Acceptance:**

- Replace links to the deleted verification document with current approved documentation. Do not restore AGENTS or OpenSpec files, and do not change the parent-owned decision record.
- Run the project formatter on scoped changed files, the existing `nix flake check`, and the real template NixOS toplevel build on the integrated result. Do not format the whole repository or perform whole-repository cleanup. Ensure the compact routing check is invoked once and the lifecycle scenario remains disposable.
- Confirm generated template selections and stable second-generation output through ticket 2's single lifecycle scenario; do not add duplicate checks here.
- Do not add standalone cleanup unrelated to the consumer contract.

**Test value:** Confirms the existing CI gates cover integrated consumer behavior and prevents stale documentation from sending users to deleted instructions.

**Blockers:** Final acceptance follows tickets 1–5. Documentation-link work can begin independently; final gates should run after integration.

## Proposed dependency graph

- Ticket 1 → tickets 3, 4, and 5: its complete selection, host/user isolation, overridable-default, and input-ownership proof gates broader migration and profile integration.
- Ticket 2 remains independently runnable as the complementary external-input lifecycle scenario. No universal parallelism promise applies where implementation surfaces overlap.
- Tickets 1–5 → ticket 6 final integrated gates. Documentation-link replacement itself need not wait; final integration adds no duplicate tests.

Approve or revise this granularity and these blocker edges before tickets are created. Separate implementation approval is still required.
