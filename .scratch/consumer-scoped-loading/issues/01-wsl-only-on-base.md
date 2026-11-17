# 01: Run a WSL-only Consumer on Base

**What to build:** A WSL-only Consumer can pin the Aspect library as a source, import Base, and generate and lock one flake with the existing Nix workflow. Its terminal and CLI development selections work without importing Desktop or opting into DevTools.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [ ] A disposable Base-only Consumer runs the existing flake writer, locks with Nix, and evaluates a representative terminal and CLI development home through native Den.
- [ ] Base uses explicit import roots with one implementation per feature. No Desktop implementation is imported or registered, and no Desktop-only input is reachable from the Consumer lock root. A disabled Desktop service alone is not sufficient evidence.
- [ ] The terminal profile does not select Wayland clipboard. Keep shared XDG user directories, CLI GPG/RBW defaults, and Hunk's package source usable without Desktop or DevTools.
- [ ] The Base lock has no dangling follows to DevTools inputs. Base Age/Rekey host and home configuration remains available independently of the repository tooling.
- [ ] Reuse the Consumer generation or terminal checks where practical. No new shell wrapper, selection catalogue, target flake, or lock seeding. Do not switch the published template or private Consumer in this slice.
