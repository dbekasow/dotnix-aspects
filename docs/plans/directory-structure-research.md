# Directory structure research: Den, flake-file, import-tree

Research date: **2026-10-24**. Status: **evidence and advisory only; not an approved design revision or implementation authorization**.

## Answer in brief

**Yes: the illustrative target can become shallower without weakening its ownership boundaries.** Prefer a root `features/` catalog, a few problem-domain groups where they help navigation, single files for small features, and private local subtrees for complex features. Keep explicit assembly/consumer entry points outside feature discovery. Do not replicate the public `dotnix.host/home/account` selection tree in filesystem paths.

The strongest transferable upstream patterns are not particular category names:

1. Den separates its discoverable module tree from its library implementation and explicit public export table.
2. flake-file publishes explicit named adapters, uses explicit imports inside complex features, and keeps development configuration separate. Its root `default.nix` is a bootstrap entry point, not its consumer module.
3. Actual users co-locate feature declarations, inputs, persistence contributions and optional sub-aspects. They also demonstrate both underscore-private helpers and ordinary `.nix` files that are **module-shaped registrations**, not helper data.
4. import-tree really does exclude `/_` by default, but only under precise discovery semantics. This is neither module-shape validation nor a security/targeting boundary.

The approved behavioral contract remains unchanged: one namespace; role-pure supported selections; inert adapter registering Den, namespace and library-owned global contracts; namespace alone without Quirks; optional devTools; native options/resources; preserved capabilities; no producer/adapter/generator recursion; discovery of module-shaped entries only. Migration cost and compatibility are deliberately not scoring criteria.

## Method, scope and version discipline

Read local `AGENTS.md`, domain and issue-tracker pointers, `GLOSSARY.md`, [approved illustrative target](den-architecture-target.md), [canonical composition spec](../../.scratch/den-flake-file-redesign/spec.md), its documentation pointer, `modules/expose.nix`, and relevant lock entries. `docs/adr/` does not exist; no placeholder created. Existing baseline evidence reports 147 aspect Nix files across six broad top-level groups; that is inherited context, not a fresh inventory count here.

Online discovery used web search, then unauthenticated public GitHub/Codeberg metadata, recursive source trees and raw source files. Search summaries and README directory lists were leads, not evidence for import mechanics. No remote tracker operation, credentials, sibling `dotnix` access, Nix build, generation lifecycle, implementation, staging or commit occurred. Only this new note is an authorized repository edit.

