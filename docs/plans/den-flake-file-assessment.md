# Den / flake-file architecture assessment

Status: historical planning evidence; implementation is not authorized. This assessment supplements, and does not replace or amend, the decision record. Existing production files, inputs, lockfiles, and deleted planning artifacts remain untouched.

> **Superseded recommendation:** Earlier advice here against a setup module and to keep popup-launcher Quirk registration consumer-owned is superseded by the approved inert default consumer adapter, which registers library-owned global contracts without enabling features. Namespace import alone still does not register Quirks. Pinned source facts and historical probes below remain valid. See the [approved target architecture](den-architecture-target.md) and [canonical spec](../../.scratch/den-flake-file-redesign/spec.md).

## Finding

Keep Den's namespace as the sole aspect export. Do not add wrapper exports, factories, alias surfaces, required profile tiers, or a dependency registry for parity. Existing aspect-local contributions, optional domain profiles, persistence classes/policies, and the explicit popup-launcher Quirk have concrete uses. The first implementation slice must fix the verified scope leak: selecting PipeWire for one user currently enables its NixOS child on the host. Supported library home-selection entry points should carry no OS-class contribution; prefer a separate explicit host/home selection interface, co-locating implementations where practical. A global schema-isolation flag is not a drop-in fix: the parent counterprobe also removed integrated Home Manager and the user's own-class route. This contract does not protect arbitrary consumer-authored OS modules placed in user scope. See the [supplemental Den feature research](den-feature-research.md) for source and runtime evidence.

## Research boundary

This is a bounded evidence assessment, not a complete Den feature survey. The [supplemental Den feature research](den-feature-research.md) records the completed, pinned-source investigation and isolation counterprobe; it narrows the scope decision but is not an exhaustive Den audit or implementation approval.

## Evidence matrix

