# Can herdr-auto-title be installed/configured declaratively in Nix?

Research date: 2026-11-13.
Sources read in full: herdr **v0.9.5** (shallow clone, commit `2ecf19a92fc3a7fff75b6ce3655ef04f4625ec01`) and herdr-auto-title **main** (commit `36382125353207e109df32f326f6b17731bf06df`; latest release tag **v0.22.2** = commit `9633ddf4d9a0da03f80b54ff0dd4dd87c15e49b8`, matches the version in the cloned tree's `herdr-plugin.toml`).

Citations use `<repo>:<file>:<line>`; herdr = github.com/herdrdev/herdr at v0.9.5, auto-title = github.com/kryptamine/herdr-auto-title at the commits above.

## Recommendation (short version)

**Yes — declaratively, without `herdr plugin install`.** herdr has a first-class local-path mechanism, `herdr plugin link <path>` (herdr:`src/cli/plugin.rs:51-90`, help text at `:1814`), which registers an arbitrary directory — including a read-only `/nix/store` path — in its plugin registry. herdr-auto-title needs exactly **one** thing from the plugin context: the `HERDR_SOCKET_PATH` env var (auto-title:`internal/herdr/client.go:15,64-71`); all renames go through the herdr socket API, so running the binary from a store path works unchanged.

**Recommended wiring: package herdr-auto-title with `pkgs.buildGoModule` and register it at Home-Manager activation via `herdr plugin link`.** This is exactly the pattern the third-party kevinpita/herdr-nix Home-Manager module already uses in production ("The module runs `herdr plugin link` in an isolated build home. It does not run manifest build commands", kevinpita/herdr-nix `docs/modules.md`, Plugins section). It keeps the full plugin lifecycle (startup at every server bootstrap, the `restart` action, future named sessions) with zero imperative state.

Fallback (simpler runtime, more caveats): a systemd user service running the same package with `HERDR_SOCKET_PATH` set — see option (a).

---

## 1. herdr plugin loading mechanism (herdr v0.9.5 source)

### plugins.json schema

`~/.config/herdr/plugins.json` is a JSON array of `InstalledPluginInfo` (herdr:`src/persist/plugin_registry.rs:7-9` — `registry_path()` = `config_dir().join("plugins.json")`; parse at `:126-131` — `serde_json::from_str::<Vec<InstalledPluginInfo>>`). Schema (herdr:`src/api/schema/plugins.rs:47-70`):

```rust
pub struct InstalledPluginInfo {
    pub plugin_id: String,        // e.g. "herdr.auto-title"
    pub name: String,
    pub version: String,
    pub min_herdr_version: String,
    pub description: Option<String>,
    pub manifest_path: String,   // <plugin_root>/herdr-plugin.toml
    pub plugin_root: String,     // arbitrary path
    pub enabled: bool,
    pub platforms: Option<Vec<PluginPlatform>>,
    pub build: Vec<PluginManifestBuild>,
    pub startup: Vec<PluginManifestStartup>,
    pub actions: Vec<PluginManifestAction>,
    pub events: Vec<PluginManifestEventHook>,
    pub panes: Vec<PluginManifestPane>,
    pub link_handlers: Vec<PluginManifestLinkHandler>,
    pub source: PluginSourceInfo, // kind: "local" (default) | "github"
    pub warnings: Vec<String>,
}
```

`PluginSourceKind` defaults to `Local` (herdr:`src/api/schema/plugins.rs:118-140`) — a github source is _not_ required. A `.plugins.lock` file (`config_dir/.plugins.lock`, herdr:`src/persist/plugin_registry.rs:11-13,15-30`) is only an advisory flock serializing registry mutations.

### The plugin manifest

A plugin is a directory containing `herdr-plugin.toml` (also the upstream docs' definition, herdr.dev/tui/docs/plugins/). Fields (herdr:`src/app/api/plugins/manifest.rs:7-25`): `id`, `name`, `version`, optional `min_herdr_version`/`description`/`platforms`, and arrays `[[build]]`, `[[startup]]`, `[[actions]]`, `[[events]]`, `[[panes]]`, `[[link_handlers]]` — each with a `command = [...]` argv list and optional per-platform filters. The "build/startup/action" lines from the install output are exactly these arrays. Example: auto-title's manifest (auto-title:`herdr-plugin.toml`) declares `[[build]] command = ["sh", "scripts/install.sh"]`, `[[startup]] command = ["./herdr-auto-title"]`, and a `restart` action.

### How herdr executes plugin commands

At server bootstrap, `run_plugin_startup_hooks()` runs every enabled plugin's `startup` commands (herdr:`src/server/headless/bootstrap.rs:93,206`). Execution (herdr:`src/app/api/plugins/runtime.rs:34-141`):

- **cwd = `plugin_root`** (`command_for_argv_in_dir(&program, &args, &plugin_root)`, runtime.rs:139-141; herdr:`src/plugin_command.rs:8-11`). Relative programs like `./herdr-auto-title` resolve against that cwd (herdr:`src/plugin_command.rs:14-28`).
- **Env injected** (runtime.rs:39-77): `HERDR_SOCKET_PATH` (herdr:`src/api/mod.rs:20` defines the var), `HERDR_ENV=1`, `HERDR_PLUGIN_ID`, `HERDR_PLUGIN_CONTEXT_JSON`, `HERDR_BIN_PATH`, plus per-context `HERDR_WORKSPACE_ID`/`HERDR_TAB_ID`/`HERDR_PANE_ID`, and `HERDR_PLUGIN_ROOT`/`HERDR_PLUGIN_CONFIG_DIR`/`HERDR_PLUGIN_STATE_DIR` (herdr:`src/app/api/plugins/env.rs:20-35`). Plugin config dir: `~/.config/herdr/plugins/config/<id>`; plugin state dir: `$XDG_STATE_HOME/herdr/plugins/<id>` (herdr:`src/plugin_paths.rs:48-59`).
- stdout/stderr are captured (64 KiB cap) into a plugin command log (runtime.rs:8,41).

### Arbitrary directories: YES

`herdr plugin link <path> [--disabled]` (herdr:`src/cli/plugin.rs:51-90`) takes any local directory; the handler only loads the manifest and inserts the entry into the registry (herdr:`src/app/api/plugins/mod.rs:68-87`) — **no build execution, no checkout, no github layout**. The manifest path is canonicalized and `plugin_root` becomes the resolved directory (herdr:`src/app/api/plugins/manifest.rs:106-119`; on Linux `plugin_runtime_path` is the identity, herdr:`src/platform/mod.rs:204-220`). It works both against a running server (API method `PluginLink`) and offline — when no server is reachable, the CLI writes the registry directly (`offline_plugin_link_response`, herdr:`src/cli/plugin.rs:1289-1294`). By contrast, `herdr plugin install` only takes GitHub refs and runs the manifest's `[[build]]` step in a fresh clone under `~/.config/herdr/plugins/github-installations/<id>-<pid>-<n>/` (herdr:`src/plugin_paths.rs:26-45`; generations created with pid-suffixed names, `create_managed_installation`).

In contrast to `install`, **`link` never runs build commands** — confirmed by herdr source (link handler = manifest load + registry insert only) and by kevinpita/herdr-nix's module docs ("It does not run manifest build commands, fetch unpinned sources at activation, or execute plugins during registration", kevinpita/herdr-nix `docs/modules.md`).

### Does herdr write into the plugin dir? NO (for linked plugins)

The only thing herdr ever creates inside a plugin installation is a `.in-use` lease file — and only for installations under `github-installations`: `lease_path()` returns `None` unless the path is under `managed_plugins_dir()/github-installations` (herdr:`src/plugin_installations.rs:19-27`; `command_lease` at `:29-32` then acquires nothing). Installation cleanup/reclaim also operates exclusively on `github-installations` (herdr:`src/plugin_installations.rs:80-105,200+`). A linked plugin rooted at a read-only `/nix/store` path is therefore safe: herdr reads the manifest, spawns the startup command with cwd there, and writes all plugin state to `~/.config/herdr/plugins/config/<id>` and `$XDG_STATE_HOME/herdr/plugins/<id>` — never into `plugin_root`.

Registry writes are symlink-aware: `resolve_write_target` follows up to 40 symlinks before atomic-replacing (herdr:`src/persist/plugin_registry.rs:23-44`) — i.e. if `plugins.json` were a symlink into the store, a registry mutation would fail loudly on the read-only target rather than corrupt anything. (We don't rely on this; see option (b).)

### Declarative config.toml registration? NO (upstream open request)

`config.toml` has no plugin section (grep over herdr:`src/config.rs` finds no plugin keys; the section list is theme/terminal/update/keys/server/worktrees/ui/session/remote/experimental/advanced). Upstream feature request for declarative plugin installation via config exists as an open discussion: herdrdev/herdr discussion **#762** "[idea] Allow for plugin installation via config.toml". The sanctioned declarative hook is `plugin link`.

---

## 2. herdr-auto-title standalone feasibility (its Go source)

### How the binary talks to herdr

NDJSON over the unix socket named by **`HERDR_SOCKET_PATH`** — one fresh connection per call, no subscription (auto-title:`internal/herdr/client.go:14-33,75-110`; protocol methods at `internal/herdr/protocol.go:67-71`: `session.snapshot`, `tab.rename`, `pane.rename`, `workspace.report_metadata`). There is **no stdin protocol and no other plugin-channel**: grep for `HERDR_PLUGIN` across the entire auto-title repo returns **zero** matches — the plugin context's only consumed input is `HERDR_SOCKET_PATH`:

> `"%s is not set: Auto Title must be started by Herdr"` (auto-title:`internal/herdr/client.go:64-71`)

Everything the plugin does — tab renames (`RenameTab`), pane labels (`RenamePane`, auto-title:`internal/herdr/client.go:35-41`), workspace topic/sidebar tokens (`ReportWorkspaceTopic`, `:43-52`) — is performed through that socket. **None of it requires plugin registration**; registration only buys lifecycle (auto-start at server bootstrap, the `restart` action).

### Plain process / systemd service against a running TUI server

Works, provided `HERDR_SOCKET_PATH` is set to the TUI server's socket. That path is deterministic: the default session's API socket is `<config_dir>/herdr.sock` = `$HOME/.config/herdr/herdr.sock` (herdr:`src/session.rs:171-173` `api_socket_path_for` = `data_dir.join("herdr.sock")`; `data_dir_for(None)` = config_dir, herdr:`src/session.rs:163-169`; config_dir = `$XDG_CONFIG_HOME/herdr` or `$HOME/.config/herdr`, herdr:`src/config/io.rs:30-34,58-62`). Named sessions get `$HOME/.config/herdr/sessions/<name>/herdr.sock` (herdr:`src/session.rs:163-169`).

The poll loop tolerates herdr being down: "No failure is fatal — Herdr's socket can lag the process it just launched" (auto-title:`internal/app/app.go:205-233`); a missing socket reads as server identity `""` and the loop keeps polling (auto-title:`internal/app/app.go:236-258`). One **critical lifecycle detail**: when the herdr server restarts, the socket file's device:inode changes and the running instance exits _cleanly_ ("another server holds the socket and starts an auto title of its own", auto-title:`internal/app/app.go:236-258`; identity via `stat` dev:ino, auto-title:`internal/herdr/server_unix.go` `serverIdentity`). A standalone service therefore needs `Restart=always` (not `on-failure`) to come back after every herdr server restart. Single-instance safety is handled by a claim file keyed by socket path in `~/.config/herdr-auto-title/` (auto-title:`internal/app/serve.go:44-47`, `internal/app/paths.go:44-52`), so a restarted service cleanly displaces a stale instance.

### What `desktop install` creates on Linux — and why it is NOT for the TUI

`desktop install` renders this unit (auto-title:`internal/autostart/templates/systemd.service`, quoting verbatim):

```ini
[Unit]
Description=Herdr Auto Title for the Herdr desktop app

[Service]
ExecStart={{quote .Binary}} desktop
# A clean exit is a newer instance claiming the session: not restarted.
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

But `desktop` mode is a **different client for the herdr DESKTOP app (herdr-core)**: it dials `$XDG_RUNTIME_DIR/herdr-core/default.sock` (auto-title:`internal/desktop/socket_unix.go:17-37` `coreSocketPath`, comment: "follows the rules in herdr-core's docs/security.md for its default session") and finds sessions by scanning the process table with `ps`/`lsof` (auto-title:`internal/desktop/sessions_unix.go:14-40`). It never touches the TUI socket. So the README's systemd path is irrelevant for our TUI setup; a TUI-targeting service must run the **plugin-mode binary** (no args) with `HERDR_SOCKET_PATH` pointing at `<config_dir>/herdr.sock`.

### Service-mode feature gaps vs plugin mode

Functionally none for the TUI use case: renames, pane labels, and workspace topics are all socket calls (above). Gaps are lifecycle only:

- No `restart` action registered (replace with `systemctl --user restart herdr-auto-title`).
- Covers only the session whose socket you configure (default session); plugin mode starts one instance per server, so named sessions would each get their own auto-title for free.
- Env passthrough the herdr server gives plugin processes (e.g. `CLAUDE_CONFIG_DIR`, `CODEX_HOME`, `GROK_CONFIG_DIR`, auto-title:`internal/app/config.go:32-40`) is absent in a bare service; auto-title falls back to its built-in default dirs, which is what we want anyway.

---

## 3. Declarative wiring options, ranked

### (b) RECOMMENDED — buildGoModule package + `herdr plugin link` at activation

**Wiring:**

1. Package (callPackage-compatible, e.g. `modules/agent/<kind>/pkgs/` or `pkgs/` — auto-exposed via `packagesFromDirectoryRecursive`):

```nix
# herdr-auto-title/default.nix
{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "herdr-auto-title";
  version = "0.22.2";
  src = fetchFromGitHub {
    owner = "kryptamine";
    repo = "herdr-auto-title";
    rev = "v${finalAttrs.version}"; # tag v0.22.2 -> commit 9633ddf4d9a0da03f80b54ff0dd4dd87c15e49b8
    hash = ""; # ponytail: fill from build error, never invent
  };
  vendorHash = ""; # ponytail: fill from build error, never invent
  # upstream release binaries are CGO_ENABLED=0 (docs/architecture/installation.md);
  # all deps incl. modernc.org/sqlite are pure Go, so add CGO_ENABLED = 0; to be safe.
  postInstall = ''
    install -Dm755 $out/bin/herdr-auto-title $out/herdr-auto-title
    install -m644 herdr-plugin.toml $out/herdr-plugin.toml
  '';
  # $out itself is the plugin root: manifest startup command is ["./herdr-auto-title"]
  # with cwd = plugin_root (herdr src/app/api/plugins/runtime.rs:139-141), so the binary
  # must sit next to herdr-plugin.toml at $out root.
  meta = {
    description = "Automatic contextual tab titles for herdr";
    homepage = "https://github.com/kryptamine/herdr-auto-title";
    license = lib.licenses.mit; # auto-title LICENSE (verify at packaging time)
    mainProgram = "herdr-auto-title";
  };
})
```

2. Register at Home-Manager activation (aspects `features/herdr.nix`):

```nix
home.activation.herdrAutoTitlePlugin =
  lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${lib.getExe pkgs.herdr} plugin link ${herdr-auto-title-pkg}
    # startup hooks run only at server bootstrap (herdr src/server/headless/bootstrap.rs:93);
    # the restart action starts an instance immediately when a server is up:
    $DRY_CMD ${lib.getExe pkgs.herdr} plugin action invoke herdr.auto-title.restart || true
  '';
```

3. Optional declarative config: `home.file.".config/herdr-auto-title/config.env"` (auto-title reads `config.env` from `~/.config/herdr-auto-title/`, auto-title:`internal/app/paths.go:23-40,65-84`). Manage only this file — `manual-names.json` in the same dir is binary-owned runtime state.

**Why it holds:** `plugin link` accepts arbitrary local dirs (§1); herdr writes nothing into the plugin dir for linked plugins (§1); link never runs the `[[build]]` step (§1), so the network-downloading `scripts/install.sh` is inert — the binary comes from Nix. The registry entry is written by herdr itself, so no internal-schema coupling on our side. This is the same pattern kevinpita/herdr-nix ships ("The module runs `herdr plugin link` in an isolated build home", kevinpita/herdr-nix `docs/modules.md`).

**Fragilities:**

- `plugins.json` becomes mixed-ownership state: `plugin link` merges into the existing registry (herdr:`src/persist/plugin_registry.rs:74-88` — load, mutate, save), so imperative installs coexist; if the user imperatively unlinks our plugin, the next activation re-links it (self-healing, desired).
- Startup runs only at server bootstrap (herdr:`src/server/headless/bootstrap.rs:93,206`); after activation, either restart the herdr server or invoke the `restart` action (kevinpita docs state the same: "Restart the affected server after changing startup hooks").
- Store path changes on every rebuild → activation updates `plugins.json`; a previously started plugin process keeps running the old binary until the restart action or server restart.
- `min_herdr_version = "0.8.2"` (auto-title `herdr-plugin.toml`) is enforced by herdr at manifest load (herdr:`src/app/api/plugins/manifest.rs:127`); fine for 0.9.5, revisit on herdr downgrades.
- Activation depends on `pkgs.herdr` being on PATH-able location at activation time (it is — provided by llm-agents/nixpkgs).

### (a) VIABLE FALLBACK — package + systemd user service, no plugin registration

```nix
systemd.user.services.herdr-auto-title = {
  Unit.Description = "herdr-auto-title (TUI session)";
  Service = {
    ExecStart = "${herdr-auto-title-pkg}/herdr-auto-title";
    Environment = "HERDR_SOCKET_PATH=%h/.config/herdr/herdr.sock";
    # instance exits CLEANLY when the herdr server restarts (socket dev:ino changes,
    # auto-title internal/app/app.go:236-258) -> Restart=always, not on-failure:
    Restart = "always";
    RestartSec = 5;
  };
  Install.WantedBy = [ "default.target" ];
};
```

Works because the binary only needs `HERDR_SOCKET_PATH` (§2) and the poll loop survives herdr being down (§2). **Do NOT copy `desktop install`'s unit** — its `ExecStart … desktop` targets the herdr-core desktop socket, not the TUI (§2).

**Fragilities:** default session only (named sessions need one service per socket path); clean exit on every herdr server restart requires `Restart=always`; no `restart` action (use systemctl); agent-dir env passthrough absent (defaults apply — acceptable); service polls forever while no herdr runs (measured cost ~1/1000 core, auto-title `docs/architecture/poll-loop.md`).

### (c) herdr-native declarative plugin support — NOT AVAILABLE

No `config.toml` plugins section in 0.9.5 (§1); open upstream request only (herdrdev/herdr discussion #762). `plugin link` (option b) is the closest sanctioned mechanism; an HM module could also generate `plugins.json` wholesale via `home.file` (schema in §1 is fully serializable), but that couples us to the internal `InstalledPluginInfo` serde format and clobbers imperative installs — strictly worse than letting herdr write the registry via `link`.

---

## 4. Existing packaging

**herdr-auto-title is not packaged anywhere found**: not in nixpkgs (searched NixOS package search / MyNixOS; only `herdr` itself exists), not in NUR (no hits), not in any flake. The two community herdr flakes package herdr only:

- AodhanHayter/herdr-nix — archived ("upstream herdr now provides an official Nix Flake"), herdr CLI binary only, no auto-title.
- kevinpita/herdr-nix — packages herdr/herdr-core/herdr-tui + a Home-Manager module whose `programs.herdr.plugins` option implements exactly the option-(b) pattern via `herdr plugin link` (see §3b). No auto-title package, but its module is prior art worth reading before implementing our activation snippet.

---

## Deciding facts (summary)

1. `herdr plugin link <path>` registers an arbitrary local directory — read-only store paths included — and never runs build commands or writes into the plugin dir (herdr `src/cli/plugin.rs:51-90`, `src/app/api/plugins/mod.rs:68-87`, `src/plugin_installations.rs:19-32`).
2. herdr-auto-title consumes exactly one thing from the plugin context: `HERDR_SOCKET_PATH` (auto-title `internal/herdr/client.go:64-71`); all tab/pane/workspace renames are socket API calls, so a store-rooted binary behaves identically to the installed plugin.
3. The README's systemd path (`desktop install`) targets the herdr **desktop app** (herdr-core socket, `internal/desktop/socket_unix.go:17-37`), not the TUI — a standalone TUI service must run plugin mode with `HERDR_SOCKET_PATH=$HOME/.config/herdr/herdr.sock` and `Restart=always` (clean exit on server restart, `internal/app/app.go:236-258`).
