# Research 4/10 — Aspekt `term` (Shell-Ökosystem & Daemons)

Repo: `/home/denis/repositories/private/.dotnix-aspects`, Branch `refactor/public-release`, 38 Dateien, 1198 LOC unter `modules/aspects/term/`. Uncommitted: `M modules/aspects/term/shell-ux/sesh.nix` (Modus „configs" + generierte Git-Repo-Sessions entfernt — zur Kenntnis genommen, unberührt). Verifiziert gegen gepinnten home-manager-Rev `7b4c5ec4` (Optionsexistenz: `programs.sesh`, `programs.nix-search-tv`, `programs.nix-init`, `programs.ripgrep-all` — alle vorhanden, keine toten Optionen).

## Summary

Der Aspekt `term` ist überwiegend **CLI-Pakete, keine Daemons** — das 10-Dateien-Verzeichnis `monitoring` hat exakt **null** Laufzeitkosten (alles packages/HM-Konfigs, kein Timer, kein Service). Hauptverdächtiger „träger Desktop" liegt also außerhalb von `term`. Was `term` trotzdem dauerhaft laufen lässt: (1) `fish_greeting` startet **fastfetch in jedem interaktiven Fish — inklusive jedes tmux-Panès/Popups** (merkbare Latenz pro Pane + visueller Müll), (2) ein **mbsync-Systemd-Timer alle 15 Minuten über alle Mailaccounts** plus ein zweiter Sync-Pfad über `notmuch hooks.preNew`, (3) **zimal parallel verwaltete gpg-Agent-Stacks** (NixOS + HM) mit widersprüchlichem Pinentry, (4) **tmux-continuum** mit resurrect-Save alle 15 Min im laufenden tmux-Server, (5) **direnv-instant**-Daemons pro Shell-Hook. Redundanz-Standout: **fzf + skim + atuin** gleichzeitig aktiviert, mit überlappenden Ctrl-R-/Ctrl-T-Bindings. Struktur/Konventionen sind überdurchschnittlich sauber (Assertions gegen Key-Kollisionen im tmux-Stack sind vorbildlich); Schwächen sind ein No-Op-Aspekt (`bash`), ungegatelte Cross-Aspect-Popup-Einträge und eine latente Option-Abhängigkeit von `sesh` → `tmux-bindings`.

**Persistenter/periodischer Laufzeitbestand aus `term`-Scope** (vollständige Inventur):

| Komponente | Art | Quelle | Takt |
|---|---|---|---|
| mbsync Timer | systemd user timer | `mailing/maildir.nix:8-9` | alle 15 Min, alle Accounts |
| notmuch preNew → mbsync | Hook bei jedem `notmuch new` | `mailing/maildir.nix:17` | pro Aufruf |
| gpg-agent (HM) | systemd user service/socket | `secrets/gpg.nix:11-22` | permanent |
| gpg-agent (NixOS) | systemweiter Agent-Stack | `secrets/gpg.nix:3-5` | permanent (parallel!) |
| tmux-continuum | Subprocess im tmux-Server | `shell-ux/tmux.nix:93-94` | Save alle 15 Min + Restore beim Start |
| direnv-instant | Daemon pro Shell-Hook | `shell-ux/direnv.nix:20` | pro .envrc-Wechsel |
| fastfetch | pro interaktivem Fish | `monitoring/fastfetch.nix:23-26` | jedes Pane/Popup/Fenster |

**Explizit KEINE Daemons/Timer**: monitoring (10 Dateien, alles Packages), nix (nix-index-Datenbank ist vorgebaut via `nix-index-database`-Input, symlinked — kein Index-Timer; tealdeer-Timer ist **aus**), data, files, shell, atuin (Daemon-Option nicht gesetzt), rbw (Agent spawn on demand).

## Findings

### HIGH

#### H1 — fastfetch läuft in jedem tmux-Pane (fish_greeting ohne TMUX-Guard)
Datei: `modules/aspects/term/monitoring/fastfetch.nix:23-26`, Wechselwirkung `shell-ux/tmux.nix:10` (`shell = lib.getExe pkgs.fish`).
Beleg:
```nix
programs.fish.functions.fish_greeting = lib.mkIf config.programs.fish.enable {
  description = "Greeting with fastfetch";
  body = "fastfetch";
};
```
`fish_greeting` feuert bei **jedem** interaktiven Fish-Start. tmux-Panes, -Windows und das Fish-Popup (`shell-ux/tmux-popups.nix:79`, key `f`) starten alle Fish — d..h. jedes neue Pane druckt einen Sysinfo-Block (fastfetch modul `packages` zählt Nix-Profile, `cpu`/`memory` lesen `/proc`). Kein `if not set -q TMUX`-Guard, anders als beim sesh-Autostart (`shell-ux/sesh.nix:51-55`), der korrekt guardt.
Warum wichtig: 100–300 ms zusätzliche Startlatenz **pro Pane** plus visuelles Rauschen in jedem Split — direkter „sich träge anfühlender" Terminal-UX-Faktor, den man bei jedem Fensteröffnen spürt.

#### H2 — Mail: systemd-Timer alle 15 Min über alle Accounts + zweiter Sync-Pfad
Datei: `modules/aspects/term/mailing/maildir.nix:7-9, 17`.
Beleg:
```nix
programs.mbsync.enable = true;
services.mbsync.enable = true;
services.mbsync.frequency = "*:0/15";
...
hooks.preNew = "mbsync --all";
```
Verifiziert gegen HM-Rev `7b4c5ec` (`modules/services/mbsync.nix:98-109`): `OnCalendar = cfg.frequency`, `WantedBy = ["timers.target"]` — also ein permanenter Timer, der alle 15 Minuten `mbsync` über **alle** Accounts fährt. Zusätzlich läuft jeder `notmuch new` (auch via aerc) vorher nochmal komplett `mbsync --all` (preNew-Hook). Netzwerk-/CPU-/Disk-Churn alle 15 Min plus bei jeder Index-Abfrage.
Warum wichtig: Das ist der einzige echte Dauer-Ticker aus `term`-Scope. Zwei Sync-Pfade für dieselbe Arbeit; bei trägem IMAP-Server oder großem Postfach spürbarer regelmäßiger Load.

#### H3 — fzf + skim + atuin gleichzeitig: doppelte Widgets, Ctrl-R-Dreifachbindung
Dateien: `modules/aspects/term/shell-ux/fzf.nix:21` (`historyWidget.command = ""; # Ctrl-R for Atuin`), `shell-ux/skim.nix:1-25`, `shell-ux/atuin.nix`; aggregiert in `modules/aspects/terminal.nix` (fzf, skim, atuin nebeneinander importiert).
Beleg — fzf.nix und skim.nix sind nahezu identische Zwillingskonfigurationen (beide `defaultCommand = "fd --type f"`, beide changeDir-Widget mit identischem eza-Preview). fzf deaktiviert nur sein Ctrl-R-Widget; skim tut das **nicht**: HM skim-Integration sourct `key-bindings.fish` (verifiziert, `modules/programs/skim.nix:127-129`) und bindet Ctrl-R auf Skim-History — während atuin (fish-Integration default an) ebenfalls Ctrl-R bindet. Ctrl-T/Alt-C binden fzf **und** skim parallel.
Warum wichtig: Drei Tools, zwei fuzzy-Finder, überlappende Key-Bindings — wer zuletzt gesourct wird, gewinnt, Verhalten ist nicht-deterministisch. Skim wird als Binärdependency nur noch vom sesh-picker gebraucht (`sesh.nix:28` `sk --ansi`). Redundanz = Wartungs- und Startup-Kosten (zwei Integrations-Skripte pro Shell-Start), plus ein Konflikt, der jede Ctrl-R-Nutzung zu einer Lotterie macht.

### MEDIUM

#### M1 — gpg-Agent doppelt verwaltet, Pinentry-Widerspruch
Datei: `modules/aspects/term/secrets/gpg.nix:3-5` (NixOS) vs. `gpg.nix:11-22` (HM).
Beleg:
```nix
# NixOS
programs.gnupg.agent.enable = true;
programs.gnupg.agent.enableSSHSupport = true;
programs.gnupg.agent.pinentryPackage = pkgs.pinentry-curses;
# HM (parallel!)
services.gpg-agent = rec { enable = true; enableSshSupport = true; pinentry.package = pkgs.pinentry-gnome3; ... };
```
Beide Stacks laufen permanent (HM-Seite: systemd user service/socket, verifiziert gegen HM `modules/services/gpg-agent.nix:134-148`), beide beanspruchen SSH-Support, mit unterschiedlichem Pinentry (curses vs. gnome3). Der HM-User-Agent überspielt zur Laufzeit den NixOS-Agent — die NixOS-Zeilen sind für den User faktisch tot, bleiben aber als Wartungs-/Verwirrungsquelle stehen.
Warum wichtig: Zwei konkurrierende `SSH_AUTH_SOCK`-Quellen sind klassische Debugging-Hölle; Pinentry-Mix (TTY vs. Wayland-Dialog) produziert je nach Kontext unterschiedliche UIs.

#### M2 — tmux-continuum: Hintergrund-Save alle 15 Min + Session-Restore
Datei: `modules/aspects/term/shell-ux/tmux.nix:93-94`.
Beleg:
```tmux
set -g @continuum-restore 'on'
set -g @continuum-save-interval '15'
```
Der tmux-Server forked alle 15 Minuten einen `resurrect save`-Prozess (schreibt Pane-Inhalte auf Disk, `@resurrect-capture-pane-contents 'on'`, tmux.nix:81) und startet beim Server-Start alle gespeicherten Sessions wieder. Kein Daemon im klassischen Sinn, aber permanente periodische Aktivität im meistlaufenden Prozess des Users.
Warum wichtig: Bewusst gewählt (Session-Persistenz), aber ein legitimer Laufzeit-Kostenposten, den man dem „trägen" Gefühl zuordnen muss — insbesondere Disk-Writes und Process-Spawns im 15-Min-Takt, zusätzlich zum mbsync-Timer (gleiches Intervall, gleiche Minute = synchroner Load-Peak).

#### M3 — Popup-Menü: ungetoggelte Einträge hängen an fremden Aspekten
Datei: `modules/aspects/term/shell-ux/tmux-popups.nix:74-88`.
Beleg: Die Einträge `bluetui` (Z. 74), `wifitui` (Z. 84), `fish`, `nix-tree`, `dua i`, `scratch` (Z. 88) setzen — anders als `bottom`, `lazydocker`, `lazygit`, `k9s`, `aerc`, `gh-dash`, `yazi`, `tv` (alle mit `inherit (X) enable`) — kein Enable-Gate. bluetui wird von `modules/aspects/system/bluetooth.nix` installiert, wifitui von `modules/aspects/system/network-wifi.nix`, lazygit/k9s/gh-dash aus development — alles **außerhalb** des `terminal`-Aggregats.
Warum wichtig: Host ohne bluetooth/wifi/development-Aspekt bekommt Menüeinträge, deren Binary fehlt → Popup stirbt mit command-not-found. Die enable-Gating-Pattern ist im File schon erfunden — sie ist nur unvollständig angewendet.

#### M4 — sesh-Aspekt hat undeklarierte Option-Abhängigkeit von tmux-bindings
Datei: `modules/aspects/term/shell-ux/sesh.nix:65` schreibt `dotnix.tmux.bindings` (und `development/ai/workmux.nix:38` ebenso); definiert wird die Option **nur** in `shell-ux/tmux-bindings.nix:22`.
Beleg: `dotnix.tmux.bindings = map (base: base // { inherit (config.programs.sesh) enable; }) [...]` — ein Setzen einer Option, deren Definition in einem anderen Aspekt-File lebt. Im `terminal`-Aggregate (`modules/aspects/terminal.nix`) kommen beide immer zusammen vor; ein Standalone-Import von `sesh` ohne `tmux-bindings` crasht die Evaluation mit "The option `dotnix.tmux.bindings' does not exist".
Warum wichtig: Bibliothek (dieses Repo ist als wiederverwendbare flake-lib gedacht, vgl. `templates/dotnix`) — die Abhängigkeit ist rein implizit. Entweder Option in ein Core-Modul ziehen oder in sesh dokumentieren.

#### M5 — nix-search-tv-Index-Cache wird auf impermanentem System bei jedem Reboot weggeworfen
Datei: `modules/aspects/term/monitoring/television-nix.nix:7-12`; Fehlen in den persistierten Pfaden.
Beleg: `indexes = [ "nixpkgs" "nixos" "home-manager" "noogle" ]` — nix-search-tv cached per Default unter `$XDG_CACHE_HOME/nix-search-tv` (Upstream-README Z. 157: `// default: $XDG_CACHE_HOME/nix-search-tv`). Term persistiert nur `.cache/nix`, `.cache/nix-index`, `.cache/zellij` (nix-tools.nix:20, nix-index-database.nix:15, zellij.nix:40) — `nix-search-tv` fehlt.
Warum wichtig: Auf der impermanenten Maschine bedeutet das: nach jedem Reboot baut der erste `tv`-Aufruf den nixpkgs-Index neu auf/leicht neu herunter (Minuten). Damit ist der Popup-Eintrag `t` (tmux-popups.nix:86) nach Boots scheinbar „eingefroren/traig".

#### M6 — bash-Aspekt ist ein No-Op
Datei: `modules/aspects/term/shell/bash.nix:3-5`.
Beleg:
```nix
programs.bash = {
  enable = lib.mkDefault false;
};
```
`mkDefault false` ist der HM-Default sowieso — der Aspekt verändert nichts, egal ob enabled oder nicht. Vermutlich als „bash explizit aus"-Statement gemeint, aber `mkDefault` verliert sogar gegen jedes spätere normale `true`.
Warum wichtig: Toter Aspekt im öffentlichen Aggregationspfad (`terminal.nix` importiert `bash`) — Verwirrung für Consumer, die denken, sie schalten damit etwas.

### LOW

#### L1 — tealdeer: zwei gegenläufige Auto-Update-Switches
Datei: `modules/aspects/term/monitoring/tealdeer.nix:5-9`. `enableAutoUpdates = false` (schaltet HM-`tldr-update`-Timer ab — gut, verifiziert gegen HM `modules/programs/tealdeer.nix:96-100`) aber `settings.updates.auto_update = true; auto_update_interval_hours = 720` (tealdeer-interne Prüfung bei Aufruf). Konsistent (kein Timer, seltenstes On-Invocation-Update), aber zwei Switches mit entgegengesetzten Werten und ähnlichem Namen sind Wartungsfallen. Gut: Timer-Vermeidung ist hier bewusst gelöst.

#### L2 — Explizite Leer-Werte = Rauschen
Dateien: `files/eza.nix:11` (`extraOptions = [ ];`), `shell/nushell.nix:6-7` (`plugins = [ ]; settings = { };`), `files/ripgrep-all.nix:6` (`custom_adapters = [ ];`), `monitoring/bottom.nix:17` (`default_layout = "default"` — setzt den Default auf den Default). Alle Optionen existieren (verifiziert), sind aber No-ops. Kürzen reduziert Signal/Rauschen im public-release-Repo.

#### L3 — Kleiner Beschreibungs-Typo
Datei: `modules/aspects/term/shell-ux/tmux-bindings.nix:61`: `description = " Key table to bind in (-T).";` — führendes Leerzeichen.

#### L4 — aerc-Editor `hx` ist ungetoggelte Cross-Aspect-Abhängigkeit
Datei: `modules/aspects/term/mailing/aerc.nix:21` (`compose.editor = "hx"`). Helix kommt aus development/core-Aspekten — aerc ohne helix-Aspekt hat einen kaputten Composer. Gleiches Muster wie M3, geringere Tragweite.

#### L5 — Zwei Disk-Usage-Tools, zwei Multiplexer
Dateien: `files/dua.nix` + `files/dust.nix` (beide im terminal-Aggregate; dua zusätzlich als Popup `dua i`), `shell-ux/zellij.nix` (44 LOC, `enable = lib.mkDefault false`, Z. 4 — zweiter Multiplexer neben tmux, Referenz-Kommentar in tmux.nix:26 verweist auf zellij-Settings). Nicht kaputt, aber Redundanz, die der Besitzer selbst unter „Struktur" leiden könnte: pro Kategorie ein Tool wählen.

#### L6 — Uncommitted-Änderung sesh.nix
`git diff modules/aspects/term/shell-ux/sesh.nix`: entfernt Modus `g` (configs) und die aus `config.dotnix.git.repositories` generierten Named-Sessions. Konsistent mit `config`-Entfernung; kein Folgebruch erkennbar (`config`-Arg bleibt legitim in Nutzung). Zur Kenntnis; nicht angefasst.

### Konsistenz-Check (positiv)

- **Konventionen gehalten**: kein `builtins.*` in term/ (grep leer), kein `with lib;`, das einzige `//` (sesh.nix:66) ist flaches Attribut-Merge auf Bindings — kein deep-`//`-Verstoß. `{ pkgs, ... }`-Stil durchgehend.
- **mkOption-Qualität**: `tmux-bindings.nix` und `tmux-popups.nix` sind vorbildlich — explizite `types.*`, descriptions, und **Assertions gegen Key-Kollisionen** (bindings.nix:87-95 pro Key-Table, popups.nix:88-91 global) mit sprechender Fehlermeldung. Der Doku-Kommentar „Bindings written straight into extraConfig stay invisible to this check" (bindings.nix:25-28) zeigt Bewusstsein für die Grenze des Patterns.
- **Cross-Gating**: `fastfetch.nix` (`lib.mkIf config.programs.fish.enable`), `sesh.nix` (`inherit (config.programs.sesh) enable`), tmux.nix-Fallback (`mkIf (!config.programs.sesh.enable)`) — sauber; funktioniert, weil alle referenzierten Optionen HM-Upstream-Optionen sind (Existenz gegen Rev `7b4c5ec` verifiziert).
- **Multi-Writer-Merging**: 9 Dateien schreiben `flake.modules.homeManager.impermanence`, 4 schreiben `homeManager.tmux` — korrekt, weil `flake.modules.homeManager` vom HM-Flake-Modul als `attrsOf deferredModule` deklariert ist; die Bodies mergen als Module. Konstruktion ist dendritisch beabsichtigt, aber für Leser nicht offensichtlich — ein Satz Doku im README würde helfen.
- **Shell-Startup-Kette** (Bewusstseins-Befund, kein Bug): pro Fish-Start laufen fzf-Integration, skim-Integration, atuin, carapace, starship, zoxide, direnv-instant-Hook, ggf. fastfetch + sesh-connect. Alles Standard-HM-Preis, aber die Summe ist der messbarste Term-Beitrag zur „trägen" Wahrnehmung (zusammen mit H1).

## HardQuestions

1. **fastfetch-Platzierung**: Soll der Sysinfo-Dump wirklich in **jedem** tmux-Pane/Popup laufen (`fish_greeting` ohne TMUX-Guard), oder nur im ersten Terminal nach Login? Ein Einzeiler-Guard (`if not set -q TMUX`) würde die spürbarste Term-Latenz sofort eliminieren — gibt es einen bewussten Grund für den Status quo?
2. **Finder-Konsolidierung**: fzf, skim und atuin sind parallel aktiv mit überlappenden Bindings (Ctrl-R: atuin vs. skim; Ctrl-T/Alt-C: fzf vs. skim). Welcher Finder ist der Hausstandard? (Skim wird mindestens als sesh-picker-Backend gebraucht — als Widget-Layer wäre eine Abschaltung konfliktfrei.)
3. **Mail-Takt**: mbsync-Timer alle 15 Min über alle Accounts **plus** preNew-Vollsync bei jedem `notmuch new` — ist das bewusste „Mail immer frisch"-Semantik, oder soll der Hook der einzige Sync-Pfad sein und der Timer lockerer (z. B. stündlich)? Beide Pfade zusammen verdoppeln die IMAP-Arbeit.
