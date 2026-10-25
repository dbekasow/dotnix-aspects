# 03: Exercise the generated consumer and optional tooling end to end

**What to build:** Integrate the generator and optional development tooling so consumers can reproducibly bootstrap, evaluate, and regenerate a generated flake. The explicitly selectable Direnv feature uses the library-captured `direnv-instant` dependency. Formatter, hooks, and the development shell retain clear input and implementation ownership and remain outside feature export and the normal consumer adapter.

**Blocked by:** [02: Reorganize feature ownership and discovery around the confirmed criterion](02-feature-ownership-discovery.md).
**Status:** claimed
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] Optional `devTools` are selectable separately from the normal adapter and feature catalog; formatter, hooks, and development shell have clearly assigned inputs and implementation owners.
- [ ] An explicitly disposable consumer fixture selects Direnv and exercises bootstrap, generation, evaluation before and after generation, and repeated generation with stable selections and no drift in generated flake text.
- [ ] The fixture observes intended activated Direnv behavior before and after generation; `direnv-instant` comes from a library-captured input, not a same-named consumer root input. Input deduplication alone is not evidence of behavior.
- [ ] The lifecycle uses an explicitly specified temporary directory; fixture-owned input and lock writes are allowed. It never uses the current sibling-based script default or a real private consumer.
- [ ] Preserve existing auto-follow behavior when state already exists; do not change it for stylistic reasons. Library inputs and lock pins remain unchanged.
- [ ] Report evaluation and generated text as such; do not infer build or runtime evidence from constructing an activation derivation.
