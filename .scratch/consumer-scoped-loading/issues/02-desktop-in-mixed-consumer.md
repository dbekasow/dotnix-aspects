# 02: Opt into Desktop in a mixed Consumer

**What to build:** A Consumer can opt into Desktop alongside Base, keep one lockfile for all its configuration targets, and use native Den selections to configure only the intended hosts and homes.

**Blocked by:** [01: Run a WSL-only Consumer on Base](01-wsl-only-on-base.md).

**Status:** ready-for-agent

- [ ] Desktop has an explicit import root for the graphical profile, desktop foundations, compositors and shells, greeters, graphical applications, and GUI integrations. The existing Den selection names remain available; importing Desktop alone enables none of them.
- [ ] A Base Consumer can add Desktop using the existing flake writer and normal locking. Evaluate a mixed Consumer with one graphical target and one headless target from the same lockfile; verify a representative Desktop feature is applied only to the selected host or home.
- [ ] Wayland clipboard is available through the graphical home profile or explicit selection. Graphical pinentry remains opt-in and does not replace the Base CLI defaults for unselected homes.
- [ ] After removing Desktop and regenerating/relocking, neither its module registration nor its Desktop-only inputs remain. Reuse the Base Consumer check or existing graphical checks, not a new fixture matrix.
- [ ] Desktop does not require DevTools or introduce target-specific generation. The published template and private Consumer are not cut over in this slice.
