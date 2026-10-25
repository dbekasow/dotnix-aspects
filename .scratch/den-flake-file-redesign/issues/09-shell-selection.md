# 09: Select shells and login shells independently

**What to build:** Separate Fish and Nushell so host prerequisites, account login shells, and home configuration remain independently selectable. Related shell UX such as Atuin, Carapace, Starship, FZF, Skim, and Zoxide remains independently combinable.

**Blocked by:** [05: Configure accounts without hidden shell or vault choices](05-account-selection.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] Fish and Nushell home configurations can be activated without automatically selecting them as account login shells; set a login shell only for selected accounts.
- [x] Required host packages/prerequisites are separate from user and home selections; host-side activation does not affect unrelated accounts.
- [x] Atuin, Carapace, Starship, FZF, Skim, and Zoxide retain their existing selectable capabilities and are not activated wholesale by the base shell.
- [x] Completions, prompt, and navigation behavior remain usable for existing shell combinations; native options override defaults.
- [x] Shell selection requires neither popup/multiplexer selection nor Secrets/vault conventions.

## Integration evidence

Merged `impl/den-redesign-09-shell-selection` (tip `3107465`) into the integration
branch as `1def7b9` with `--no-ff`; no conflicts.

Three independent selectors and what each carries:

- `dotnix.host.{fish,nushell}` — host prerequisites only (`programs.fish.enable`
  and `useBabelfish`; `programs.nushell.enable`). No account or home effect.
- `dotnix.home.{fish,nushell}` — home configuration only (`programs.fish.enable`
  plus the autopair and fish-you-should-use plugins and
  `home.shell.enableFishIntegration`; `programs.nushell.enable`). No login shell
  change.
- `dotnix.account.{fish,nushell}` — sets only the login `shell` of the accounts
  it is applied to.

Measured role isolation (evaluation-domain assertions in
`tests/broad-compositions.nix`, `shell*` composition names):

- Host-only selection leaves home configuration absent and leaves account
  shells unchanged.
- Home-only selection enables home configuration while the login shell stays
  Bash.
- Account selection changes exactly the selected account; the unrelated account
  keeps the native default.
- Shell UX features (Atuin, Carapace, Starship, FZF, Skim, Zoxide) and
  multiplexers stay independent of the login shell.

Honest qualification, recorded as observed rather than as a defect:
`dotnix.account.fish` alone does set the login shell, but it still needs the host
prerequisite (`dotnix.host.fish` or `programs.fish.enable`). That is the intended
separation of the three roles, not a missing piece.

What an existing Fish-login consumer must now select: a consumer that previously
relied on a combined shell module to obtain a Fish login shell has to select
`dotnix.account.fish` (or `dotnix.account.nushell`) explicitly, in addition to
the home and host selections it wants.

Merged assertions: the ticket05 and ticket12 assertions present before this
merge survived it.

Commands and results, all run inside the integration worktree at the merge
result:

- `nix eval --impure --json --file tests/broad-compositions.nix` — 57 of 57
  `true`.
- `nix eval --impure --file tests/headless-composition.nix` —
  "headless and workstation composition checks passed".
- `nix eval --impure --json --file tests/niri-dms.nix` — 33 of 33 `true`.
- `nix flake check --no-build --no-write-lock-file` — all checks passed.
- `typos --force-exclude --format brief --hidden .` — exit 0.
- `nix fmt -- --ci` — 0 files changed; `git status --porcelain` empty.
- `git diff eb4abdb..HEAD -- flake.nix flake.lock` — empty; `flake.lock`
  sha256 equals the value in `source-lock.sha256`.

Caveat: this evidence is evaluation-only (`nix eval` plus flake-check
evaluation). No NixOS or home-manager activation and no runtime login-shell
behaviour was executed.
