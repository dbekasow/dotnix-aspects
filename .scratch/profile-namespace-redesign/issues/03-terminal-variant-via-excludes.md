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
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); ticket publication is
approved, implementation requires separate approval.

## Acceptance criteria

- [x] Den `excludes` semantics verified on pin `7594405` with a minimal
      evaluation before the profile change (evidence in the ticket).
- [x] Selecting `home.terminal-herdr` yields the shared terminal content plus
      herdr, without tmux or sesh, and without duplicating the terminal
      include list.
- [x] `home.term-ux-herdr` no longer exists in the namespace.
- [x] `home.term-ux` still selects tmux and sesh; `home.terminal` is
      unchanged for tmux users.
- [x] Gates pass: `nix fmt`, `nix flake check --no-build --no-write-lock-file`,
      updated composition tests, template consumer evaluation.

## Comments

### Excludes verification on the pinned Den (2026-11-12, pre-change)

Pinned Den confirmed in `flake.lock`: `den` @ `7594405b45e0ce2d5a418fe104a26e17f6b1dd8f`.
Docs on the pin: `reference/aspects.mdx` — "`excludes` | `listOf provider` |
Aspects or policies excluded from this subtree"; `explanation/policy-activation.mdx`
— "Parent excludes are **authoritative** — child scopes cannot re-enable an
excluded policy"; Den's own CI
(`templates/ci/modules/deadbugs/issue-613-exclude-sibling-isolation.nix`)
asserts per-entity sibling isolation for excludes.

Minimal evaluation in this library's consumer context, BEFORE the profile
change: a throwaway harness mirroring the `evaluate` fixture of
`tests/broad-compositions.nix` (same bootstrap, overlays, user classes;
files were `/tmp/pnr03-excludes-verify.nix` and `/tmp/pnr03-verify2.nix`,
not committed). A consumer-declared aspect — the same mechanism the template
uses for `dotnix.myuser` — carried the exact target shape of decision 7:

```nix
dotnix.pnr03-variant = {
  includes = [ dotnix.home.terminal dotnix.home.herdr ];
  excludes = [ dotnix.home.tmux dotnix.home.sesh ];
};
```

tmux/sesh arrive only transitively (variant → terminal → term-ux →
`[ sesh tmux ]`). Commands and results:

```
$ nix eval --impure --raw --file /tmp/pnr03-excludes-verify.nix
{"controlNoExcludes":{"atuin":true,"fish":true,"herdr":true,"sesh":true,"tmux":true,"yazi":true},
 "variantOnly":{"atuin":true,"fish":true,"herdr":true,"sesh":false,"tmux":false,"yazi":true},
 "variantPlusTmux":{"atuin":true,"fish":true,"herdr":true,"sesh":false,"tmux":false,"yazi":true}}

$ nix eval --impure --raw --file /tmp/pnr03-verify2.nix
{"consumerExcludeOnLibraryAspect":{"fish":true,"herdr":false},
 "siblingScope":{"aliceSesh":true,"aliceTmux":true,"fixtureHerdr":true,"fixtureTmux":false}}
```

Findings:

1. **Aspect carries both includes and excludes**: the variant resolves and
   its subtree survives (fish, atuin, yazi, herdr all enabled).
2. **Authoritative**: `variantOnly` removes tmux/sesh that arrive only via
   the child chain; the control (`controlNoExcludes`, same includes without
   excludes) proves they arrive transitively otherwise. Child includes cannot
   re-enable an excluded member.
3. **Subtree/entity-scoped**: in `siblingScope`, a second user (`alice`)
   selecting `home.terminal` directly in the same host keeps tmux and sesh
   while the variant user does not. Excludes do not leak across entities.
