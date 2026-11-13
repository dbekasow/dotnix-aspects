# Research: existing herdr plugins for the prefix+o tool menu

Date: 2026-11-13 · Scope: herdr 0.9.5 stable, marketplace + GitHub topic `herdr-plugin`

## Short answer

**No existing plugin does what we need.** The marketplace (2,100 plugins across
2,016 repos, snapshot `https://assets.herdr.dev/plugins/index.json`, generated
2026-11-13) has several _menu/launcher_ plugins and several _popup_ plugins, but
none combines: single-keypress menu → per-tool popup with per-tool width/height.
The two closest are `cdragon.command-center` (single-key menu, but no popup
launch type) and `cloudmanic/herdr-plus` (fuzzy launcher, but geometry is one
global placement setting, not per-tool). A tiny own plugin — one `[[panes]]`
entrypoint per tool, each with its own `placement = "popup"` + `width`/`height`,
plus a small menu script calling `herdr plugin pane open --entrypoint <tool>` —
is the pattern every comparable plugin already uses (ssh-manager, pretty-which),
and is less machinery than bending command-center to our purpose.

## Sources checked

- Marketplace doc (v0.9.5): `https://raw.githubusercontent.com/herdrdev/herdr/v0.9.5/docs/next/website/src/content/docs/marketplace.mdx`
- Marketplace index (the JSON behind herdr.dev/plugins): `https://assets.herdr.dev/plugins/index.json` — 2,016 repos, keyword-scanned for menu/launcher/popup/picker/which-key (326 hits, all triaged)
- Plugin capability doc (v0.9.5): `https://raw.githubusercontent.com/herdrdev/herdr/v0.9.5/docs/next/website/src/content/docs/plugins.mdx`
- Official examples: `github.com/ogulcancelik/herdr-plugin-examples` — 4 plugins (telegram-notify, dev-layout-bootstrap, github-link-preview, rust-release-check), **none** are menus/launchers
- Per-plugin `herdr-plugin.toml` manifests fetched raw from each candidate repo (paths cited per finding)

## Per-plugin findings

### speardragon/herdr-command-center — closest match for (a)

- id `cdragon.command-center`, ★20, `min_herdr_version = "0.7.5"`, Node.js 22+.
- Popup menu bound to one key; commands get slot keys `1`–`9`, `0`, `a`–`z`; **one
  keypress runs the command** — exactly our single-key dispatch.
- Manifest (`herdr-plugin.toml`): one `[[panes]]` entrypoint `palette`,
  `placement = "popup"`, `width = "90%"`, `height = "70%"`.
- **Gap:** command `type` is only `shell`, `pane`, or `plugin_action`
  (README "The config file" / "Where the output goes"). No popup-with-geometry
  type. `pane` types into the focused pane; `shell` runs detached. Lazygit via
  `pane` would take over the tiled pane, not open a popup.
- Workaround it suggests itself (README "Anything herdr can do"): a `shell`
  entry `herdr plugin pane open --plugin X --entrypoint Y --placement popup` —
  i.e. it would still need our own plugin with per-tool entrypoints to get
  geometry. Config lives in the plugin's config dir, edited via its own TUI —
  not declaratively from Nix.
- Reuse verdict: wrong fit. Menu UX matches, launch semantics don't, and the
  declarative-from-flake requirement fails.

### CowboyVang/herdr-which-key — which-key overlay, dispatches _bindings_

- id `cowboyvang.which-key`, ★6, `min_herdr_version = "0.7.5"`, Python 3.
- "Press a key, see every binding under your prefix grouped and labelled, press
  a second key to run it." Manifest: `[[panes]]` popup 78%×62%.
- Dispatches _existing herdr keybindings and plugin actions_, not arbitrary
  tools. To use it for our menu we would have to bind each tool as its own
  `prefix+<key>` popup binding first — which is exactly the drawer of bindings
  we want to replace, and per-tool geometry would then live in `[[keys.command]]`
  entries, not in one menu.
- Reuse verdict: solves keymap discovery, not tool launching.

### ramarivera/herdr-pretty-which — which-key + launcher + shell

- id `ramarivera.pretty-which`, ★6, `min_herdr_version = "0.7.4"`, Rust/ratatui.
- Manifest: three popup entrypoints (`overlay` 90%×80%, `launcher` 90%×80%,
  `shell` 90%×12); actions call
  `herdr plugin pane open --plugin ramarivera.pretty-which --entrypoint launcher --focus`.
- Launcher is fuzzy-search, not single-key dispatch; no per-entry tool geometry
  (one launcher pane, one size).
- Reuse verdict: no, but its manifest is a clean reference for the
  action→`plugin pane open` handoff pattern.

### cloudmanic/herdr-plus — fuzzy launcher, global placement

- id `cloudmanic.herdr-plus`, ★381, `min_herdr_version = "0.7.0"`, Go.
- Quick Actions: fuzzy launcher for one-off commands (command/select/form types),
  run in the directory you launched from. Picker pane `placement = "overlay"`
  (manifest `herdr-plugin.toml`); user config allows switching the _global_
  placement per feature (`[quick_actions] placement = "overlay|popup|split|tab|zoomed"`).
