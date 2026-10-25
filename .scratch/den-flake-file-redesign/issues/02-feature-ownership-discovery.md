# 02: Reorganize feature ownership and discovery around the confirmed criterion

**What to build:** Mechanically organize the existing capability set by confirmed feature ownership and constrain discovery so feature entry points remain distinguishable from producer, adapter, and tooling code. Gate G is closed: use a direct feature catalog; small capabilities may remain single files; complex capabilities keep variants, integrations, and helpers local. Add no thematic categories and do not mirror host, home, or account selections in the source layout.

**Blocked by:** [01: Use PipeWire as the complete reference through the new library entry point](01-pipewire-reference-adapter.md).
**Status:** claimed
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] Preserve the existing feature set semantically as the public capability catalog; organize it by concrete feature ownership, not an invented mail, container, audio, or web theme hierarchy.
- [ ] Small features may remain one file each. Multi-part features keep variants, optional integrations, and helpers with their owner; do not force one file per role.
- [ ] Keep source discovery, adapter/producer assembly, and optional tooling as separate responsibilities. Consumer code does not import the producer tree wholesale.
- [ ] Document the actual pinned import-tree rule: directory scans exclude relative `/_` paths by default; explicitly supplied files and roots, as well as a replacing `initFilter` configuration, can bypass this rule. `default.nix` does not stop recursive scanning.
- [ ] Set public namespace names explicitly; do not derive them from filenames or directory paths. Add no registry or taxonomy DSL.
- [ ] Pure storage moves preserve existing selections without alias or compatibility promises and require neither new tests nor a feature matrix.
- Evidence: Formatter gate passed after excluding German tickets and allowing legitimate `ful` in `denful` / `config.den.ful`.
- Evidence: Specs, tickets, and documentation are English-only; translating all tickets lets the typo gate check them without exclusions.
