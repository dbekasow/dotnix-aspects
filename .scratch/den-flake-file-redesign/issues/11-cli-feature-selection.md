# 11: Combine small CLI capabilities independently

**What to build:** Keep existing small terminal-oriented capabilities individually consumable without creating a new theme or role tree. This includes file, data, search, monitoring, and Nix tools as well as Aerc and Maildir; their existing state contributions remain with their respective owners.

**Blocked by:** [02: Reorganize feature ownership and discovery around the confirmed criterion](02-feature-ownership-discovery.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] `bat`, `dua`, `dust`, `eza`, `fd`, `ouch`, `ripgrep`, `ripgrep-all`, `sd`, `fx`, `jq`, `mdcat`, and `xh` remain independently selectable.
- [x] Monitoring tools including Bandwhich, Bottom, Fastfetch, Hyperfine, Procs, Rustscan, Tealdeer, Television, and Tokei remain available as separate capabilities.
- [x] Nix tools such as Nix Index Database, Nix Search TV, and Nix Tools, along with Aerc and Maildir, remain explicitly selectable without introducing a new mail or container directory tree.
- [x] Existing Persistence/state contributions remain local to each feature; small individual features require neither their own tests nor mandatory directories.
- [x] Shell UX and login shells belong to ticket 09, multiplexers/popups to ticket 10, Secrets to ticket 06, Direnv to ticket 03, and development tools to ticket 12.

## Integration evidence

Preservation ticket: no feature code changed. Merged as `cd6aa6abf7a7836e4aa1765c2eef6d700500216e`; the only branch content was the claim commit and an integration merge.

Verified at the public namespace and consumer seam, in the integration worktree:

- The namespace exposes 114 aspects; all 27 capabilities named by this ticket are present, none missing.
- A profile-free selection (`aerc`, `maildir`, `nix-tools`, `nix-index-database`, `bat`, `jq`) with host and home persistence resolved aerc (including its viewer pager), notmuch/mbsync/msmtp, `maildirBasePath`, bat, jq, nix-init and nix-index, and produced persistence directories `[.local/share/aerc, mail, .cache/nix, .cache/nix-index]`.
- An unrelated home gained none of it (aerc, bat, notmuch false, no persistence directories), and a second host gained no aerc and no persistence attribute.
- No excluded area was pulled in implicitly: fish, nushell, starship, carapace, atuin, zoxide, sesh, skim, tmux, zellij, herdr, workmux, rbw, direnv, helix, git, lazygit, docker and `nix-ld` all stayed inactive; the login shell stayed the default rather than fish; no age secrets were declared.
- Selecting `bat` alone enabled only bat, with no aerc, notmuch, jq or nix-index and no persistence directories.

Gates: 41 broad-composition assertions all true; headless composition passed; flake evaluation passed with no build; `typos` exit 0; `nix fmt -- --ci` produced no changes; source `flake.nix` and `flake.lock` unchanged with the recorded lock hash.

Evaluation only: no build, activation or runtime proof is claimed.
