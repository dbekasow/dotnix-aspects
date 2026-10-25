# 03: Exercise the generated consumer and optional tooling end to end

**What to build:** Integrate the generator and optional development tooling so consumers can reproducibly bootstrap, evaluate, and regenerate a generated flake. The explicitly selectable Direnv feature uses the library-captured `direnv-instant` dependency. Formatter, hooks, and the development shell retain clear input and implementation ownership and remain outside feature export and the normal consumer adapter.

**Blocked by:** [02: Reorganize feature ownership and discovery around the confirmed criterion](02-feature-ownership-discovery.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] Optional `devTools` are selectable separately from the normal adapter and feature catalog; formatter, hooks, and development shell have clearly assigned inputs and implementation owners.
- [x] An explicitly disposable consumer fixture selects Direnv and exercises bootstrap, generation, evaluation before and after generation, and repeated generation with stable selections and no drift in generated flake text.
- [x] The fixture observes intended activated Direnv behavior before and after generation; `direnv-instant` comes from a library-captured input, not a same-named consumer root input. Input deduplication alone is not evidence of behavior.
- [x] The lifecycle uses an explicitly specified temporary directory; fixture-owned input and lock writes are allowed. It never uses the current sibling-based script default or a real private consumer.
- [x] Preserve existing auto-follow behavior when state already exists; do not change it for stylistic reasons. Library inputs and lock pins remain unchanged.
- [x] Report evaluation and generated text as such; do not infer build or runtime evidence from constructing an activation derivation.

## Integration evidence

Merged as `efcbf581a87bd6ce4e8bd6aedba7caa7950c1771` from branch `impl/den-redesign-03-consumer-generation-tooling` (reviewed at `8ecc834b708f4f317025e8393fa4a13916f3b89a`, tip `8ecc834b`).

**Template defect fixed.** The template root `flake.nix` declares seven bootstrap inputs (`nixpkgs`, `import-tree`, `flake-parts`, `den`, `home-manager`, `dotnix`, `nixos-hardware`) plus the `mkFlake`/`import-tree` outputs expression, but `templates/dotnix/modules/parts.nix` declared none of them through `flake-file`. The first `nix run .#write-flake` therefore regenerated the consumer root `flake.nix` from the `flake-file` declarations alone and dropped every bootstrap input and the outputs expression, leaving an un-evaluable consumer. `parts.nix` now declares `flake-file.inputs` (with the existing `follows` relations) and `flake-file.outputs`, so generation reproduces the template instead of destroying it.

**Explicit-destination contract.** `tests/consumer-generation.sh` takes exactly one explicit destination and refuses to run otherwise: traversal components are rejected before path normalization, then the normalized path is checked for symlinked components, the filesystem root, the repository, `$HOME`, the original library checkout and the private consumer, and it must be an existing empty directory. Zero, multiple or empty arguments print usage and exit 2; traversal, symlink, missing, non-directory, non-empty and protected destinations exit 1. Writes and cleanup are confined to a script-owned child directory created inside that destination, so the sibling-based default and any real consumer are never reachable.

**Observed behavior.** `tests/consumer-generation/myHost.nix` selects `dotnix.direnv` for a home-manager user. The fixture asserts `programs.direnv-instant.enable` is `true` _before_ generation, after the first generation and after repeated generation, and that the consumer root inputs do not contain `direnv-instant`: the dependency arrives through the library-captured input, not a same-named consumer root input. Repeat generation is stable: `flake.nix` and `flake.lock` are byte-identical to the post-first-generation copies (`cmp`).

Verified in `/tmp/pi-den-redesign.zPYNBq/integration` at the merge commit above:

- One lifecycle run with a fresh explicit directory created for this check under `/tmp`: `bash tests/consumer-generation.sh <tmpdir>` printed `Consumer generation lifecycle passed`, exit 0, left the destination empty (the only residue is the script's own child, removed by its trap), and the temp directory was then deleted.
- `nix eval --impure --json --file tests/broad-compositions.nix`: 41 assertions, all `true`.
- `nix eval --impure --file tests/headless-composition.nix`: `"headless and workstation composition checks passed"`.
- `nix flake check --no-build --no-write-lock-file`: `all checks passed!`.
- `typos --force-exclude --format brief --hidden .`: exit 0. `nix fmt -- --ci`: 222 files, 0 changed, `git status --porcelain` empty.
- `git diff c354f5e..HEAD -- flake.nix flake.lock` empty; `sha256sum flake.lock` equals the recorded source lock hash `6f9c06db3f8a4211e10a99998c20c27c3307d8a4eedd9a69d3fed9b0af2f0e47`.

Evaluation plus one lifecycle run only: no build, activation or runtime proof is claimed, and constructing an activation derivation is not treated as runtime evidence.
