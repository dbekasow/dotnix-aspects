# Split aspects into uniform role catalogs

Status: accepted

All role-scoped aspects live in uniform catalogs: host-scoped under
`dotnix.host.*`, home-scoped under `dotnix.home.*`, account-scoped under
`dotnix.account.*`. Multi-role features declare one aspect per role
(role-split, the fish/docker style) instead of one aspect carrying multiple
class contents (class-multiplexing, the former dms/noctalia style). The
namespace top level stays reserved for cross-cutting aspects (for example
`popup-launchers`) and consumer-owned composites such as per-user aspects and
hardware profiles.

## Considered Options

- **Class-multiplexing everywhere** (one aspect with `nixos` and
  `homeManager` content): fewer aspects, but the role structure is invisible
  at the selection site and host-only or per-user composition becomes harder
  to reason about.
- **Top-level placement for home-only aspects** (the former majority state):
  smallest diff, but the `dotnix.home.*` catalog stays half-empty and every
  selection must remember per-feature which prefix applies.

## Consequences

Roughly seventy home-only aspects move to `dotnix.home.*`, and `dms` and
`noctalia` split into host and home aspects. Renames carry no compatibility
aliases: the library has no external consumers. Uniform role paths make
per-role composition and agent navigation (grep `dotnix.home.` finds every
home aspect) predictable across the whole catalog.
