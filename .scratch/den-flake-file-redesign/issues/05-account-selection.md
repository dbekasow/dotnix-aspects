# 05: Configure accounts without hidden shell or vault choices

**What to build:** Provide consumer-owned account selections so only explicitly selected accounts are affected and account foundations remain independent of home selections. Ordinary native account options and optional integrated Home Manager use remain possible; host-only accounts remain valid.

**Blocked by:** [02: Reorganize feature ownership and discovery around the confirmed criterion](02-feature-ownership-discovery.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] The consumer owns the account inventory and account selections; a selection affects only the explicitly named account.
- [x] Account foundations require neither blanket `host.users` privileges nor a default shell, vault conventions, or a password generator as prerequisites.
- [x] Account selection works regardless of whether Home Manager is selected for that account; integrated Home Manager use remains explicit and optional.
- [x] Native options remain overridable, and an unrelated person on the same host remains unchanged.
- [x] Password recipes and Secrets/Auth belong to ticket 06; the Fish login shell belongs to ticket 09. Neither is activated implicitly by account foundations.

## Integration evidence

Account selection is an explicit foundation: `dotnix.account.users` sets the OS account settings for one named user only, while `account.passwords` stays a separate per-user opt-in that reads native `age.rekey.secretsDir` (defaulting to `modules/hosts/<host>/secrets`, overridable) and keeps users mutable until vault material exists. `profiles/core.nix` no longer bundles the legacy users selection, so neither a default Fish login shell nor password generation is pulled in implicitly.

The password hash pipeline is executable and regression-tested: `tests/password-recipe.sh` evaluates the real generator option, runs its script with a synthetic decrypt command in a temporary directory, and independently reproduces the `$6$` hash with nixpkgs OpenSSL. It fails the build on any mismatch, so it proves the recipe hashes actual plaintext rather than merely evaluating.

Three review rounds: the first caught that the opt-in password recipe had been dropped and restored it; the second caught that the generator's hash pipeline was not executing and made it run as one shell line; the third approved with no findings, confirming the recipe occupies one line with no helper abstraction and that `profiles/core.nix` differs from the integration tip only by removing the legacy bundled users selection.

Verified in the integration worktree at this merge: `nix eval --impure --json --file tests/broad-compositions.nix` returned 46 checks, all `true`; `nix eval --impure --file tests/headless-composition.nix` passed; `nix flake check --no-build --no-write-lock-file` passed; `typos --force-exclude --format brief --hidden .` exited 0; `nix fmt -- --ci` reported 0 changed files and left `git status --porcelain` empty; `flake.nix` and `flake.lock` are unchanged versus the pre-merge tip. `bash tests/password-recipe.sh` exited 0 and printed a reproduced `$6$` hash for the synthetic plaintext.

This is evaluation plus one executable regression: there is no build, activation or runtime proof for these account selections.
