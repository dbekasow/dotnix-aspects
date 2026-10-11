# Repair 7.3 LOC report — repaired Nix source snapshot

Physical-line counts verified from repository trees on 2026-10-11 after the independent Sol review and the last source-code commits. Documentation commits and a targeted consumer `flake.lock` refresh do not change `.nix` counts; re-count if further Nix source edits occur.

## Scope and method

- Original baseline and reviewed snapshots use exact commits and scope from [`review.md`](review.md): library pre-migration `58566cdfe16874ca89e05441fd8378dabc7d5dd6`, reviewed `359b3b3226dc9fac856ed2e4c2c342ef0cee0336`; consumer pre-migration `be3cd865d6e1c1b65bba23992b971c7a3b5f6dbf`, reviewed `831756fe32505fa6471fc14f2675861f81bf5a3a`.
- Count every tracked `.nix` in each historical commit. For current snapshot count tracked plus non-ignored untracked `.nix` files that exist in worktree; deleted tracked files contribute zero. Count physical lines as Python `bytes.splitlines()` (line terminators excluded; final unterminated line counted). No generated-file filter: included template/generated-root flake files remain included. Separate comparison excludes only each repository's root `flake.nix`, matching baseline table's explicitly labeled root-flake comparison.
- No Nix evaluation, build, input/lock operation, or network access used.

## Verified counts

| Repository / scope                        | Pre-migration | Reviewed | Repaired source | Current − pre | Current − reviewed |
| ----------------------------------------- | ------------: | -------: | --------------: | ------------: | -----------------: |
| Library, all `.nix`                       |         5,836 |    5,794 |           6,008 |          +172 |               +214 |
| Consumer, all `.nix`                      |           210 |      327 |             353 |          +143 |                +26 |
| Combined, all `.nix`                      |         6,046 |    6,121 |           6,361 |          +315 |               +240 |
| Combined, excluding each root `flake.nix` |         5,936 |    5,962 |           6,194 |          +258 |               +232 |

Historical counts reproduce from exact commits above. Root-flake-excluded counts: 5,744 library + 192 consumer before migration; 5,676 + 286 reviewed; 5,889 + 305 current. Current snapshot includes the Quirk producer/consumers, Herdr and template Nix changes, Broad's 28 assertions, and the consumer parts guard. Markdown documentation does not contribute to these counts.

## Interpretation

Compared with reviewed snapshot, library adds 214 lines and consumer 26. Library changes include manual fixtures, true source-aspect changes (new shared Quirk producer and Herdr/Tmux consumers), README/template edits, and tooling/root changes; consumer adds the parts guard. Counts are physical, not a complexity score. Fixture growth captures restored native standalone/routing/resource/identity/Tmux coverage; source growth implements behavior, not formatting alone.

Growth does not prove migration is worse, and lower historical LOC does not prove simplification: removed builder/wrapper and legacy exports/profile schema coexist with native behavior repairs. Do not count lost behavior as simplification. Compare final snapshot to both historical baselines after Sol review; current count may change.

## Reproduce / final refresh

Run from any directory; requires Python 3 and Git only. It prints historical and current counts using the same semantics. Re-run if Nix source changes after this snapshot.

```sh
python3 - <<'PY'
import pathlib, subprocess
repos = [
    ('/home/denis/projects/dotnix-aspects', '58566cdfe16874ca89e05441fd8378dabc7d5dd6', '359b3b3226dc9fac856ed2e4c2c342ef0cee0336'),
    ('/home/denis/projects/dotnix', 'be3cd865d6e1c1b65bba23992b971c7a3b5f6dbf', '831756fe32505fa6471fc14f2675861f81bf5a3a'),
]
def count(data): return len(data.splitlines())
for root, before, reviewed in repos:
    print(root)
    for ref in (before, reviewed):
        names = subprocess.check_output(['git', '-C', root, 'ls-tree', '-r', '--name-only', ref], text=True).splitlines()
        nix = [name for name in names if name.endswith('.nix')]
        total = sum(count(subprocess.check_output(['git', '-C', root, 'show', f'{ref}:{name}'])) for name in nix)
        print(ref, total, 'excluding-root-flake', total - count(subprocess.check_output(['git', '-C', root, 'show', f'{ref}:flake.nix'])))
    names = subprocess.check_output(['git', '-C', root, 'ls-files', '--cached', '--others', '--exclude-standard'], text=True).splitlines()
    nix = [name for name in names if name.endswith('.nix') and pathlib.Path(root, name).is_file()]
    total = sum(count(pathlib.Path(root, name).read_bytes()) for name in nix)
    without_root = sum(count(pathlib.Path(root, name).read_bytes()) for name in nix if name != 'flake.nix')
    print('CURRENT', total, 'excluding-root-flake', without_root)
PY
```
