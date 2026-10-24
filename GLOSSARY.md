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