| Classification         | Evidence                                                                                                                                                                                                                                                                                                                        | Assessment                                                                                                                                                                                                                    |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Already appropriate    | [modules/expose.nix](../../modules/expose.nix) exports aspects through `den.namespace "dotnix"`; [templates/dotnix/modules/parts.nix](../../templates/dotnix/modules/parts.nix) imports that export.                                                                                                                            | Keep one Den namespace. No parallel module factory or alias needed.                                                                                                                                                           |
| Already appropriate    | [modules/aspects/system/pipewire/pipewire.nix](../../modules/aspects/system/pipewire/pipewire.nix) keeps the NixOS service and its WirePlumber home-persistence contribution together. [impermanence.nix](../../modules/aspects/system/impermanence.nix) routes the generic `homePersistence` class to integrated Home Manager. | Co-location is coherent; selection scope is the defect, not contribution organization.                                                                                                                                        |
| Already appropriate    | [impermanence.nix](../../modules/aspects/system/impermanence.nix) defines home/system persistence classes and policies used by current features. [tests/broad-compositions.nix](../../tests/broad-compositions.nix) observes selected persistence and unrelated-user absence.                                                   | Retain these real class/policy uses; avoid speculative classes or policies.                                                                                                                                                   |
| Already appropriate    | [modules/aspects/desktop/apps/handy/handy.nix](../../modules/aspects/desktop/apps/handy/handy.nix) adds Niri bindings only when Niri options exist. [tests/niri-dms.nix](../../tests/niri-dms.nix) already covers Niri, DMS, Noctalia, and Handy combinations.                                                                  | Keep compatible applications composable; validate only genuinely exclusive collisions on one target.                                                                                                                          |
| Already appropriate    | The shared `popup-launcher` Quirk is explicitly declared by the consumer in [templates/dotnix/modules/parts.nix](../../templates/dotnix/modules/parts.nix) and consumed by existing popup backends in [tests/broad-compositions.nix](../../tests/broad-compositions.nix). The namespace does not register `den.quirks`.         | Keep this explicit consumer declaration documented. No setup-module export, new classes, or Pipes are justified absent a concrete need. Keep the existing `flake-scope` dependency; do not speculate about a context rewrite. |
| Concrete improvement   | Parent's scratch consumer evaluation found user-only PipeWire selection activates host PipeWire. Details and replay recipe below.                                                                                                                                                                                               | Scope safety is a demonstrated first-slice defect. Correctly scoped success alone is not an adequate regression test.                                                                                                         |
| Concrete improvement   | [impermanence.nix](../../modules/aspects/system/impermanence.nix) combines generic persistence routing with Btrfs `@root` rollback, fixed device label, and subvolume assumptions.                                                                                                                                              | Select/separate generic persistence capability from explicit root-reset/storage behavior without removing either capability or redesigning boot/storage defaults.                                                             |
| Concrete improvement   | The broad evaluation fixture injects NUR, llm-agents, and Niri overlays globally in [tests/broad-compositions.nix](../../tests/broad-compositions.nix). Handy uses `pkgs.llm-agents.handy` but has no local dependency declaration in [handy.nix](../../modules/aspects/desktop/apps/handy/handy.nix).                          | Narrow reference fixtures to declared prerequisites where relevant. Handy is a static prerequisite risk, not a reproduced failure; verify before claiming a bug.                                                              |
| Concrete improvement   | [templates/dotnix/flake.nix](../../templates/dotnix/flake.nix) is the bootstrap input/output definition; generated declarations also live in [templates/dotnix/modules/parts.nix](../../templates/dotnix/modules/parts.nix), while aspects can add input declarations.                                                          | Test bootstrap → generation → evaluation → second generation for stable flake text and selected behavior. Account for lockfile writes and auto-follow state. Do not infer input propagation from moving declarations.         |
| Targeted investigation | The pinned flake-file auto-follow default is on; generated follows depend on existing input declarations and the existing flake. Its helper removes automatically managed nested follows, preserves existing follows, and rejects `autoFollow = false` with configured follows.                                                 | Test the pinned workflow in a disposable fixture before changing explicit follows. Do not recommend incompatible auto-follow/follows settings.                                                                                |
| Concrete improvement   | The parent tested `den.schema.user.isolated`: it blocked host PipeWire but also removed Home Manager integration and the user's own-class route. See the [counterprobe](den-feature-research.md#focused-counterprobe-isolated-users).                                                                                           | Do not use the global isolation flag as a shortcut. Prefer supported home entry points without OS-class contributions and an explicit host/home selection interface; co-locate implementations where practical.               |
| Targeted investigation | [tests/consumer-lifecycle.sh](../../tests/consumer-lifecycle.sh) is untracked user work and defaults its consumer argument to `/home/denis/projects/dotnix`; it also checks generation twice and lock hashes.                                                                                                                   | Keep this script untouched in planning. Any reusable lifecycle fixture must be disposable and independent of a private sibling repository.                                                                                    |
| Targeted investigation | CI runs `nix flake check` and builds the exported template's NixOS toplevel in [.github/workflows/flake-check.yml](../../.github/workflows/flake-check.yml). The supplied run inventory says CI does not explicitly invoke `tests/*.nix`.                                                                                       | Reuse existing check/build gates. Wire a compact routing projection once; do not multiply suites or duplicate the template build.                                                                                             |
| Deliberately unused    | Existing decisions allow public interface redesign but require preserving capabilities absent explicit removal approval.                                                                                                                                                                                                        | No compatibility shim solely for parity; no capability deletion or forced defaults.                                                                                                                                           |
| Deliberately unused    | Unused feature inputs may be present; selective inclusion is investigative, not an architectural prerequisite.                                                                                                                                                                                                                  | No public input factory or dependency registry without measured need. Keep feature input declarations co-located and essential follows/identity explicit.                                                                     |
| Deliberately unused    | Pareto test strategy rejects declaration-mirroring option tests, exhaustive invalid-combination matrices, quotas, and a VM per feature.                                                                                                                                                                                         | Use a few effective-option observations at the consumer boundary and existing suites/builds. No global desktop restriction.                                                                                                   |

## Verified runtime evidence

### PipeWire scope leak

