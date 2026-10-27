# Den feature research: composition, context, and data flow

Status: historical supplemental planning evidence. Two read-only researchers examined primary sources at the pinned Den revision. The parent checked critical recommendations with focused consumer evaluations. This is not an exhaustive Den audit, implementation approval, or a proposal to adopt every mechanism.

> **Superseded recommendation:** Earlier advice here against a setup module and to keep popup-launcher Quirk registration consumer-owned is superseded by the approved inert default consumer adapter, which registers library-owned global contracts without enabling features. Namespace import alone still does not register Quirks. Pinned source facts and historical probes below remain valid. See the [approved target architecture](den-architecture-target.md) and [canonical spec](../../.scratch/den-flake-file-redesign/spec.md).

## Question and version boundary

Which Den mechanisms improve feature locality and safe consumer composition in this library, and which add complexity without demonstrated value?

All Den links below use revision `7594405b45e0ce2d5a418fe104a26e17f6b1dd8f`, matching the library lock. No dependency was updated. The scope is NixOS and integrated Home Manager, with concrete hosts, users, and selections owned by consumers. Existing capabilities are preserved; Pareto testing is mandatory.

## Conclusions

1. Give mixed features explicit host and home selection surfaces. A supported home selection must not carry an OS-class contribution. Related implementations can remain together; a second implementation or universal wrapper is not required. Start with PipeWire, whose user-only selection currently activates host PipeWire.
2. Keep existing persistence classes and routing policies. Their optional delivery is a concrete reason to use custom classes. Separate generic persistence selection from explicit Btrfs root-reset behavior; do not redesign storage.
3. Document the existing popup-launcher Quirk declaration and input-context requirements as part of the consumer contract. Namespace import alone does not register the global Quirk. No new contract-module export or dependency registry is justified yet.

These recommendations apply to supported library selection surfaces. They do not promise to make arbitrary consumer-authored OS modules safe when placed in a user scope, or to repair Den globally.

## Mechanism assessment

| Mechanism                         | Verified semantics and relevance                                                                                                                                             | Decision for this effort                                                                                                                  |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| `includes` and profiles           | Includes compose behavior in the current resolution scope; profiles can remain ordinary optional combinations.                                                               | Keep. Do not replace includes with policies merely for uniformity.                                                                        |
| Named `provides`                  | Providers create cross-entity inclusion edges; they are not an independent OS-class isolation barrier. Certain names are special, so arbitrary facet naming is not harmless. | Keep explicit user-targeted selection. Use optional facets only for a concrete feature need, with documented naming.                      |
| Policies                          | A registry entry is not activation. Context predicates and effects differ from ordinary aspect inclusion; policy routing cannot be assumed to stop direct OS-class emission. | Retain real persistence routes; no blanket scope-guard framework.                                                                         |
| `excludes`                        | Exclusions propagate down the subtree, match identity prefixes, and cannot be reversed by a child. Excluding a node is not filtering only its unwanted class.                | Useful consumer escape hatch, not the primary interface for choosing a feature's home half.                                               |
| `den.default` and schema includes | Defaults participate across entity scopes. Schema includes establish broad behavior for a kind, not per-feature opt-in.                                                      | Keep infrastructure deliberate. Do not inject desktop or other optional feature behavior globally.                                        |
| Schema `isolated`                 | Stops implicit subtree absorption, but also changes the ordinary cross-scope delivery paths. The focused probe below breaks integrated Home Manager and own-user delivery.   | Not a drop-in fix or silent template default. Revisit only with a concrete need and a complete routing design.                            |
| Parametric aspects                | Required function arguments affect dispatch, deferral, and entity fan-out. A missing argument is not necessarily an immediate helpful error.                                 | Use when actual host/user context varies; avoid adding context parameters for stylistic consistency.                                      |
| `flake-scope` battery             | Supplies pipeline context via `resolve`/`pipelineOnly`; does not rewrite lexical closures.                                                                                   | Keep where currently needed, with explicit provenance. Do not treat it as isolation or replace it with speculative injection helpers.     |
| `hostname` battery                | Host-derived, narrowly scoped behavior.                                                                                                                                      | Existing use fits the contract.                                                                                                           |
| `host-aspects` battery            | Projects host aspect content into user resolution.                                                                                                                           | Do not make it a library default; explicit targeted selection remains clearer.                                                            |
| Pipes                             | Den data-plane effects, not merely ordinary Nix list composition. Assembly and inheritance have nontrivial semantics.                                                        | Retain existing necessary data aggregation; no fleet-wide collect/broadcast or new pipe chains without a concrete consumer.               |
| Quirks                            | Named data contracts require a global registry declaration; the namespace has no equivalent automatic Quirk-registry export.                                                 | Keep popup-launcher as a documented contract. Reuse current consumer scenarios rather than inventing a test per Quirk.                    |
| Custom classes and forwarding     | Classes represent module contributions; routes/forwarding deliver them. They solve a different problem from shared data aggregation.                                         | Keep persistence contributions as classes. Do not replace them with Quirks or add forwarding adapters without an actual destination need. |
| Conflict checks                   | `filterBy` examines one aspect, not a set of peer selections. Argument collision policy is not feature exclusivity.                                                          | Prefer existing module assertions and one representative same-target conflict check. No generic exclusion registry.                       |

## Critical source findings

### Composition and routing

