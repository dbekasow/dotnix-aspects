# 12: Use Git, Helix, and development tools without host side effects

**What to build:** Make development capabilities individually consumable without unwanted host activation. Git/VCS tools, Helix and its language configuration, automation, Kubernetes, and other existing development tools remain with their respective feature owners.

**Blocked by:** [02: Reorganize feature ownership and discovery around the confirmed criterion](02-feature-ownership-discovery.md).
**Status:** claimed
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] Git, Git aliases, GitHub CLI, Lazygit, Delta, and Difftastic retain separate selections; an existing host Git contribution remains explicitly selectable.
- [ ] Helix, Helix keys, and existing Bash/Fish/JSON/Just/Markdown/Nix/Python/Text/TOML/YAML LSP configurations remain usable without a mandatory language matrix.
- [ ] Bacon, Just, Watchexec, Kubernetes, and other existing DevOps/automation capabilities remain consumable.
- [ ] A home selection activates neither Docker nor Nix-LD as a hidden host prerequisite; host facets remain explicit host selections.
- [ ] Native options remain overridable; no Development profile is required for an individual tool, and no per-language test matrix is introduced.
