# 03: Opt into DevTools without Desktop

**What to build:** A non-graphical Consumer can add DevTools independently and get the existing development shell, formatting, checks/hooks, and vault commands without adding Desktop.

**Blocked by:** [01: Run a WSL-only Consumer on Base](01-wsl-only-on-base.md).

**Status:** ready-for-agent

- [ ] Start with a Base lock that does not declare the optional DevTools group. Add the DevTools import, run the existing flake writer, and lock with ordinary Nix. Inputs missing before that first generation do not block it.
- [ ] With DevTools enabled, the existing shell, formatter, checks/hooks and vault command outputs evaluate. Do not run commands that operate on private vault contents.
- [ ] Optional follows only target declared inputs. Omitting DevTools keeps the Base lock valid and Age/Rekey configuration available; an upstream input's own transitive dependencies do not count as opting into DevTools.
- [ ] Keep the Consumer Desktop-free and reuse the Base Consumer verification seam. No separate fixture family or additional shell script. The published template and private Consumer are not cut over in this slice.