- Host OS materialization merges class buckets over an isolation-bounded scope subtree. This explains why an OS class emitted while resolving a user aspect reaches the host. Sources: [materialization](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/nix/lib/aspects/fx/edges/materialize.nix#L31-L46), [scope walk](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/nix/lib/aspects/fx/scope-walk.nix#L16-L37), and [documented scope caveats](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/docs/src/content/docs/explanation/where-config-lands.mdx).
- Provider keys matching entity kinds or reserved prefixes are special. Ordinary named providers match host/user identity; cross-providers result in inclusion in the current scope. They must not be advertised as a cure for OS-class leakage. Sources: [provider interpretation](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/nix/lib/aspects/fx/aspect/provide.nix#L20-L52), [reserved keys](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/nix/lib/aspects/fx/aspect/provide.nix#L150-L157), [policy application](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/nix/lib/aspects/fx/policy/apply.nix#L43-L47).
- Inline conditional guard context is not interchangeable with full policy context. Do not prescribe a `user == null` guard without checking argument dispatch and the actual guard context. Source: [conditional context construction](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/nix/lib/aspects/fx/handlers/compile-conditional.nix#L121-L145).
- Excludes use identity-prefix constraints, inherited through descendants. Sources: [constraint matching](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/nix/lib/aspects/fx/handlers/constraint.nix#L10-L24), [inheritance](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/nix/lib/aspects/fx/handlers/constraint.nix#L90-L98).
- Upstream isolation tests cover custom child entities and explicit routes. Reading these tests does not prove integrated user/Home Manager delivery works unchanged. Source: [entity-isolation tests](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/templates/ci/modules/features/entity-isolation.nix).

### Context, Pipes, and registry ownership

- Parameter binding examines required arguments and can defer or fan out aspect evaluation. Source: [argument binding](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/nix/lib/aspects/fx/handlers/bind.nix#L26-L53), [dispatch](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/nix/lib/aspects/fx/handlers/bind.nix#L188-L264).
- Pipe builders create effects. Independent effects and inherited/local pools have semantics that can duplicate or shadow data; adding a pipe is not a free abstraction. Sources: [builders](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/nix/lib/policy-effects.nix#L296-L350), [assembly](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/nix/lib/aspects/fx/assemble-pipes.nix#L603-L608), [inheritance](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/nix/lib/aspects/fx/assemble-pipes.nix#L918-L937).
- Namespace structural keys include schema/classes but not a global Quirk registry. Namespace class registration has no parallel Quirk forwarding. Sources: [namespace types](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/nix/lib/namespace-types.nix#L7-L13), [namespace export/import](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/nix/lib/namespace.nix), [Quirk registry](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/modules/options.nix#L164-L178).
- `flake-scope` supplies pipeline context; `host-aspects` projects the host tree. Neither changes the library dependency already bound by an outer Nix closure. Sources: [flake-scope](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/modules/aspects/batteries/flake-scope.nix), [host-aspects](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/modules/aspects/batteries/host-aspects.nix), and the [captured-input consumer probe](den-flake-file-assessment.md#captured-library-input-versus-consumer-input).

## Focused counterprobe: isolated users

The composition researcher identified `den.schema.user.isolated` as a candidate, explicitly without integrated-user runtime proof. The parent evaluated a minimal consumer twice with `isolated = false` and `true`. Both use the pinned namespace, one NixOS host, and Alice with classes `[ "user" "homeManager" ]`. The host supplies state version and Alice's home; Alice selects PipeWire, sets `user.description`, and enables Git in her Home Manager configuration. The observations force the Home Manager activation derivation where that integration exists.

Command shape: `nix eval --impure --json --expr '<consumer fixture with den.schema.user.isolated = isolated>'`. This was a scratch evaluation, not a persistent source change or build. Exact result:

```json
{
  "defaultScope": {
    "hasHomeManager": true,
    "homeActivationConstructs": true,
    "homeGit": true,
    "hostPipewire": true,
    "ownUserClassRoutes": true
  },
  "isolatedUserScope": {
    "hasHomeManager": false,
    "homeActivationConstructs": null,
    "homeGit": null,
    "hostPipewire": false,
    "ownUserClassRoutes": false
  }
}
```

An initial unguarded observation failed with `attribute 'home-manager' missing`; the second probe explicitly recorded absence instead of attempting to read that configuration. The flag blocks the unwanted implicit OS delivery in this fixture but also removes expected integration. This does not prove isolation can never be configured with explicit routes; it disproves treating the flag alone as a drop-in fix.

## Consequences for the plan

- First slice: scope-safe supported host/home selection for PipeWire, with its existing optional persistence route preserved. Choose the public selection names and shape from source evidence; do not introduce global schema isolation as a shortcut.
- Keep related class contributions co-located where practical. A class-pure user-facing selection is the goal, not a mandatory directory/class split across all features.
- Document that arbitrary OS-class content authored by consumers remains subject to the pinned Den scope semantics. Supported library selections must meet the stronger declared contract.
- Keep popup-launcher registration explicit in the consumer recipe. Consider a small setup module only if repeated real consumer integration demonstrates value; do not add a new export now.
- Retain the existing flake-scope dependency for context-consuming aspects and explain it. Narrower injection can be investigated if a concrete collision or provenance problem appears; no ambient-context rewrite now.
- No new pipe, broadcast, collection, or generic conflict framework solely to exercise Den features.
- Existing consumer fixtures are the test seam. Add only the demonstrated scope regression and high-value lifecycle/conflict checks already in the plan, not a test for every researched mechanism.

## Evidence limits

Researchers source-read the pinned implementation, docs, and selected upstream tests; they did not run the upstream suite. Parent runtime evidence covers the PipeWire leak, one captured-input Direnv case, the existing broad-composition baseline, and the isolation counterprobe only. No end-to-end proof is claimed for every provider, Pipe stage, conditional guard, or explicit routing design. No full build, system activation, disk operation, lock update, or consumer migration was performed for this research.
