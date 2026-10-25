# 08: Select Docker separately for host, account, and home

**What to build:** Offer the Docker host daemon, account settings, and user tools as separate consumer selections while preserving rootful and rootless use. Existing subuid/subgid and linger contributions must no longer be applied indiscriminately to every host account.

**Blocked by:** [05: Configure accounts without hidden shell or vault choices](05-account-selection.md), [07: Select Persistence independently from the Btrfs root reset](07-persistence-root-reset.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] The host daemon, a specifically selected account, and home-side Docker tools can be selected independently.
- [x] Subuid/subgid and linger affect only the explicitly selected account rather than every host account indiscriminately.
- [x] Describe actual capabilities accurately: do not claim Docker group membership or root privileges unless they are explicitly configured separately.
- [x] Rootful and rootless capabilities remain available; rootless state/Persistence is selected deliberately, not silently activated by the daemon or a developer selection.
- [x] Do not redesign existing runtime behavior; a Docker feature does not force a Development profile.

## Integration evidence

Merged `impl/den-redesign-08-docker` (tip `365e199`) into the integration branch as
`0e3cfa2` with `--no-ff`; the `merge-tree --write-tree` probe exited 0 and the merge
was conflict-free.

Three independent selectors and what each carries:

- `dotnix.host.docker` — `virtualisation.docker` with `enable`, `rootless.enable`,
  `rootless.setSocketVariable` and `autoPrune.enable`. No account and no home effect.
- `dotnix.account.docker` — `autoSubUidGidRange` and `linger`, both as `mkDefault`,
  applied only to the accounts the aspect is invoked on. No Docker group membership,
  no daemon, no home tools.
- `dotnix.home.docker` — LazyDocker (plus the `lzd` Fish abbreviation) and Dive. No
  daemon and no account settings.
- `dotnix.home.docker-persistence` — separate opt-in that routes
  `.local/share/docker` through home persistence; the daemon and the `development`
  profile do not select it.

Measured account cases (public-consumer evaluation, `(autoSubUidGidRange, linger)`):

- Daemon only: `(false, null)` for both the fixture account and an unrelated account.
- Account selection: `(true, true)` for that account only; the unrelated account stays
  `(false, null)`.
- Ordinary override: `(false, false)` — both settings are `mkDefault`, so native
  options override them without `mkForce`.

So the blanket all-users subuid/subgid and linger behaviour is gone: those settings
follow the selected account and never reach unrelated accounts.

Accurate capability statement: the account aspect allocates subordinate IDs and
lingers the user service for rootless Docker. It does not add Docker group membership
and does not grant root privileges; README and code make no such claim. Rootful and
rootless capability both remain available, rootless state stays opt-in through explicit
persistence selection, and no Docker aspect forces `development`.

Merge note: `docker` and `nix-ld` remain out of `profiles/development.nix`; the
`development` profile still does not pull either in.

Commands and results, all run inside the integration worktree at the merge result:

- `nix eval --impure --json --file tests/broad-compositions.nix` — 66 of 66 `true`
  (includes the six `docker*` assertions).
- `nix eval --impure --file tests/headless-composition.nix` —
  "headless and workstation composition checks passed".
- `nix eval --impure --json --file tests/niri-dms.nix` — 37 of 37 `true`.
- `nix flake check --no-build --no-write-lock-file` — all checks passed.
- `typos --force-exclude --format brief --hidden .` — exit 0.
- `nix fmt -- --ci` — 0 files changed; `git status --porcelain` empty.
- `git diff aa8fa73..HEAD -- flake.nix flake.lock` — empty; `flake.lock` sha256 equals
  the value in `source-lock.sha256`.

Caveat: this evidence is evaluation-only (`nix eval` plus flake-check evaluation). No
Docker daemon was started, no rootless pull was performed, and no account linger or
subuid allocation was activated on a running system.
