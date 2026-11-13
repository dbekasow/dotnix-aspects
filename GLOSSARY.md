# Dotnix Aspects

Shared language for a reusable configuration library and the configurations that consume it.

## Language

**Aspect library**:
A collection of reusable configuration features and optional profiles, independent of concrete hosts, users, and personal selections.

**Consumer**:
A configuration that selects library features and profiles for its concrete hosts and users. The consumer owns those hosts, users, and selections.

**Consumer template**:
A ready-made starting configuration that consumers copy to bootstrap a new consumer. The library publishes one; the copying consumer owns the result.

**Occupant**:
A human who uses a machine managed by a consumer. The consumer composes the occupant's account, home, and selections; the library never encodes occupants.

**Feature**:
A coherent configuration capability that can be reused across consumers.

**Profile**:
An optional, purpose-named combination of reusable features for one selection scope. Profiles are domain-oriented convenience bundles, not occupant archetypes.

**Host selection**:
A consumer choice to apply reusable host-scoped configuration to an explicitly selected host.

**Home selection**:
A consumer choice to apply reusable home-scoped configuration to one explicitly selected account's home.

**Account selection**:
A consumer choice to apply reusable account-level settings to an explicitly selected account, independently of that account's home selection.

**Primary account**:
The one email account a consumer marks primary. Identity-bearing features default to its address and real name unless the consumer sets them explicitly.