Parent ran a minimal scratch `nix eval --impure --json` consumer evaluation against the pinned source, with no repository edits. Reproduction shape: construct a `flake-parts` consumer via `mkFlake`; import the pinned Den flake module and `den.namespace "dotnix"`; enable Den's flake-scope battery; define one NixOS host with one integrated Home Manager user `alice`; set that user's NixOS `home` to `/home/alice` and provide valid host/user state versions; leave host includes empty; select only `source.denful.dotnix.pipewire` in `provides.alice.includes`. Evaluate a second baseline with the same host and no user feature. A runnable equivalent is below. Save it as `/tmp/pipewire-scope-probe.nix`, run `nix eval --impure --json --file /tmp/pipewire-scope-probe.nix`, and do not write it into the source tree. This is a repeatable scratch probe, not a source test or a product build.

```nix
let
  source = builtins.getFlake (toString /home/denis/projects/dotnix-aspects);
  inputs = source.inputs // { dotnix = source; self = source; };
  dotnix = source.denful.dotnix;
  system = "x86_64-linux";
  evaluate = userIncludes:
    let
      fixture = {
        imports = [
          inputs.den.flakeModule
          (inputs.den.namespace "dotnix" [ inputs.dotnix true ])
          ({ den, ... }: {
            den.default.includes = [ den.batteries.flake-scope ];
          })
        ];
        den.hosts.${system}.probe = {
          users.alice.classes = [ "homeManager" ];
          instantiate = args: inputs.nixpkgs.lib.nixosSystem args;
        };
        den.aspects.probe = {
          includes = [ ];
          nixos = {
            system.stateVersion = "25.11";
            nixpkgs.hostPlatform = system;
            users.users.alice.home = "/home/alice";
          };
          provides.alice = {
            includes = userIncludes;
            homeManager = {
              home.username = "alice";
              home.homeDirectory = "/home/alice";
              home.stateVersion = "25.11";
            };
          };
        };
      };
      flake = inputs.flake-parts.lib.mkFlake { inherit inputs; } fixture;
    in
    flake.nixosConfigurations.probe.config;
  baseline = evaluate [ ];
  userOnly = evaluate [ dotnix.pipewire ];
in
{
  baselineHostPipewire = baseline.services.pipewire.enable or false;
  userOnlySelectionHostPipewire = userOnly.services.pipewire.enable or false;
}
```

Exact output:

```json
{ "baselineHostPipewire": false, "userOnlySelectionHostPipewire": true }
```

