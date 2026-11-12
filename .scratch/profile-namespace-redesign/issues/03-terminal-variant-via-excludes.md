# 03: Express the multiplexer variant with excludes

**What to build:** Collapse the parallel variant profiles into one
excludes-based profile. `home.terminal-herdr` becomes
`{ includes = [ terminal herdr ]; excludes = [ tmux sesh ]; }` and the
public aspect `home.term-ux-herdr` is removed. Keep the remaining `term-*`
sub-bundles public — they are the occupant-granular building blocks (a
parent takes term-cli without term-nix, term-monitoring, or term-secrets).
Before relying on it, verify on the pinned Den that an aspect may carry both
`includes` and `excludes`, that the exclude is authoritative and
subtree-scoped (it removes members that arrive transitively through
`terminal`), and that the selection site can still override.

**Blocked by:** [01: Unify role catalogs, split multi-role features, rename
profiles](01-uniform-role-catalogs.md).
**Status:** claimed
**Spec/authorization:** [Canonical spec](../spec.md); ticket publication is
approved, implementation requires separate approval.

## Acceptance criteria

- [ ] Den `excludes` semantics verified on pin `7594405` with a minimal
      evaluation before the profile change (evidence in the ticket).
- [ ] Selecting `home.terminal-herdr` yields the shared terminal content plus
      herdr, without tmux or sesh, and without duplicating the terminal
      include list.
- [ ] `home.term-ux-herdr` no longer exists in the namespace.
- [ ] `home.term-ux` still selects tmux and sesh; `home.terminal` is
      unchanged for tmux users.
- [ ] Gates pass: `nix fmt`, `nix flake check --no-build --no-write-lock-file`,
      updated composition tests, template consumer evaluation.

## Comments

(append discussion here)