- **No per-tool geometry** — one placement string for the whole picker, and the
  picked command does not open a popup at all (it runs in the launch context).
- Reuse verdict: no. Fuzzy, not single-key; no popup geometry handoff.

### jorge07RD/herdr-ssh-manager — menu → popup handoff, fixed geometry

- id `herdr-ssh-manager`, ★5, `min_herdr_version = "0.8.0"`.
- Manifest: two popup entrypoints (`picker` 70%×20, `add` 70%×18); the picker
  action opens via `herdr plugin pane open --plugin herdr-ssh-manager
--entrypoint picker --placement popup`. "Enter hands the popup straight to
  ssh" — a menu→terminal handoff, but the result runs in the _same_ popup pane
  and geometry is per-_screen_, declared once in the manifest.
- Reuse verdict: no (SSH-specific), but the closest architectural sibling to
  our design: manifest-declared popup entrypoints + picker.

### maro114510/herdr-toggle-popup — generic popup shell, fixed size

- id `maro114510.toggle-popup`, ★9, `min_herdr_version = "0.9.3"` (newest of all
  candidates — tracks current API).
- One keybinding toggles a full-screen (`100%`×`100%`) popup shell; persistent
  session, key closes it. Fixed geometry, fixed command (`$SHELL`).
- Reuse verdict: no — answers "toggle one popup shell", not "menu of tools with
  per-tool sizes". Adjacent only.

### Tyru5/herdr-floax — adjacent

- Toggleable floating scratch shell, "sized popup", one per workspace (tmux-floax
  style). Same single-popup-shape category as toggle-popup. Not a launcher.

### Others triaged (adjacent, not matches)

- `enekos/herdr-quick-actions` (fzf picker over herdr's _native_ actions),
  `vjeantet/herdr-palette`, `ramarivera/herdr-palette`,
  `cesarferreira/herdr-palette`, `JanTvrdik/herdr-command-palette`,
  `javoscript/herdr-pickr`, `lurepos/herdr-commander`,
  `arjenblokzijl/herdr-launcher` — all fuzzy/palette launchers; none offer
  single-key dispatch with per-entry popup geometry.
- `speardragon/herdr-plugin-manager`, `vika2603/plugin-manager` — popup plugin
  browsers, not tool launchers.

## Capability facts confirmed along the way (v0.9.5 docs)

- `[[panes]]` manifest entrypoints accept `placement = "popup"` with optional
  `width`/`height` (cells or `"80%"`-style percentages) — per entrypoint
  (plugins.mdx, "Manifest pane placement…"). This is the declarative home for
  per-tool geometry.
- `plugin.pane.open` (socket request) can _override_ placement and accepts
  width/height in the open request (plugins.mdx). The CLI
  `herdr plugin pane open --plugin X --entrypoint Y [--placement …]` is shown
  in docs without width/height flags — geometry should live in the manifest.
- `[[keys.command]] type = "popup"` supports per-binding `width`/`height`
  (herdr.dev/tui/docs/configuration/) — relevant fallback: direct per-tool
  bindings, no menu, if the menu is ever dropped.

## Conclusion for our design

**Write our own — small.** No plugin sells the menu→per-tool-popup handoff, and
the two reusable menus (command-center, herdr-plus) both fail on geometry or
dispatch style, plus neither is declaratively configurable from a Nix flake
(command-center edits TOML via its own TUI; herdr-plus reads its config dir).

The ecosystem-standard shape, which we should copy:

1. One plugin, `herdr-plugin.toml` with a `[[panes]]` entrypoint **per tool** —
   `id = "lazygit"`, `placement = "popup"`, its own `width`/`height`,
   `command = ["lazygit"]` — geometry declarative and per-tool by construction.
2. One small menu entrypoint (popup, menu-sized, e.g. 40%×12): a shell/Python
   script that renders the tool list, reads one keypress, closes itself, and
   runs `herdr plugin pane open --plugin <ours> --entrypoint <tool> --focus`.
3. `prefix+o` binds to the menu action (`type = "plugin_action"`).

The popup-close-before-launch ordering command-center documents (herdr refuses
UI work with `ui_busy` while a popup owns the screen) is a real constraint our
menu script must reproduce: dispatch after the menu popup exits, not from
inside it.

## Verification addendum (checked against the installed 0.9.5 binary)

- `herdr plugin pane open --help` on 0.9.5 stable: `--placement` accepts only
  `overlay | split | tab | zoomed` — **no `popup`**, and no `--width`/`--height`
  flags. The CLI cannot open plugin popups on stable; the v0.9.5 docs describe
  `plugin.pane.open` with `placement = "popup"` + `width`/`height` for the
  **raw socket method only**. A geometry-preserving handoff on 0.9.5 therefore
  needs a raw-socket client (python/socat) inside the menu script plus the
  detached-child dispatch described above; the CLI alone is insufficient.
- The `ui_busy` constraint is sourced from command-center's README, not
  verified against 0.9.5 directly. Treat as plausible (popups are
  session-modal) but unconfirmed.
