# Consumer-scoped loading for Dotnix Aspects

Status: resolved

## Problem Statement

A WSL-only Consumer needs to use the Aspect library without importing desktop modules or locking their optional dependencies. The current library-flake interface brings the full library input graph into the Consumer. The previous solution generates a flake and lockfile per configuration target, adds a separate selection catalogue and requires a target-specific generation workflow. That is more isolation and maintenance than needed: hosts in one Consumer may share inputs even when they select different features.

## Solution

Replace the current Consumer entry point with explicit, source-only imports. Every Consumer imports **Base** and can independently opt into **Desktop** and **DevTools**. The Consumer has one generated flake and lockfile. Den continues to control the host, home, and account selections within that Consumer. Cut over the public interface, published Consumer template, and private `dotnix` Consumer together, without a compatibility loader or additional shell scripts.

## User Stories

1. As a WSL-only Consumer maintainer, I want to omit Desktop so that no Desktop modules are imported when I generate or evaluate my flake.
2. As a WSL-only Consumer maintainer, I want Desktop-only inputs absent from the reachable lock graph so that locking my configuration does not pull in a GUI dependency tree.
3. As a mixed Consumer maintainer, I want one shared lockfile so that I do not manage pins separately for each host.
4. As a host maintainer, I want importing Desktop to register features without applying them so that an ISO, WSL or other headless host remains headless in a mixed Consumer.
5. As an occupant, I want graphical configuration limited to the selected home so that other homes do not inherit my desktop settings.
6. As a Consumer maintainer, I want to keep the existing Den selection names so that changing import groups does not require a new syntax for composing features.
7. As a terminal user, I want the terminal profile without a Wayland dependency so that I can use it without Desktop.
8. As a graphical user, I want to keep the Wayland clipboard and graphical pinentry options so that I can opt into those features without changing the CLI defaults for others.
9. As a developer, I want CLI development features without DevTools so that Hunk and the rest of my configured home do not depend on Consumer repository tooling.
10. As a Consumer maintainer, I want DevTools without Desktop so that development shells, formatting, checks, and vault commands can be used in a non-graphical Consumer.
11. As a Consumer maintainer, I want to add or remove an import group with the existing flake writer and ordinary Nix commands so that I do not have to run or maintain custom scripts.
12. As a new Consumer maintainer, I want the published template to demonstrate the new interface so that a fresh configuration does not start on the retired adapter.
13. As the private Consumer maintainer, I want `luffy` and `roger` to migrate together without changing their intended features, resources, or role as desktop and ISO targets.
14. As the private Consumer maintainer, I want my existing lockfile changes and unrelated pins respected so that the migration does not discard my work or silently upgrade my dependencies.
15. As an Aspect library maintainer, I want one set of feature modules and the existing library checks so that I do not maintain two catalogues or duplicate the verification suite.

## Implementation Decisions

- Follow [ADR 0007](../../docs/adr/0007-scope-imports-and-inputs-to-the-consumer.md). Build the replacement from the pre-target-loading baseline on `main`; retain the independent-target work and ADR as history, not as a path to merge or extend. Preserve the library's standalone development and verification workflow.
- The Consumer pins the Aspect library as a source-only input. It owns its core flake inputs directly; it cannot follow through the former library flake to its dependency graph. Keep tracked pins reproducible and do not require a checkout-specific absolute path as the supported interface.
- Use native `import-tree` within explicit group directories (`modules/base`, `modules/desktop`, and `modules/devtools`). Base must not discover Desktop files. Only the library flake imports `modules/standalone`. Keep a single implementation of each feature or profile and retain the established `dotnix.host.*`, `dotnix.home.*`, and `dotnix.account.*` selection interface. Do not add a feature manifest, resolver, or host-dependent import selector.
- Base contains non-graphical features and profiles, including terminal, CLI development, and shared features needed without Desktop. XDG user directories stay in Base because `home.core` includes them. Keep the input used by Hunk available independently of DevTools.
- Desktop contains graphical foundations, compositors, shells and greeters, graphical applications, and GUI integrations. The existing Graphical profile remains an explicit Den selection, not a side effect of importing Desktop. Move the Wayland clipboard out of `term-ux`; keep it available via `home.graphical` or explicit selection. Keep CLI GPG and RBW defaults in Base and their graphical pinentry variants in Desktop. Hide no compositor or application selection inside an import group.
- DevTools is independent of Desktop and preserves the current development shell, formatter, checks/hooks, and vault commands. Runtime Age/Rekey configuration remains usable without DevTools. Only declare optional `follows` edges where the target input exists in that group's generated graph; an upstream dependency's own transitive graph is not the same as opting into the Consumer's DevTools group.
- Selected modules contribute `flake-file.inputs` to one Consumer flake. Declarations for an added group must be evaluable before its inputs exist; module imports that need those inputs must not block the first run of the existing `write-flake` app. After normal Nix locking, the selected modules use the real inputs. Removing a group and regenerating/relocking removes its group-only dependencies. There is no added shell script, target writer, or lock seeding step.
- Replace the public entry point directly. Migrate the published Consumer template and the private `dotnix` Consumer in the same cutover. Translate private selections to the current Den interface only where necessary; preserve intended host/home/account behavior and the ISO output, except that Denis on `luffy` selects the Herdr terminal profile and no longer selects `denis-repos`. Keep `luffy` on Noctalia with its existing greeter. Verify that Git and RBW resolve identity with the existing primary email account and any explicit override. Review and preserve the private checkout's existing changes before touching its lockfile. Do not opportunistically change pins, host settings, secrets, identities, or storage choices.

## Testing Decisions

- Verify at one public seam: a Consumer's generated flake, reachable lock graph, and evaluated configuration outputs. Prefer adapting the existing Consumer generation, headless, graphical, and terminal checks to this seam. Do not add a new test matrix or test internal loader structure.
- **WSL-only:** A Base Consumer can generate, lock, and evaluate representative terminal/CLI configuration without Desktop. Verify both absence of registered Desktop implementations and absence of Desktop-only inputs in the reachable lock graph; a disabled Niri option alone is insufficient. With DevTools omitted, Base must not have dangling follows to DevTools inputs. Exercise the initial DevTools opt-in through the existing writer and normal locking to catch missing-input bootstrap failures, without introducing another fixture family.
- **Mixed Consumer:** The private `dotnix` Consumer uses one lockfile. Its `luffy` desktop selections, `roger` ISO output, and DevTools still evaluate; graphical configuration does not spill over to the headless target. Verify the published Consumer template also evaluates through the new interface. Reuse existing host/home selection checks rather than repeating the same assertion for each feature.
- Run the existing formatting and flake checks after integration. Evaluation and build results must be reported separately; passing evaluations are not evidence of activation or hardware behavior.

## Out of Scope

- Per-target flake generation, independent per-host lockfiles, or strict per-host import isolation inside a mixed Consumer.
- Finer-grained Desktop splits, new group abstractions, or changes to unrelated profiles or features.
- A parallel legacy Consumer entry point, shell wrappers, or a rewrite of the library development workflow.
- An actual WSL deployment, activation on private machines, hardware/runtime validation, or unrelated input updates.

## Further Notes

The isolated, offline experiment with the pinned tools proved the source-only/import-tree/flake-file workflow using the production Niri feature. WSL-only had no Niri registration or reachable Niri inputs; a mixed Consumer enabled Niri only on Desktop; removing the opt-in restored the original flake and lock byte for byte. The experiment did not verify the complete Desktop group, DevTools bootstrap, or the private Consumer cutover. Those are implementation acceptance work, not results already obtained.
