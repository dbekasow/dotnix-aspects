# 02: Reorganize feature ownership and discovery around the confirmed criterion

**What to build:** Mechanically organize the existing capability set by confirmed feature ownership and constrain discovery so feature entry points remain distinguishable from producer, adapter, and tooling code. Gate G is closed: use a direct feature catalog; small capabilities may remain single files; complex capabilities keep variants, integrations, and helpers local. Add no thematic categories and do not mirror host, home, or account selections in the source layout.

**Blocked by:** [01: Use PipeWire as the complete reference through the new library entry point](01-pipewire-reference-adapter.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] Preserve the existing feature set semantically as the public capability catalog; organize it by concrete feature ownership, not an invented mail, container, audio, or web theme hierarchy.
- [x] Small features may remain one file each. Multi-part features keep variants, optional integrations, and helpers with their owner; do not force one file per role.
- [x] Keep source discovery, adapter/producer assembly, and optional tooling as separate responsibilities. Consumer code does not import the producer tree wholesale.
- [x] Document the actual pinned import-tree rule: directory scans exclude relative `/_` paths by default; explicitly supplied files and roots, as well as a replacing `initFilter` configuration, can bypass this rule. `default.nix` does not stop recursive scanning.
- [x] Set public namespace names explicitly; do not derive them from filenames or directory paths. Add no registry or taxonomy DSL.
- [x] Pure storage moves preserve existing selections without alias or compatibility promises and require neither new tests nor a feature matrix.
- Evidence (superseded): an earlier attempt excluded the German ticket directory from `typos`; the user rejected hiding German text and required translation instead.
- Evidence: Specs, tickets, and documentation are English-only. All 20 tickets were translated, so the typo gate checks them without any content exclusion; only `certificates/`, `secrets/` and the legitimate identifier `ful` in `denful` / `config.den.ful` remain configured.

## Integration evidence

Merged as `e15b4f6f2795f21d0a808d0612479381a245f7bf`; reviewed branch tip `3d5fd024ac96d429a49ab1348ff988497816e63f`.

Translation fidelity was reviewed against the German originals: identical filenames, numbering, blocker link targets and order, statuses, and 104 acceptance criteria with unchanged checked/unchecked counts; one wording defect in ticket 05 (prerequisite prohibition weakened to an assignment prohibition) was found and fixed. Ownership and discovery were reviewed separately with no findings; 144 files moved as pure renames, and adapter, tests, templates, source flake and lock are unchanged.

Commands actually run in the integration worktree, evaluation only:

- `typos --force-exclude --format brief --hidden .` -> exit 0.
- `nix eval --impure --json --file tests/broad-compositions.nix` -> 34 checks, all true.
- `nix flake check --no-build --no-write-lock-file` -> passed; no build performed.
- `nix fmt -- --ci` -> 219 files, none changed; worktree clean.
- `flake.lock` unchanged at `6f9c06db3f8a4211e10a99998c20c27c3307d8a4eedd9a69d3fed9b0af2f0e47`; generated `flake.nix` unchanged.
- Namespace sanity check confirmed the public aspects (including `docker`, `aerc`, `dms`, `noctalia`, `helix`, `tmux`, `herdr`, `git`, `stylix`, `host.pipewire`, `home.pipewire`) still resolve after the move.

No build, runtime, activation, or disk-operation proof is claimed.
