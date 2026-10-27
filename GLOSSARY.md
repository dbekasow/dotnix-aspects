# Dotnix Aspects

Shared language for a reusable configuration library and the configurations that consume it.

## Language

**Aspect library**:
A collection of reusable configuration features and optional profiles, independent of concrete hosts, users, and personal selections.

**Consumer**:
A configuration that selects library features and profiles for its concrete hosts and users. The consumer owns those hosts, users, and selections.

**Feature**:
A coherent configuration capability that can be reused across consumers.

**Profile**:
An optional, named combination of reusable features.

**Host selection**:
A consumer choice to apply reusable host-scoped configuration to an explicitly selected host.

**Home selection**:
A consumer choice to apply reusable home-scoped configuration to one explicitly selected account's home.

**Account selection**:
A consumer choice to apply reusable account-level settings to an explicitly selected account, independently of that account's home selection.