4. **Selection site can still override** — both channels probed:
   - Direct re-inclusion at the selection site
     (`includes = [ users variant tmux ]`, `variantPlusTmux`) does NOT bring
     tmux back: the exclude registers at the selecting entity's scope and
     wins over sibling includes there. A consumer wanting Herdr plus Tmux
     composes `home.terminal` + `home.herdr` (or the public `term-*`
     building blocks) instead of `home.terminal-herdr` — exactly why
     decision 7 keeps the `term-*` sub-bundles public.
   - The `excludes` option itself remains consumer-effective:
     `consumerExcludeOnLibraryAspect` set
     `dotnix.home.terminal-herdr.excludes = [ dotnix.home.term-ux-herdr ]`
     from a consumer module and the exclude took effect (herdr vanished,
     shells survived). The selection site can steer the aspect through its
     `excludes` option.

Side finding (recorded, not relied upon): a consumer-side `lib.mkForce` on a
library aspect's `includes` is ignored — the library's denful-fed include
list survives. Irrelevant here because the library rewrites its own profile
module.

### Implementation (2026-11-12, worktree t03, branch impl/pnr-03-terminal-variant)

Base: `cbcafb0` (verified with `git log --oneline -1`). Commits: `feddbc4`
(claim), `77b9ec9` (implementation). `git merge integration/profile-namespace-redesign`
→ "Already up to date" (ticket 02 had not landed at merge time).

- `profiles/terminal-herdr.nix`:
  `dotnix.home.terminal-herdr = { includes = [ terminal herdr ]; excludes = [ tmux sesh ]; }`
  (scoped `with dotnix.home;`) — no duplicated terminal include list.
- `profiles/term-ux.nix`: `dotnix.home.term-ux-herdr` declaration removed;
  `term-ux` keeps atuin…zoxide + sesh + tmux. The `shared` let was inlined
  (its only remaining consumer was the removed variant).
- `tests/broad-compositions.nix`: new `terminalHerdr` fixture plus three
  checks — `terminalHerdrSwapsMultiplexersViaExcludes` (fish, nushell,
  atuin, carapace, starship, fzf, skim, zoxide, bat, herdr enabled; tmux and
  sesh absent), `terminalKeepsMultiplexersForTmuxUsers` (`home.terminal`
  keeps tmux and sesh), `termUxHerdrAspectRemovedFromNamespace`
  (`term-ux-herdr` gone, `terminal-herdr` present). 94 → 97 assertions.
- No other references existed: repo-wide grep for `term-ux-herdr` outside
  `.scratch/` now matches only the namespace assertion.

### TDD

Expectations written first. Red confirmed:
`nix eval --impure --json --file tests/broad-compositions.nix` →
`error: Broad composition fixture failed: termUxHerdrAspectRemovedFromNamespace`
— exactly the namespace check fails, because the pre-change `term-ux-herdr`
path produced the same member set as the post-change excludes form (the old
variant also omitted tmux/sesh), so only the namespace-shape assertion can go
red. Implementation turned all 97 assertions green.

### Gates (exact commands, results)

- `nix fmt` → 0 changed; re-run 0 changed (idempotent), tree clean.
- `nix flake check --no-build --no-write-lock-file` → exit 0,
  `all checks passed!`.
- `nix eval --impure --json --file tests/broad-compositions.nix` → exit 0,
  97/97 assertions true.
- `nix eval --impure --file tests/headless-composition.nix` → exit 0,
  `"headless and workstation composition checks passed"`.
- `nix eval --impure --json --file tests/niri-dms.nix` → exit 0, 48/48 true.
- `typos` → exit 0, no findings.
- `bash tests/consumer-generation.sh /tmp/pnr03-consumer-gen` → exit 0,
  `Consumer generation lifecycle passed` (destination directory created
  first; the script requires an existing directory).
- Full template NixOS build not chased (pre-existing failure documented in
  ticket 01).

### Deviations

None. The verification's "selection site can still override" clause resolved
to the `excludes`-option channel (finding 4): direct re-inclusion of an
excluded aspect at the selection site does not override, which matches Den's
authoritative-exclude semantics and the spec's design (public `term-*`
building blocks are the compositional escape hatch).
