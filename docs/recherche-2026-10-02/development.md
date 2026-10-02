# Research 6/10 — Aspekt `development` (Editoren, VCS, KI)

Repo: `/home/denis/repositories/private/.dotnix-aspects` · Branch: `refactor/public-release`
Scope: `modules/aspects/development/**` — tatsächlich **30 Dateien, 851 LOC** (nicht 24; editors 2, helix-lsp 9, vcs 8, ai 4, automation 4, devops 3). Uncommitted `sesh.nix` (term) unberührt. Keine nix-Kommandos ausgeführt.

## Summary

Der development-Aspekt ist überwiegend flach und ordentlich gebaut: 30 kleine Module (ø 28 LOC), konsequente `lib.*`-Nutzung, keine `builtins.*`-Vergehen, sauberes Merge-Verhalten über das Modulsystem (9 helix-lsp-Dateien mergen still in ein Modul, per `flake.factory.helix` geteilte Helfer). Die KI-Schiene ist **runtime-unkritisch**: keine persistenten Dienste, nur Overlays, Binary-Caches und on-demand-tmux-Popups.

Die Probleme sitzen an drei Stellen: (1) Der **Helix-Eigen-Input** kostet Cache-Trefferrate und Rebuild-Zeit und ist im Lock 2 Monate alt — der eigentliche Zweck („master") läuft ins Leere. (2) **Doppelte LSP-Server pro Buffer** (nixd+nil, marksman+markdown-oxide) + 16 ungepinnte extraPackages befeuern das Editor-Trägheitsgefühl. (3) **Struktur-Lüge**: die Verzeichnisgrenze `development/` deckt sich nicht mit der Aktivierungs-Realität — git-Familie und alle AI-Module hängen an `core`/`terminal`, nicht an `development`.

## Findings

### HIGH — Helix-Eigen-Input: „master"-Lock 2 Monate alt, Cache-Treffer durch `follows` kaputt

**Dateien:** `flake.nix:36-37`, `flake.lock` (helix), `editors/helix.nix:1-6`, `modules/aspects/development.nix:4-5`

**Beleg:**
```nix
# flake.nix:36-37
helix.inputs.nixpkgs.follows = "nixpkgs";
helix.url = "github:helix-editor/helix";
```
```nix
# editors/helix.nix:3-6
nixpkgs.overlays = [ inputs.helix.overlays.default ];
nix.settings = {
  substituters = [ "https://helix.cachix.org" ];
  trusted-public-keys = [ "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs=" ];
};
```
```nix
# development.nix:4-5  — Motivation explizit: Master statt nixpkgs-Release
# Editor (master)
helix
```
Lock-Daten (flake.lock, ausgelesen per json): helix `rev 079a789e8cb0`, **lastModified 2026-07-23** — nixpkgs-unstable dagegen **2026-09-27**. Der „master"-Stand ist also 2 Monate alt; nixpkgs-unstable trägt Helix-Updates täglich.

**Kosten, präzise:**
- **Zweite Helix im Store: NEIN.** Das Overlay *ersetzt* `pkgs.helix` systemweit; `core/system-packages.nix:8` (`helix` in `environment.systemPackages`) und home-manager greifen dieselbe Derivation. Keine Duplizierung, kein `programs.helix.package`-Override nötig (grep `pkgs.helix` im ganzen Repo: 0 Treffer — der Overlay ist der einzige Eingriff).
- **Rebuild-Risiko: JA, und zwar designbedingt.** `helix.inputs.nixpkgs.follows = "nixpkgs"` (flake.nix:36) zwingt den Master-Build gegen das *lokale* unstable nixpkgs. helix.cachix.org spiegelt aber Helix-CI-Builds gegen *deren* Eigenlock — bei Drift (unstable wandert täglich) → Cache-Miss → **voller Rust-Rebuild von helix auf dem Desktop** bei jedem Bump. Der mitgebrachte Substituter mildert das nur, wenn die Inputs zufällig synchron sind.
- **Update-Disziplin fehlt:** Lock 2 Monate alt trotz unstable-Nixpkgs daneben. Entweder Input-Rhythmus etablieren (bump + Rebuild-Zeit einplanen) oder den Input streichen — nixpkgs-Helix bei unstable ist current genug und gratis.

### HIGH — Doppelte LSP-Server pro Buffer: Editor-Flut als Trägheitsfaktor

**Dateien:** `editors/helix-lsp/nix.nix`, `editors/helix-lsp/markdown.nix`

**Beleg:**
```nix
# nix.nix:3 + 18-23
programs.helix.extraPackages = with pkgs; [ nixd nil nixpkgs-fmt statix deadnix ];
...
language = [{
  name = "nix";
  language-servers = [ "nixd" "nil" ];
```
```nix
# markdown.nix:5,16-18
programs.helix.extraPackages = with pkgs; [ marksman markdown-oxide ];
...
language-servers = withTypos [ "marksman" "markdown-oxide" ];
```
- **nix + nil gleichzeitig**: Helix startet pro `.nix`-Buffer BEIDE Server. nixd evaluiert zusätzlich die Flake des Editier-Projekts live (nix.nix:10-12: `builtins.getFlake (toString ./.)` für nixpkgs-Import und flake-parts-Options) — auf größeren Flakes spürbar CPU/RAM. Doppelte Completion/Diagnose-Quellen, die sich gegenseitig duplizieren.
- **markdown**: marksman + markdown-oxide + typos-lsp = **3 Server pro .md-Buffer**.
- **Flut gesamt:** 16 `extraPackages` über 9 Dateien (nix 5, markdown 2, bash 3, fish 1, text/typos 2, toml 1, yaml 1, just 1) — **alle ungepinnt aus nixpkgs-unstable**, keiner hat eine Version festgenagelt. Gepinnt ist nur helix selbst (Input) und llm-agents (Input).
- **Toter Ballast:** `statix`, `deadnix` (nix.nix:3) liegen nur im Helix-PATH; an keine `languages.toml`-Diagnostik gebunden — reine Nutzlosigkeit im Wrapper.
- **Warum wichtig:** Der Owner beklagt trägen Desktop. Helix-Sessions mit 2-3 Servern pro Buffer, inline-diagnostics (helix.nix:69-73) + auto-save/auto-format sind genau die Kategorie von Overhead, die sich als „Editor fühlt sich zäh an" äußert. Halbierung der Serverzahl ist gratis.

### MEDIUM — Struktur-Lüge: development-Dateien hängen an core/terminal, nicht an development

**Dateien:** `modules/aspects/development.nix`, `modules/aspects/core.nix`, `modules/aspects/terminal.nix`, `vcs/git*.nix`, `ai/*.nix`

**Beleg:**
- `development.nix` importiert (homeManager): helix, helix-keys, helix-lsp, delta, difftastic, gh, lazygit, bacon, just, repomix, watchexec, docker, kubernetes. **Nicht dabei:** git, git-alias, git-credentials, git-repos, skills, tuicr, workmux, llm-agents.
- Diese sind woanders aktiviert: `core.nix:8,28-31` (nixos `git` + homeManager `git`, `git-alias`, `git-credentials`, `git-repos`), `core.nix:10` (nixos `llm-agents`), `terminal.nix:59-61` (`# ai workflow`: `ai-tools`, `workmux`, `tuicr` — skills.nix definiert das Modul `ai-tools`).
- **Konsequenz:** „development abschalten" lässt git + die gesamte KI-Schiene aktiv. Die Verzeichnisgrenze suggeriert eine Aspektgrenze, die bei Aktivierung nicht existiert. Wer `vcs/git.nix` sucht, findet die Datei unter development, die Verdrahtung unter core — klassische Wartbarkeitsfalle bei „Struktur"-Unzufriedenheit.

### MEDIUM — difftastic: aktiviert, konfiguriert, aber von git nie erreicht

**Dateien:** `vcs/delta.nix`, `vcs/difftastic.nix`

**Beleg:**
```nix
# delta.nix:5,15-18
enableGitIntegration = true;           # git-diffs laufen über delta
programs.lazygit.settings.git.diffRenderers = [{
  colorArg = "always";
  command = "${lib.getExe pkgs.delta} --color-only --paging=never";
}];
```
```nix
# difftastic.nix:13-16
programs.lazygit.settings.git.diffRenderers = [{
  type = "extDiff";
  command = "${lib.getExe pkgs.difftastic} --color=always";
}];
```
Beide Module schreiben in ** dieselbe Liste** (home-manager konkateniert). Der delta-Eintrag trägt keinen Pfad-Filter — nach lazygit-Schema (diffRenderers werden per Pfad-Match gewählt, erster Treffer gewinnt) deckt der delta-Eintrag alles ab und der difftastic-Eintrag feuert vermutlich nie (Semantik offline nicht verifizierbar — bei Aufräumen lazygit-Doku prüfen). Ein `diff.external`/`difftool`-Wiring für difftastic existiert nirgends im Repo. Fazit: 18 Zeilen Modul + 1 Paket im Profil, deren reale Nutzung unklar ist — entweder bewusst begründen oder streichen. Zwei Diff-Tools mit Überlappung sind ein klassischer Verwirrungsort bei 3 Uhr nachts.

### MEDIUM — Aspekt-lokale Substituter werden global: +2 Endpoints für jeden Build

**Dateien:** `editors/helix.nix:4-7`, `ai/llm-agents.nix:4-7`, (Referenz: `core/nix-substituters.nix`, `core/nix.nix:24-30`, `desktop/compositor/niri.nix:6`)

**Beleg:**
```nix
# llm-agents.nix:4-7 — identisches Muster wie helix.nix
nix.settings = {
  substituters = [ "https://cache.numtide.com" ];
  trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
};
```
Der Desktop-Host akkumuliert **5 Substituter** (cache.nixos.org, nix-community, helix.cachix.org, cache.numtide.com, niri.cachix.org). `core/nix.nix:24` kennt das Problem selbst: *„Five substituters over a flaky WLAN: without timeouts Nix can hang for minutes"*. Jeder zusätzliche Substituter = eine NAR-Info-Query pro fehlendem Pfad — auch auf Hosts, die helix/llm-agents nie bauen. Zusammen mit `narinfo-cache-negative-ttl = 30` (core/nix.nix:30, sehr kurz) werden Misses nach 30 s erneut angefragt. Die Timeouts (`connect-timeout = 5`) dämpfen das, aber jedes aspekt-lokale `nix.settings` verstärkt die Query-Last für ALLE Builds. Muster im Verdacht: sollte pro-Input-Derivation (oder per-Host) entschieden werden, nicht pro Aspekt.

### LOW — Dateiname ≠ Modulname: k9s.nix definiert „kubernetes"

**Datei:** `devops/k9s.nix:3`

**Beleg:** `flake.modules.homeManager.kubernetes = { ... programs.k9s ... }` — k9s.nix und kubernetes.nix mergen still in dasselbe Modul `kubernetes`. Wer per grep die Verantwortlichkeit für `programs.k9s` sucht, landet auf zwei Dateien mit „falschem" Namen. Funktioniert, kostet aber Suchzeit.

### LOW — mkOption ohne description — ausgerechnet in den einzigen eigenen Options des Aspekts

**Dateien:** `vcs/git-credentials.nix:5-6`, `vcs/git-repos.nix:21-24`

**Beleg:**
```nix
host = lib.mkOption { type = str; };   # keine description
user = lib.mkOption { type = str; };
```
```nix
options.dotnix.git.repositories = lib.mkOption {
  type = with lib.types; attrsOf str;
  default = { };                       # keine description
};
```
Hausstandard anderswo (z. B. `term/shell-ux/tmux-popups.nix:31-60`): jede Option mit `description`. Types sauber (`attrsOf` + submodule), nur die Dokumentation fehlt.

### LOW — Tote Zeilen und Doppel-Alias

**Dateien:** `automation/bacon.nix:6`, `editors/helix-lsp/json.nix:6`, `vcs/git-alias.nix:36,48`

**Beleg:**
- `bacon.nix:6` — `settings = { };` (leeres Assignment, bewirkt nichts)
- `json.nix:6` — `language-server = { };` (leeres Attrset, kein Effekt)
- `git-alias.nix:36` + `:48` — `can` und `amend` sind **identisch**: `commit --amend --no-edit`

### LOW — Konventionen: sauber, zwei Randnotizen

**Beleg:**
- Entwicklung-Dateien: konsequent `lib.*` (`lib.getExe`, `lib.mkOption`, `lib.genAttrs`, `lib.mapAttrs'`), kein `builtins.*`, Listen/Attrs mergen über das Modulssystem — kein `mkMerge` nötig bei disjunkten Options. `text.nix` definiert `flake.factory.helix` (`withTypos`, `prettier`) und 7 Dateien konsumieren es — sauberes DRY ohne Duplikat.
- Randnotizen: `modules/expose.nix:13` nutzt `builtins.isFunction` statt `lib.isFunction` (Wiring-Datei, außerhalb des Aspekts). `git-credentials.nix:28` nutzt `//` statt `lib.mergeAttrs` — shallow und harmlos, aber stilistisch das einzige `//` in Sichtweite.
- **Positiv:** `git-repos.nix:24-31` kapselt den Clone in `writeShellApplication` mit early-exit (`[ -d "$dest/.git" ] && exit 0`) — `git ls-remote` läuft nur, wenn das Repo wirklich fehlt, nicht bei jedem Switch. Kein Netzwerk-Kosten-Problem.

### INFO — KI-Schiene: runtime-unkritisch, keine persistenten Dienste

**Dateien:** `ai/llm-agents.nix`, `ai/skills.nix`, `ai/tuicr.nix`, `ai/workmux.nix`

**Beleg:**
- `llm-agents.nix` (ganzes Modul): nur `nixpkgs.overlays = [ inputs.llm-agents.overlays.shared-nixpkgs ]` + Numtide-Cache. **Kein systemd-Service, kein Daemon.**
- `skills.nix`: 4 Pakete (`beads`, `beads-viewer`, `skills`, `tokscale`) via Overlay.
- `tuicr.nix`/`workmux.nix`: Paket + xdg-Config + **on-demand** tmux-Popups (`dotnix.tmux.popups`, Keys `r`/`a`). workmux-Sidebar ist bewusst kein Popup (workmux.nix:31-36, Kommentar) — läuft nur auf Tastendruck, nicht dauerhaft.
- llm-agents-Input: gelockt 2026-09-28 (frisch), `follows nixpkgs`, Numtide-Binary-Cache deckt die Pakete — kein Rebuild-Risiko wie bei helix.
- Einziger runtime-nennenswerter Effekt im ganzen Aspekt: `devops/docker.nix:16` — `linger = true` für alle `dotnix.host.members` (nötig für rootless-Docker-Usernamespace), hält User-Manager nach Logout am Leben. Bewusst gesetzt, kein AI-Thema.

### INFO — automation/devops: kein Tot, minimale Module

`just/repomix/watchexec` = je 1 Paket in `home.packages` (6 LOC, nichts zu tot). `bacon` läuft mit HM-Default-Config (tote `settings = {}` siehe oben). `docker.nix` rootless + autoPrune + impermanence für `/var/lib/docker` — stimmig. `kubernetes.nix`/`k9s.nix` konfigurieren k9s/kubecolor + 7 kubectl-Tools, tmux-Popup `k` korrekt an `programs.k9s.enable` gegated (tmux-popups.nix: `inherit (k9s) enable`).

## HardQuestions

1. **Helix-Input: welchen Preis soll er haben?** `follows = "nixpkgs"` zerstört die helix.cachix.org-Trefferrate (CI baut gegen Helix-Eigenlock) → bei jedem Bump droht lokaler Rust-Rebuild auf dem Desktop. Und der Lock ist 2 Monate alt — der „master"-Vorteil gegenüber nixpkgs-unstable-Helix ist damit faktisch null. Beides zusammen ist der schlechteste Punkt auf der Kostenkurve: **entweder** Input fallen lassen (nixpkgs-Helix, gratis, current), **oder** bump-Rhythmus etablieren und Rebuild-Zeit bewusst einplanen — Status quo ist beides nicht.
2. **Welcher Nix-LSP und welcher Markdown-LSP soll gewinnen?** nixd+nil und marksman+markdown-oxide starten pro Buffer doppelt/dreifach (inkl. typos-lsp). Halbierung der Serverzahl ist der billigste Performance-Gewinn im Editor-Stack — es fehlt nur die Entscheidung, welcher stirbt.
3. **Ist difftastic gewollt oder Relikt?** Git-Diffs laufen über delta (`enableGitIntegration`), ein difftastic-Wiring für git existiert nicht, und in der lazygit-`diffRenderers`-Liste konkurriert sein Eintrag mit einem pfad-losen delta-Eintrag (erster Treffer gewinnt — Streichkandidat). Antwort geklärt → entweder Module löschen oder delta/difftastic-Rollen sauber trennen (z. B. difftastic nur via `git difftool`).