This demonstrates user-only selection activates a NixOS child. The existing broad suite selects PipeWire for both host and user, so its successful route observations cannot detect this leak. The regression must reject wrong-scope activation and also check the intended user, an unrelated user, and a host-only selection against a distinct non-selected host. The isolation counterprobe found that `den.schema.user.isolated = true` changes host PipeWire to false but also removes Home Manager integration and own-user class routing (and leaves Home Manager activation/Git absent). It is not a drop-in fix; see the [supplemental research](den-feature-research.md#focused-counterprobe-isolated-users). The supported library contract does not extend to arbitrary consumer-authored OS modules placed in user scope.

### Captured library input versus consumer input

Parent separately ran a corrected minimal consumer `nix eval --impure --json` for Direnv. The scratch consumer's root inputs were `builtins.removeAttrs source.inputs [ "direnv-instant" ]` plus `dotnix = source` and `self = source`; it imported Den and the dotnix namespace. The host had integrated user `alice`, with `users.users.alice.home = "/home/alice"`; Alice selected only `dotnix.direnv`, and the fixture supplied Home Manager username, home directory, and state version. It observed the activation derivation, consumer root-input absence, and feature enablement:

```json
{
  "activationConstructs": true,
  "consumerHasDirenvInput": false,
  "direnvInstantEnabled": true
}
```

This proves only that this feature's library-captured Direnv input works when the consumer lacks a same-named root input, and that an activation derivation can be constructed. It proves neither a build nor runtime behavior. The first attempt omitted the NixOS user's home and hit an upstream `/var/empty` versus `/home/alice` fixture conflict; correcting the fixture removed that error. It was not a product defect.

Keep input ownership precise: [direnv.nix](../../modules/aspects/term/shell-ux/direnv/direnv.nix) lexically captures `inputs.direnv-instant`; `dotnix.users = { inputs, ... }: ...` in [core/users.nix](../../modules/aspects/core/users.nix) is an aspect-level pipeline function whose `inputs.self` comes from consumer flake-scope context. The namespace does not forward library `flake-file.inputs` declarations. PipeWire has no dedicated external feature input. In its reference consumer, the consumer owns the Den/NixOS/integrated-Home-Manager setup and explicit persistence selection; the persistence aspect owns its declared Impermanence dependency. This records provenance, not external captured-input lifecycle proof; Direnv remains the complementary lifecycle case. Do not infer that every library dependency must also be declared as a same-named consumer input. No blanket dependency registry is justified by current evidence.

## Existing verification and blind spots

- Parent ran `nix eval --impure --json --file tests/broad-compositions.nix` from the target repository: exit 0, 30 checks, none false. This is a runtime baseline, not proof of host/user isolation.
- The broad fixture globally injects NUR, llm-agents, and Niri overlays, which can hide missing prerequisites. The Handy concern remains static until independently reproduced.
- Existing Niri/DMS tests demonstrate compatible combinations, but DMS and Noctalia both contribute Niri keybinds. A targeted negative test should cover only the actual exclusive same-target conflict and require a useful error, not a fixed error-string snapshot.
- CI currently runs `nix flake check` and a real template toplevel build. The latter is stronger than evaluation for the DMS family, which lacks a binary cache. No new VM build per feature.
- No full `nix flake check`, template build, or consumer lifecycle run was performed in this planning phase.

## Pinned primary-source evidence

Pinned Den: [`7594405b45e0ce2d5a418fe104a26e17f6b1dd8f`](https://github.com/denful/den/tree/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f). Source-reviewed references:

- [Namespace export](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/nix/lib/namespace.nix): exports the evaluated namespace and imports external classes; no flake-level input declarations.
- [flake-scope battery](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/modules/aspects/batteries/flake-scope.nix): resolves `pipelineOnly` inputs/lib/den with class precedence; it does not replace lexical closures.
- [Where configuration lands](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/docs/src/content/docs/explanation/where-config-lands.mdx): host `homeManager` is ignored; `provides.<user>` is explicit; user `nixos`/`os` currently emits to host, with issue #694 and documented named-host child fan-out. Do not rely on named-host children as a safety boundary.
- [Policy activation](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/docs/src/content/docs/explanation/policy-activation.mdx), [Quirks](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/docs/src/content/docs/guides/quirks.mdx), and [custom classes](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/docs/src/content/docs/guides/custom-classes.mdx): documented mechanisms; these are source references, not a live probe of every API.

Pinned flake-file: [`4ccd0b92aee0943b94324ec4c39949df1769f123`](https://github.com/vic/flake-file/tree/4ccd0b92aee0943b94324ec4c39949df1769f123). Source-reviewed references:

- [write-flake](https://github.com/vic/flake-file/blob/4ccd0b92aee0943b94324ec4c39949df1769f123/modules/write-flake.nix): compares generated content, runs `nix flake lock`, invokes `flake-edit --no-lock follow`, performs offline locking/hooks, checks diffs, and reruns follow in a temporary fixture.
- [auto-follow](https://github.com/vic/flake-file/blob/4ccd0b92aee0943b94324ec4c39949df1769f123/modules/auto-follow.nix): default is `mkDefault true`.
- [auto-follow merge helper](https://github.com/vic/flake-file/blob/4ccd0b92aee0943b94324ec4c39949df1769f123/dev/modules/_lib/default.nix): removes configured nested follows when automatically managed, preserves existing follows, and errors for `autoFollow = false` with configured follows.
- [input options](https://github.com/vic/flake-file/blob/4ccd0b92aee0943b94324ec4c39949df1769f123/modules/options/inputs.nix): typed, ordinarily merged module options.

## Planning boundaries

The README and template still link to a deleted verification document. Replace those references with current planning/verification documentation in an approved documentation slice; do not restore deleted AGENTS or OpenSpec files. The consumer lifecycle script is existing untracked work and remains untouched. This repository's issue tracker is configured for local Markdown (see [issue-tracker guidance](../agents/issue-tracker.md)); implementation-ticket publication still awaits parent-user approval of ticket granularity and blockers. Do not use a tracker belonging to another repository.
