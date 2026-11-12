# Profile and namespace redesign: canonical spec

Status: decisions approved; implementation requires separate approval.

This spec records the approved redesign of the profile layer and the
namespace conventions of this library. It follows the completed
den-flake-file redesign (see `../den-flake-file-redesign/spec.md`) and is
grounded in verified Den mechanics at pin `7594405b45e0ce2d5a418fe104a26e17f6b1dd8f`:
Den has no native profile concept (a bundle is an aspect whose `includes`
point at other aspects), `excludes` is authoritative and subtree-scoped, and
freeform nested keys are provider wrappers without `meta` while `provides`
nested keys are full aspects.

## Design lens

The real occupants are the author, a partner, and parents on managed desktop
machines, plus host-only VPS machines. Occupant composition stays
consumer-owned ([ADR 0002](../../docs/adr/0002-occupant-composition-stays-consumer-owned.md));
the library ships domain-oriented bundles fine-grained enough to compose
very different occupants.

## Decisions

1. **Uniform role catalogs** ([ADR 0001](../../docs/adr/0001-split-aspects-into-role-catalogs.md)):
   every role-scoped aspect lives under `dotnix.host.*`, `dotnix.home.*`, or
   `dotnix.account.*`. Home-only aspects move to `dotnix.home.*` (about
   seventy renames, for example `dotnix.bat` becomes `dotnix.home.bat`).
   The top level stays reserved for cross-cutting aspects (`popup-launchers`)
   and consumer-owned composites (per-user aspects, hardware profiles).
2. **Role-split for multi-role features**: `dms` and `noctalia` split into
   `host.dms`/`home.dms` and `host.noctalia`/`home.noctalia`; class-multiplexed
   single aspects are retired.
3. **Profile renames**: `term-shell` becomes `shells`, `desktop-shell`
   becomes `graphical` (host and home), `core-home` becomes `core`. The word
   "shell" keeps only its login-shell meaning.
4. **GUI domain bundles**: new `home.office` (onlyoffice, thunderbird as the
   GUI mail client) and `home.browsers` (firefox); `home.desktop-apps`
   shrinks to the author's remainder (alacritty, ghostty, handy, anki).
5. **Universal core baseline**: `host.core` keeps locale, nix, security,
   certificates, ssh, age, home-manager, system-packages; `home.core` keeps
   age, age-rekey, ssh. Author-specific content moves to its domain:
   git and git-alias to `home.development`, stylix to `graphical`,
   gnupg/gpg-agent to explicit auth selections, fish to the shells area.
   `host.nur` stays individually selectable (role-pure home does not exist
   for it).
6. **Server profile**: `host.server` includes base, ssh, security;
   hardening, monitoring, and service content follow when the first VPS
   consumer is built.
7. **Terminal variant via excludes**: `home.terminal-herdr` is
   `{ includes = [ terminal herdr ]; excludes = [ tmux sesh ]; }`;
   `home.term-ux-herdr` is removed. The `term-*` sub-bundles stay public as
   occupant-granular building blocks.
8. **Freeform profile form stays**: profiles keep freeform nested keys
   (includes-only); `provides` is the documented upgrade path if a profile
   ever needs `meta` or constraints.
9. **No compatibility aliases**: the library has no external consumers;
   renames are breaking by design.

## Boundaries

- No behavior change beyond the documented moves, renames, and bundle
  compositions; feature module bodies stay untouched.
- No new profile framework, no archetype profiles, no per-occupant content
  in the library.
- No flake input or lock changes.
- Live activation stays out of scope; gates are evaluation, static checks,
  and the template consumer build.

## Verification

Follow the Pareto test strategy of the den-flake-file redesign. Required
gates per ticket: `nix fmt`, `nix flake check --no-write-lock-file`,
`tests/broad-compositions.nix`, `tests/headless-composition.nix`,
`tests/niri-dms.nix`, and the template consumer evaluation/build. Ticket 03
must demonstrate the `excludes` semantics (aspect carrying both `includes`
and `excludes`, authoritative, subtree-scoped) on the pinned Den before
relying on it.
