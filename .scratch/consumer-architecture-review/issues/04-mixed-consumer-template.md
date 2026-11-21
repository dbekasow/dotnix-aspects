# 04: Migrate the template and demonstrate mixed-host imports

**What to build:** Show the published module names in the shipped template and give an equivalent migration example for the private consumer.

**Blocked by:** [02: Configure a work home without Desktop or YubiKey](02-independent-work-home.md); [03: Use repository tools without vault tooling](03-independent-repo-tools.md)

**Status:** ready-for-agent

- [ ] A generated mixed consumer evaluates with the desktop selected on one host and absent on the other; reuse the existing two-host check.
- [ ] The template and private migration example require no internal library paths. Preserve effective host selections; do not change login, shell inheritance or secrets in this migration.

[Review decisions and test budget](../map.md)
