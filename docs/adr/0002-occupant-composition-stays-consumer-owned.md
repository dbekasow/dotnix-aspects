# Occupant composition stays consumer-owned

Status: accepted

The library ships domain-oriented, purpose-named bundles only (terminal,
development, office, browsers, mail). Composing an occupant — the human
using a machine, such as the author, a partner, or a parent — from features
and profiles belongs to the consumer's per-user aspects (`dotnix.<name>`),
not to the library.

## Considered Options

- **Archetype profiles in the library** (`home.casual`, `home.office-user`):
  the simplest consumer configuration, but it would make the library
  person-shaped instead of domain-shaped and duplicate knowledge the consumer
  already owns (who the occupants are and what they need).

## Consequences

The library must keep domain bundles fine-grained enough to compose very
different occupants: the `term-*` sub-bundles stay public, GUI applications
get dedicated domain bundles (`home.office`, `home.browsers`), and variants
are expressed with `includes` plus `excludes` instead of parallel profile
names. The real occupants (author, partner, parents, plus host-only VPS
machines) are the design lens for granularity, not library content.
