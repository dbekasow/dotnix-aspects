# 12: Use Git, Helix, and development tools without host side effects

**What to build:** Make development capabilities individually consumable without unwanted host activation. Git/VCS tools, Helix and its language configuration, automation, Kubernetes, and other existing development tools remain with their respective feature owners.

**Blocked by:** [02: Reorganize feature ownership and discovery around the confirmed criterion](02-feature-ownership-discovery.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] Git, Git aliases, GitHub CLI, Lazygit, Delta, and Difftastic retain separate selections; an existing host Git contribution remains explicitly selectable.
- [x] Helix, Helix keys, and existing Bash/Fish/JSON/Just/Markdown/Nix/Python/Text/TOML/YAML LSP configurations remain usable without a mandatory language matrix.
- [x] Bacon, Just, Watchexec, Kubernetes, and other existing DevOps/automation capabilities remain consumable.
- [x] A home selection activates neither Docker nor Nix-LD as a hidden host prerequisite; host facets remain explicit host selections.
- [x] Native options remain overridable; no Development profile is required for an individual tool, and no per-language test matrix is introduced.

## Integration evidence

The `development` profile no longer pulls host capabilities through a Home selection. Removed couplings and where each capability lives now:

- `docker` — dropped from `profiles/development.nix`; stays `dotnix.docker` in `features/docker.nix` (nixos, homeManager and homePersistence facets), selected explicitly.
- `host.nix-ld` — dropped from `profiles/development.nix`; stays `dotnix.host.nix-ld.nixos` in `features/nix-ld.nix`, selected explicitly.
- `helix` — dropped `helix` from `features/system-packages.nix`, so Home no longer needs a host package slot; the Home feature `dotnix.helix` (with `dotnix.helix-keys`) stays in `features/helix/` as 12 files including 10 LSP modules (bash, fish, json, just, markdown, nix, python, text, toml, yaml) — no per-language matrix, no profile requirement.
- `git` — host contribution moved from `dotnix.git.nixos` to `dotnix.host.git.nixos` in `features/git.nix`, and `profiles/core.nix` now includes `host.git`, so the previous host Git contribution survives as an explicit host selection while `dotnix.git` remains Home-only.

Host cache-trust leak and fix: the llm-agents host facet moved from `dotnix.llm-agents.nixos` to `dotnix.host.llm-agents.nixos` in `features/llm-agents.nix`. A Home-only development selection therefore no longer injects the `numtide` substituter, its trusted key or the shared overlay into the host. Reconciliation with ticket 13: `features/ai-tools.nix` keeps the `pkgs.llm-agents or inputs.llm-agents.packages.<system>` precedence, so the captured-input fallback works without the overlay and no overlay dependency is reintroduced.

Measured host `nix.settings` comparison (Home-only `dotnix.development` versus the adapter-only baseline, both evaluated through the public consumer seam with the library input renamed and no ambient overlays):

| list                        | home-only development                                                | adapter-only baseline          |
| --------------------------- | -------------------------------------------------------------------- | ------------------------------ |
| `substituters`              | `["https://cache.nixos.org/"]`                                       | `["https://cache.nixos.org/"]` |
| `extra-substituters`        | `[]`                                                                 | `[]`                           |
| `trusted-public-keys`       | `["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="]` | same                           |
| `extra-trusted-public-keys` | `[]`                                                                 | `[]`                           |

Identical on all four lists; with an explicit `dotnix.host.llm-agents` selection the host regains `substituters = ["https://cache.numtide.com" "https://cache.nixos.org/"]` and `niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=`.

Commands and results, run in the integration worktree at this merge:

- `nix eval --impure --json --file tests/broad-compositions.nix` — 52/52 true, including the new `developmentHomeKeepsHostPrerequisitesExplicit`, `standaloneDevelopmentToolNeedsNoProfile`, `homeGitSelectionDoesNotEnableHostGit` and `hostGitRemainsExplicitlySelectable`, with the ticket 05 account selections and ticket 13 assertions intact.
- `nix eval --impure --file tests/headless-composition.nix` — `"headless and workstation composition checks passed"`.
- `nix eval --impure --json --file tests/niri-dms.nix` — 33/33 true.
- `nix flake check --no-build --no-write-lock-file` — all checks passed.
- `typos --force-exclude --format brief --hidden .` — exit 0.
- `nix fmt -- --ci` — 223 files, 0 changed, worktree clean.

Evidence scope: evaluation only. No build, activation or runtime proof was produced, and `flake.nix`/`flake.lock` are unchanged by this ticket.
