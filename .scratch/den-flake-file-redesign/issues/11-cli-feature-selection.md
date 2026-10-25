# 11: Combine small CLI capabilities independently

**What to build:** Keep existing small terminal-oriented capabilities individually consumable without creating a new theme or role tree. This includes file, data, search, monitoring, and Nix tools as well as Aerc and Maildir; their existing state contributions remain with their respective owners.

**Blocked by:** [02: Reorganize feature ownership and discovery around the confirmed criterion](02-feature-ownership-discovery.md).
**Status:** claimed
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] `bat`, `dua`, `dust`, `eza`, `fd`, `ouch`, `ripgrep`, `ripgrep-all`, `sd`, `fx`, `jq`, `mdcat`, and `xh` remain independently selectable.
- [ ] Monitoring tools including Bandwhich, Bottom, Fastfetch, Hyperfine, Procs, Rustscan, Tealdeer, Television, and Tokei remain available as separate capabilities.
- [ ] Nix tools such as Nix Index Database, Nix Search TV, and Nix Tools, along with Aerc and Maildir, remain explicitly selectable without introducing a new mail or container directory tree.
- [ ] Existing Persistence/state contributions remain local to each feature; small individual features require neither their own tests nor mandatory directories.
- [ ] Shell UX and login shells belong to ticket 09, multiplexers/popups to ticket 10, Secrets to ticket 06, Direnv to ticket 03, and development tools to ticket 12.