Public APIs resolve `denful/den` to **denful/den**. They currently redirect **vic/flake-file → denful/flake-file** and **vic/import-tree → denful/import-tree**. Existing input spellings are not proposals to update pins. Exact metadata endpoints: [Den](https://api.github.com/repos/denful/den), [flake-file old spelling](https://api.github.com/repos/vic/flake-file), [import-tree old spelling](https://api.github.com/repos/vic/import-tree).

| Source                                  | Inspected revision                         | Version qualification                                                                                                                      |
| --------------------------------------- | ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Den upstream                            | `0f7675b0b789eabe1a62f8a31b5323a7ad3ca5c4` | API commit date 2026-10-21; canonical repository verified                                                                                  |
| Den target pin                          | `7594405b45e0ce2d5a418fe104a26e17f6b1dd8f` | Local `flake.lock`; entry discovery and namespace implementation inspected                                                                 |
| flake-file upstream, date-bounded       | `1281456a5218ac60ada6fcb40a8f894684940199` | Selected with [commits API until 2026-10-24](https://api.github.com/repos/denful/flake-file/commits?until=2026-10-24T23:59:59Z&per_page=1) |
| flake-file target pin                   | `4ccd0b92aee0943b94324ec4c39949df1769f123` | Local lock; explicit export/adapter assembly compared                                                                                      |
| import-tree upstream **and target pin** | `eb1b52eaecc57f7c136d07ae8a93e724dfecac46` | Identical SHA; API commit date 2026-09-03                                                                                                  |
| Gwenodai/nixos                          | `ab05d3c6e156b7651a1ec6ee874c553f71979734` | Most recent API commit at cutoff, dated 2026-07-02; actual Den user                                                                        |
| Adda/nixos-config                       | `3604ab65b1e6b4ef3d5e7e3ef5993e10efee0ab3` | Codeberg API commit date 2026-10-20; actual Den user                                                                                       |
| vic/vix, current                        | `7cdc0be0162518d70882d0a941fe0927428143e6` | API commit date 2026-10-23; **now Ren, not Den**                                                                                           |
| vic/vix, historical Den snapshot        | `5802915fa6b9444e444ae5e89b379b73b6763ac0` | Snapshot returned by date-bounded API before October; historical, not current Den API evidence                                             |

Important temporal limit: unrestricted flake-file HEAD returned `7b08dbc223bb1a758a515aad9653a6bf196bc772` dated **2026-10-25**. It is not used as evidence for the requested research date. No future revision date was invented. Public metadata can advance independently of this note's date.

## Observed upstream patterns

### 1. Den: explicit surface, narrow discovery root, separate implementation

**Observation.** Root [`default.nix`](https://github.com/denful/den/blob/0f7675b0b789eabe1a62f8a31b5323a7ad3ca5c4/default.nix) imports `./nix`. [`nix/default.nix`](https://github.com/denful/den/blob/0f7675b0b789eabe1a62f8a31b5323a7ad3ca5c4/nix/default.nix) explicitly exposes `namespace`, `lib`, `nixModule`, named `flakeModules`, templates and other outputs. [`nix/flakeModule.nix`](https://github.com/denful/den/blob/0f7675b0b789eabe1a62f8a31b5323a7ad3ca5c4/nix/flakeModule.nix) discovers only `../modules`, not all repository Nix files:

```nix
imports = builtins.filter (p: lib.hasSuffix ".nix" p && !lib.hasInfix "/_" p) (
  lib.filesystem.listFilesRecursive ../modules
);
```

That file is identical at the [target Den pin](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/nix/flakeModule.nix). The implementation under `nix/lib/` can therefore contain ordinary helper Nix files without becoming consumer module imports.

Batteries use both single files and local directories: [`modules/aspects/batteries/unfree/unfree.nix`](https://github.com/denful/den/blob/0f7675b0b789eabe1a62f8a31b5323a7ad3ca5c4/modules/aspects/batteries/unfree/unfree.nix) registers `den.batteries.unfree`. Directory shape does not derive the attribute name. [`namespace.nix` at the target pin](https://github.com/denful/den/blob/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f/nix/lib/namespace.nix) exports evaluated `config.den.ful.${name}` as `flake.denful.${name}`, merges source namespace attributes, and exposes the argument alias. It does not derive aspect names from filenames or register a Quirk registry. The [upstream namespace guide](https://github.com/denful/den/blob/0f7675b0b789eabe1a62f8a31b5323a7ad3ca5c4/docs/src/content/docs/guides/namespaces.mdx) likewise defines `eg.vim` in an arbitrarily named module.

**Transfer.** Separate discoverable definitions from helper implementation; explicitly publish adapter and namespace surfaces. Neither `library/` nor `features/` nor `modules/` is a Den requirement. Keep one `dotnix` namespace independent of source locations.

**Not transferable.** Den is the framework implementation. Its deep `nix/lib/aspects/fx/` machinery and many adapter choices are not a reason to add framework layers here. Its batteries may intentionally cross OS/home boundaries: that is not evidence that this library's supported home selections may do so.

### 2. flake-file: explicit exports and local feature assembly

**Observation.** [`flake.nix`](https://github.com/denful/flake-file/blob/1281456a5218ac60ada6fcb40a8f894684940199/flake.nix) is very small:

```nix
{ outputs = _: import ./modules; }
```

[`modules/default.nix`](https://github.com/denful/flake-file/blob/1281456a5218ac60ada6fcb40a8f894684940199/modules/default.nix) is an explicit table of public `flakeModules` and their import bundles. For example:

```nix
default.imports = [
  base
  ./write-flake.nix
  ./flake-parts.nix
];
dendritic.imports = [ ./dendritic ];
```

[`modules/dendritic/default.nix`](https://github.com/denful/flake-file/blob/1281456a5218ac60ada6fcb40a8f894684940199/modules/dendritic/default.nix) explicitly imports four sibling files. [`modules/tack/default.nix`](https://github.com/denful/flake-file/blob/1281456a5218ac60ada6fcb40a8f894684940199/modules/tack/default.nix) imports `./serialize.nix lib` as a **helper**, without underscore naming. This is safe from accidental discovery in that assembly because imports are explicit, not because `serialize.nix` is somehow intrinsically private.

Root [`default.nix`](https://github.com/denful/flake-file/blob/1281456a5218ac60ada6fcb40a8f894684940199/default.nix) imports `./modules/bootstrap`, a different responsibility. [`dev/modules/dendritic.nix`](https://github.com/denful/flake-file/blob/1281456a5218ac60ada6fcb40a8f894684940199/dev/modules/dendritic.nix) consumes the published module in a separate development flake via `path:..`.

The [target-pinned export table](https://github.com/denful/flake-file/blob/4ccd0b92aee0943b94324ec4c39949df1769f123/modules/default.nix) already has this explicit assembly pattern. Upstream later adds `lon`/`niv` choices; those additions do not change the directory argument here. No general API equivalence beyond inspected assembly is claimed.

**Transfer.** Explicit exports and private local helpers can be simpler than blanket scanning. Give assembly, consumer registration, tooling and generation distinct entry points. A feature directory earns its keep through real sibling files, not a mandatory `feature/default.nix` wrapper.

**Not transferable.** flake-file's default module is a generator integration with behavior; it is not precedent for making this library's default adapter activate features or generation. Do not copy its many supported pinning backends or add more adapters for taxonomy.

### 3. import-tree: exact default and override semantics

Decisive source: [`default.nix`](https://github.com/denful/import-tree/blob/eb1b52eaecc57f7c136d07ae8a93e724dfecac46/default.nix), corroborated by [`tests.nix`](https://github.com/denful/import-tree/blob/eb1b52eaecc57f7c136d07ae8a93e724dfecac46/tests.nix). This is **the same revision as the target pin**, not merely a newer README claim.

```nix
nixFilter = andNot (hasInfix "/_") (hasSuffix ".nix");
initialFilter = if initf != null then initf else nixFilter;
pathFilter = compose (and filterf initialFilter) toString;
```

**Observed semantics:**

- Directory scanning selects `.nix` leaves and rejects any relative path containing literal `/_`. `_helper.nix` and `_private/data.nix` are excluded; `foo_bar.nix` is not. `default.nix` has no special stopping/encapsulation privilege: recursive scanning still finds eligible sibling/descendant files.
- Paths passed to directory predicates are relative to **each supplied root**, with leading slash produced by stripping that root. An underscore in the supplied root itself is not an exclusion: explicitly scanning `./_private` can include its ordinary descendants.
- `.filter` predicates accumulate with AND and retain the initial default. `.filterNot` adds negation. `.match` uses `builtins.match`, hence full-string regex matching; use `.*` where substring matching is intended. `.matchNot` negates that match.
- `.initFilter` **replaces** the default predicate. Replacing it with only a `.nix` check also removes underscore exclusion unless explicitly retained.
- Explicit non-directory file arguments bypass the filters. An explicitly supplied `_helper.nix` is not protected by its name.
- `.map` transforms selected leaves; normal module mode returns a function containing `imports`. The library does not inspect whether each file returns a valid module for the caller's module system.
- Source first recursively enumerates files and then filters leaves. Underscore exclusion is not directory-traversal pruning, confidentiality, sandboxing, or scope isolation.

Upstream tests explicitly cover `a_b.nix`, nested `_c`, scanning a hidden root, explicit file roots, predicate composition and `initFilter` replacement. No scratch evaluation was needed to establish these source-level facts.

**Transfer.** With directory discovery, put feature-local data/helpers in `_private/` (or `_foo.nix`) and import them explicitly inside the correct class/function. Keep consumer entry points outside that discovery root. Non-Nix assets avoid the default suffix match, but `_private/` is still useful when the asset collection contains Nix package expressions or generated Nix. A directory named `optional/`, `lib/`, `config/` or `assets/` is **not** excluded by default.

## Actual user repositories: source, not README trees

### Gwenodai/nixos: deep taxonomy, module-shaped extensions

**Observation.** [`flake.nix`](https://github.com/Gwenodai/nixos/blob/ab05d3c6e156b7651a1ec6ee874c553f71979734/flake.nix) scans `./modules` using import-tree. [`modules/aspects/core/inputs.nix`](https://github.com/Gwenodai/nixos/blob/ab05d3c6e156b7651a1ec6ee874c553f71979734/modules/aspects/core/inputs.nix) imports Den and flake-file dendritic adapters. This establishes actual use of all three tools, despite older `vic/den` input spelling.

[`programs/vscode/vscode.nix`](https://github.com/Gwenodai/nixos/blob/ab05d3c6e156b7651a1ec6ee874c553f71979734/modules/aspects/programs/vscode/vscode.nix) owns its `flake-file.inputs.nix-vscode-extensions`, OS overlay, Home Manager behavior and persistence contributions. [`programs/vscode/optional/config/settings.nix`](https://github.com/Gwenodai/nixos/blob/ab05d3c6e156b7651a1ec6ee874c553f71979734/modules/aspects/programs/vscode/optional/config/settings.nix) is **not private helper data**: it registers `den.aspects.vscode.config`. Discovery loads this definition; the `optional` directory does not itself control activation. [`services/audio.nix`](https://github.com/Gwenodai/nixos/blob/ab05d3c6e156b7651a1ec6ee874c553f71979734/modules/aspects/services/audio.nix) keeps PipeWire, rtkit and user persistence in one file. [`core/preservation/class/classes.nix`](https://github.com/Gwenodai/nixos/blob/ab05d3c6e156b7651a1ec6ee874c553f71979734/modules/aspects/core/preservation/class/classes.nix) registers forwarding behavior alongside that feature rather than in a remote global integration tree.

**Transfer.** Feature-local inputs, persistence and selectable sub-aspects; single-file audio; source paths need not equal public attribute paths.

**Do not transfer.** Deep `aspects/programs/vscode/optional/config/…` nesting adds navigation without a reusable-library requirement. Copying class factories, host/user conventions or combined OS/home aspects would violate the approved simplicity/role-purity constraints. These files are structural evidence, not evaluation proof of their scope behavior.

### Adda/nixos-config: plumbing separate from nested namespace features

**Observation.** Current [`flake.nix`](https://codeberg.org/Adda/nixos-config/src/commit/3604ab65b1e6b4ef3d5e7e3ef5993e10efee0ab3/flake.nix) scans `./modules`. [`plumbing/den/default.nix`](https://codeberg.org/Adda/nixos-config/src/commit/3604ab65b1e6b4ef3d5e7e3ef5993e10efee0ab3/modules/plumbing/den/default.nix) imports Den/flake-file through the project's omniflake integration. [`plumbing/den/namespaces.nix`](https://codeberg.org/Adda/nixos-config/src/commit/3604ab65b1e6b4ef3d5e7e3ef5993e10efee0ab3/modules/plumbing/den/namespaces.nix) separately registers a local `addax` namespace; [`plumbing/den/quirks/helix-settings.nix`](https://codeberg.org/Adda/nixos-config/src/commit/3604ab65b1e6b4ef3d5e7e3ef5993e10efee0ab3/modules/plumbing/den/quirks/helix-settings.nix) separately declares a Quirk.

[`aspects/audio/pipewire.nix`](https://codeberg.org/Adda/nixos-config/src/commit/3604ab65b1e6b4ef3d5e7e3ef5993e10efee0ab3/modules/aspects/audio/pipewire.nix) defines `addax.audio.pipewire.nixos` in one short file. [`aspects/console/default.nix`](https://codeberg.org/Adda/nixos-config/src/commit/3604ab65b1e6b4ef3d5e7e3ef5993e10efee0ab3/modules/aspects/console/default.nix) composes explicitly named child features **and** contains substantial personal configuration. It is a module discovered like other files, not automatic directory aggregation. [`aspects/console/shells/aliases.nix`](https://codeberg.org/Adda/nixos-config/src/commit/3604ab65b1e6b4ef3d5e7e3ef5993e10efee0ab3/modules/aspects/console/shells/aliases.nix) defines `addax.shells.aliasesAbbreviations`: namespace path omits physical `console/`.

[`aspects/work-vm/default.nix`](https://codeberg.org/Adda/nixos-config/src/commit/3604ab65b1e6b4ef3d5e7e3ef5993e10efee0ab3/modules/aspects/work-vm/default.nix) explicitly imports local `_hardware.nix` in its NixOS module and reads `_plannotator-ports.nix` as data. Its own comment identifies underscore exclusion as the reason the latter is not discovered as an aspect module.

**Transfer.** Separate global registration from namespace features, local private helper imports, short single-file capabilities, physical/public path independence.

**Do not transfer.** Personal hosts, VM disk/boot/account conventions, omniflake architecture, umbrella package selections or user-routing policy. This is a personal configuration, not evidence that every reusable library needs a `plumbing/den/classes/quirks` hierarchy.

### vic/vix: useful historical Den example; current project moved on

Den's current [README](https://github.com/denful/den/blob/0f7675b0b789eabe1a62f8a31b5323a7ad3ca5c4/README.md) links vic/vix as an in-the-wild configuration. **Follow-through matters:** its [current flake](https://github.com/vic/vix/blob/7cdc0be0162518d70882d0a941fe0927428143e6/flake.nix) uses `inputs.ren.lib.mkFlake`, not Den. Do not present that checkout as current Den practice.

The inspected historical Den snapshot has [`default.nix`](https://github.com/vic/vix/blob/5802915fa6b9444e444ae5e89b379b73b6763ac0/default.nix) importing npins/with-inputs and passing `inputs.import-tree ./modules` to flake-parts. [`modules/den.nix`](https://github.com/vic/vix/blob/5802915fa6b9444e444ae5e89b379b73b6763ac0/modules/den.nix) explicitly imports Den, exports `vix`, and keeps `vic` local. [`community/vix/macos-keys.nix`](https://github.com/vic/vix/blob/5802915fa6b9444e444ae5e89b379b73b6763ac0/modules/community/vix/macos-keys.nix) registers `vix.macos-keys` and explicitly imports adjacent `_macos-keys.nix`. [`vic/fish.nix`](https://github.com/vic/vix/blob/5802915fa6b9444e444ae5e89b379b73b6763ac0/modules/vic/fish.nix) keeps `_fish/{functions,aliases,abbrs}.nix` and a Fish asset local.

**Transfer.** Public catalog distinct from private personal selections; underscore-private local implementation; exported names independent of deeper `community/vix/` path.

**Do not transfer.** Two namespaces (approved baseline requires one), automatic `vic.everywhere` selections, shell/account coupling or current Ren channels/framework. Historical example corroborates organization only, not current Den API compatibility. Gwenodai and Adda provide two independently verified Den-user repositories without relying on the historical example.

## Complementary primary-source anchors verified by the parent researcher

These sources were inspected independently by the parent researcher and supplied for inclusion; this worker did not duplicate that research. They corroborate rather than determine the ecosystem-specific recommendation above.

- mightyiam/dendritic [`README.md`, “File path independence” and “Fanaticism”](https://github.com/mightyiam/dendritic/blob/6c76240658cf1c840faad557c0e0726064170a65/README.md): paths represent features and may be moved, renamed or split; no mandatory tree. The text permits interspersed `callPackage` files and suggests a `.pkg.nix` exclusion convention. **Inference for this library:** feature locality can include package expressions, but import-tree's default does **not** exclude `.pkg.nix`; either add an explicit filter or use the already supported underscore-private subtree. Its enable-option advice addresses activation semantics, not permission to violate this library's inert registration or native override contract.
- Official flake-parts [`template/multi-module/flake.nix`](https://github.com/hercules-ci/flake-parts/blob/024633cd702b10285db5cb19b40ad48d2399ba60/template/multi-module/flake.nix) imports `./hello/flake-module.nix`; that [`feature file`](https://github.com/hercules-ci/flake-parts/blob/024633cd702b10285db5cb19b40ad48d2399ba60/template/multi-module/hello/flake-module.nix) owns both a `perSystem` package and `flake.nixosModules.hello`. **Inference:** coherent cross-output ownership does not require global per-class directories or separate files for every output kind.
- Official [“Dogfood a reusable module”](https://flake.parts/dogfood-a-reusable-module): bind/import source directly, use that binding internally, and export the same binding; do not import a published module obtained through `config`/`self`. **Inference:** explicit producer/consumer seams are substantive; extra `library/features` and `integration/contracts` navigation levels are not a substitute for an acyclic dependency graph. This documentation URL is live, not an immutable source permalink.

The following additional comparative sources were inspected and verified by the parent researcher, not by this worker. Each row records a bounded source-level observation, not an ecosystem-wide norm.

| Source                                                                                                                                                                                   | Observed assembly                                                                                                                                                                                           | Bounded transfer                                                                                                            |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| [nix-community/nixvim, `modules/plugins.nix` at `453dc9c5037e`](https://github.com/nix-community/nixvim/blob/453dc9c5037e/modules/plugins.nix#L7-L21)                                    | `mkByName` uses `readDir` and imports directory entries only under `../plugins/by-name` and `../colorschemes`. A directory `default.nix` follows Nix import convention; it is not Den/import-tree behavior. | Directory-only selection is one possible explicit mechanism; it does not require feature folders with `default.nix`.        |
| [nix-community/stylix, `stylix/autoload.nix` at `3e27b6c499e5`](https://github.com/nix-community/stylix/blob/3e27b6c499e5/stylix/autoload.nix#L12-L26)                                   | Selects exact `../modules/<target>/<platform>.nix` paths behind directory and `pathExists` checks.                                                                                                          | Exact platform filenames can coexist with local helpers/templates; this does not recommend mandatory class-per-file layout. |
| [nix-community/home-manager, `modules/modules.nix` at `c216bf5a1f17`](https://github.com/nix-community/home-manager/blob/c216bf5a1f17/modules/modules.nix#L76-L97)                       | `programs`/`services` accept both bare `.nix` files and directories, allowing small file features and larger directory features. A minimal branch exists.                                                   | Mixed granularity is viable. The branch is not evidence that ordering or bootstrap is correct here.                         |
| [microvm-nix/microvm.nix, `nixos-modules/microvm/default.nix` at `4876e2ae2de6`](https://github.com/microvm-nix/microvm.nix/blob/4876e2ae2de6/nixos-modules/microvm/default.nix#L11-L26) | Uses explicit sibling imports.                                                                                                                                                                              | Local assembly can remain explicit without a tree-wide automatic aggregator.                                                |

Bounded synthesis: private-file safety depends on the actual import mechanic; coherent ownership and mixed small/large granularity are transferable. These frameworks do not mandate a folder plus `default.nix` per feature, class-per-file layouts or new per-feature tests. A domain folder can be navigation-only; it need not become a selectable aggregator/module.

## Hard constraints versus conventions

| Matter               | Technical constraint / approved contract                                                                     | Merely a convention or inference                                      |
| -------------------- | ------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------- |
| Discovery            | Imported leaves must be valid modules at that evaluation layer; helpers must not accidentally enter the list | `modules/`, `features/`, `_private/` spelling                         |
| Private helpers      | Default directory scan excludes relative `/_`; overrides and explicit roots can bypass it                    | A private-looking filename as confidentiality or targeting protection |
| Namespace            | Explicit definitions and namespace export determine public paths                                             | Mirroring public paths in directories                                 |
| Consumer integration | Default adapter inert; global contracts explicit; namespace alone no Quirks                                  | A mandatory `integration/contracts/` hierarchy                        |
| Assembly             | Producer must not depend recursively on its own config-dependent published adapter                           | Reusing one filename/default import for every lifecycle role          |
| Locality             | Feature inputs captured by library; consumer resources explicit through native options                       | A global `inputs/`, `assets/`, or integrations registry               |
| Scope                | Role purity is transitive behavior, not discovery placement                                                  | `host/` or `home/` as enforcement mechanism                           |

Keep an explicit dependency graph: the **producer loads source definitions and exports the namespace/adapter**; the **consumer adapter loads upstream Den, the exported namespace, and only registration it owns**. It must not load the producer forest or tooling, or depend on config/self-derived own exports in a way that recurses. The generator consumes producer input declarations. Folder spelling does not enforce this graph. This is an architectural constraint, not a runtime proof from directory rearrangement.

## Three competing candidates

All candidates retain optional `tooling/`, shared `lib/` (only for truly shared helpers), `templates/`, `docs/recipes/`, and existing `tests/`. Feature-local helpers/assets stay under `_private/` when inside a recursively scanned tree, with the applicable scan exclusion and explicit owner imports. No new registry, DSL, options, mandatory profile tier, generated taxonomy or test suite is proposed. Trees illustrate meaningful files only: no optional empty directories or files are required.

### A. Keep the approved deep library catalog

```text
library/
  default.nix
  integration/
    consumer.nix
    contracts/{persistence,popup-launcher}.nix
  features/
    audio/pipewire.nix
    identity/accounts.nix
    storage/{persistence,btrfs-root-reset}.nix
    session/niri/...
    terminal/{shells,multiplexers,popups}/...
    containers/...
    development/...
    mail/...
    web/firefox/...
  profiles/{host,home}/...
```

**Strength:** unmistakable library boundary; one feature-only discovery root; room for sizable groups.

**Weakness:** `library/features/` repeats catalog intent; small audio/mail/web groups can become one-child navigation layers. `integration/contracts/` hides feature-adjacent ownership behind three generic levels. `terminal/shells/…` may overclassify small files. Upstream does not require any of these levels.

**Improve even if retained:** collapse `integration/consumer.nix` to `library/consumer.nix`; contracts may sit beside it, or declarations may be local to their owning features and explicitly imported by the adapter. Flatten singleton feature groups; keep substantive domains only. This improves A without changing contracts.

### B. Root feature catalog with few workflow/problem-domain groups — provisional preference

```text
features/
  pipewire.nix
  docker.nix
  identity/{accounts,security-key}.nix       # only if breadth/co-change justify
  storage/{persistence,btrfs-root-reset}.nix # only if breadth/co-change justify
  session/{niri,dms,noctalia}/...            # only if breadth/co-change justify
  terminal/
    fish.nix
    tmux.nix
    popups/{records,renderers}.nix           # keep related files together
  mail/...                                   # only if breadth/co-change justify
  firefox/
    firefox.nix
    niri.nix
    _private/...
profiles/{host,home}/...                    # optional; account only if needed
flake/
  default.nix
  consumer.nix
  contracts/...
tooling/                                     # optional
lib/                                         # truly shared helpers only
templates/
tests/
```

This is illustrative: `pipewire.nix` and `docker.nix` need no singleton `audio/` or `containers/` buckets; shells can remain single files under `terminal/`; a `firefox/` directory earns its place when it has meaningful local breadth. Add `identity/`, `storage/`, `session/`, `terminal/` or `mail/` only where actual breadth or co-change supports grouping. `profiles/{host,home}/` is optional; add an account profile only if genuinely needed, not for symmetry. Keep feature-local helpers/assets in `_private/` when the actual discovery mechanic excludes it, and import them explicitly from their owner.

**Strength:** removes generic navigation levels before most features while preserving substantive domains and complex feature locality. `features/` remains the maintainer catalog; public selections stay independent, such as `dotnix.host/home/account.*`. `flake/` names producer/export/consumer assembly responsibility, unlike `library/` containing no feature definitions.

**Weakness:** mixed single-file and directory granularity needs clear ownership. Domain groups should follow real breadth and edit workflows, not a fixed file-count threshold. `flake/` is one clear illustrative name, not a technical requirement.

**Grouping judgment:** keep popup records and renderers near each other rather than splitting through unrelated `shells/` and `multiplexers/` trees. Put truly shared contracts in `flake/contracts/`; feature-owned declarations may remain local and be explicitly registered by the adapter. Do not create both arrangements for one declaration or import activation behavior to register a contract.

### C. One discovery-root `modules/` tree, explicit exports and exclusions

```text
modules/
  features/
    pipewire.nix
    firefox/
      firefox.nix
      niri.nix
      _private/...
    storage/...
  profiles/...
  _integration/
    consumer.nix
    contracts/...
  _exports.nix
tooling/...
lib/...
```

**Strength:** familiar from actual users; one scanner root, strong helper locality; explicit imports can keep integration/export files out of blanket discovery. Alternatively scan only `modules/features` plus explicitly selected profile modules and keep integration outside `modules`.

**Weakness:** scanning all `modules/` increases coupling to exclusion rules and increases the risk that a registration-only namespace import also receives producer/tooling code. Hidden entry points are less discoverable for humans. Scanning `modules/features` reintroduces a generic layer with little advantage over B. Explicit exports must not grow into a second feature registry.

**Best use:** when most files genuinely belong to one evaluation layer and explicit export assembly stays tiny. Not preferred here: personal repository convenience does not outweigh a reusable library's producer/consumer boundary.

## Provisional recommendation, not a new target

Choose **B's shallower catalog principle with `flake/{default.nix,consumer.nix,contracts/}` as a small explicit assembly boundary**. `flake/` names actual producer/export/consumer responsibility, unlike `library/` containing no feature definitions. This is one illustrative name, not a technical requirement. Keep approved ownership/behavior boundaries; remove generic layers that do not carry them. Specific advisory decisions:

- Keep `features/` at root; do not add `modules/features/` or always use `library/features/`. Use substantive domains only where real breadth or co-change supports grouping; `pipewire.nix` and `docker.nix` need no singleton audio/container buckets. No universal flat-layout claim follows.
- Keep `flake/consumer.nix` and optional shared `flake/contracts/` together; feature-owned declarations can stay local and be explicitly registered by the adapter. Keep Quirk registration separate from namespace-only exposure.
- A complex feature such as Firefox may have a local directory for meaningful sibling implementations/helpers/assets; tiny features stay single files. Keep terminal shells as individual files, popup records/renderers near each other, and do not split classes into files for symmetry.
- Keep library input declarations next to their feature entry module. Keep helpers, package expressions and Nix data in `_private/` under discovered trees only when the actual scan excludes them; explicitly import them from the owner. Ordinary assets may live there too. Reserve top-level `lib/` for genuinely shared helpers.
- Module-shaped optional integration definitions can be discovered safely as definitions **only if registration remains inert**. `firefox/niri.nix` may declare a separately selectable aspect; it must not silently mutate a selected global Niri aspect or activate its backend. Directory naming proves neither property.
- Public namespace remains independent of physical paths; this is not a compatibility-cost argument. Source reorganization must preserve explicit host/account/home choices, persistence and root reset, rootful/rootless containers, authoritative popup data and native-enabled applications, consumer resources and compatible multi-user desktop selections.

No implementation POC or production edit is needed to choose between these directory candidates. Later behavior work should use existing consumer seams only where a concrete risk warrants verification; directory moves do not mandate snapshots, one test per file, build matrices or a generation lifecycle run for this research.

## Limits and open decisions

- Source inspection demonstrates patterns and import mechanics, not effective evaluation/build/runtime correctness or this library's inertness/role purity. Native nested catalog feasibility remains the bounded evidence in the existing target/spec, not a result newly reproduced here.
- Gwenodai's current public snapshot is older than the requested research date; Adda's is recent. Vic's README linkage lagged its move to Ren. Those facts limit claims about current community consensus; no popularity ranking or universal ecosystem convention is inferred.
- Quasigod's GitHub guess returned 404; the Den README points to Tangled instead. No uninspected Quasigod structure is asserted. Dendrix was not needed to establish the mechanics and two actual Den users; this note makes no claim about its current export architecture.
- Exact boundaries among terminal/popups, session and individual apps should follow the complete capability inventory and real co-change workflows. Existing 147-file/six-group baseline argues against both a totally flat catalog and mandatory directory-per-feature, but does not determine a uniquely correct taxonomy.
- Whether persistence declaration files are primarily storage-local or shared contract files depends on their actual registration dependencies. Avoid importing activation modules to register contracts; avoid duplicate schema ownership. This remains a design detail, not permission to introduce another abstraction.
- A later approved design can adopt selected simplifications. This note neither supersedes the canonical spec/target nor authorizes changing source, pins, generation, public selections or existing records.
