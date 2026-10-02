# Research 7/10 — Duplikate, toter Code, Import-Graph

Repo: `/home/denis/repositories/private/.dotnix-aspects` (HEAD `ac7724c`, 2026-09-28).
Live-Konsument: `/home/denis/repositories/private/.dotnix` (WSL-Host `dmi`).
Methodik: repo-weite statische Analyse (Python-Referenzgraph über alle 145 `.nix`-Dateien in `modules/aspects`, `modules/parts`, `templates`; grep-Verifikation jeder Behauptung). Keine nix-Kommandos, keine Code-Änderungen. Uncommitted `M modules/aspects/term/shell-ux/sesh.nix` unangetastet gelassen.

## Summary

**Import-Graph (komplett gemappt):**

```
dotnix-aspects Repo selbst:
  flake.nix ── mkFlake + import-tree ./modules
    ├── modules/expose.nix      → flake.flakeModule = import-tree(modules/aspects ++ modules/parts)
    └── modules/parts/*         → (Repo-eval): devshell, treefmt, pre-commit, agenix-rekey,
                                  templates, flake-parts(modules), home-manager, configuration

Konsument (.dotnix / templates/dotnix):
  flake.nix ── mkFlake + import-tree ./modules
    └── modules/parts.nix (bzw. modules/flake/dotnix.nix)
          imports = [ inputs.dotnix.flakeModule ]
          → registriert JEDE Datei aus aspects + parts im Konsumenten-Flake als
            flake.modules.{nixos,homeManager,generic}.<name>

Host:  dotnix.<host> = { modules = [nixos-Aspektnamen]; members = [user]; }
       → parts/configuration.nix: nixosSystem(host.modules ++ <user-nixos-Module> ++ Defaults)
User:   homeManager.<user>.imports = [hm-Aspektnamen]
       → core/home-manager.nix: sharedModules = [ modules.homeManager.core ] (gilt für ALLE User)

Aspekt-Name ist nur lebend, wenn:
  (a) in einer Aggregator-Liste (core/system/desktop/terminal/development/bootstrap) ODER
  (b) direkt vom Konsumenten gelistet (live: `wsl`, `devops`) ODER
  (c) unter demselben Namen mit einem lebenden Aspekt gemerged (Collector-Muster).
```

**Kennzahlen:** 145 `.nix`-Dateien, 125 registrierte `(class, name)`-Modulnamen, 3 davon von **keinem** Aggregator/Konsumenten erreicht (toter Code), 9 Namen aus **mehreren Dateien** registriert (Collector-Muster, davon 2 fragwürdig), 1 kaputtes Template, 1 latenter Options-Typfehler, ~8 redundante nixpkgs-Default-Setzungen.

**Überraschendster Befund:** Der gesamte `desktop`-Ast (24 Dateien: niri, DMS, Greeter, Apps) und fast der ganze `system`-Ast werden vom einzigen auffindbaren Live-Konsumenten (WSL-Host) **nicht** erreicht — das Live-Repo hatte in seiner gesamten Git-Historie nie einen Desktop-Host. Der träge Desktop des Besitzers ist in keinem der beiden Repos konfiguriert.

## Findings

### HIGH: Drei tote Aspekt-Module — registriert, aber von niemandem erreicht

- `modules/aspects/core/yubikey-lock.nix:2` → `flake.modules.nixos.yubikey-lock`
- `modules/aspects/desktop/greeter/tuigreet.nix:2` → `flake.modules.nixos.tui-greeter`
- `modules/aspects/system/boot-limine.nix:2` → `flake.modules.nixos.boot-limine`

Beleg (Referenz-Suche, beide Repos):
- `modules/aspects/core.nix:3-23` listet `yubikey` **und** `yubikey-pam` (Zeilen 23-24), aber **nicht** `yubikey-lock`.
- `modules/aspects/desktop.nix:3-12` listet `dms-greeter`, aber **nicht** `tui-greeter`.
- `modules/aspects/system.nix:3-14` listet `boot`, `boot-systemd`, aber **nicht** `boot-limine`.
- Live-Repo `.dotnix`: `grep -rn 'boot-limine\|tui-greeter\|yubikey-lock'` → 0 Treffer.
- Python-Referenzgraph bestätigt: exakt diese 3 Namen (plus das Template-eigene `dell-precision-5570`, das vom Template-Host referenziert wird) haben keine einzige Referenz.

Warum wichtig: Der Aufräum-Commit `8b408a9` ("refactor: remove unneccessary aspects") hat nur die `ai.nix`-Familie entfernt (git `--diff-filter=D`: 8 Dateien) — diese 3 Überbleibsel hat er verpasst. Sie evaluieren bei jedem Konsumenten mit (import-tree lädt jede Datei), dokumentieren Alternativen (Limine-Boot, TUI-Greeter), die nie gewählt wurden, und vergrößern den Suchraum bei jeder Wartung.

### HIGH: Template `templates/dotnix` driftet und ist in Kombination mit dem User-Modul kaputt

Beleg:
- `templates/dotnix/modules/hosts/myHost/configuration.nix`: `modules = with nixos; [ dell-precision-5570 system development ];` — **kein `core`**.
- `templates/dotnix/modules/users/myUser/default.nix`: setzt `home-manager.users."${user}".imports = [...]` — die NixOS-Option `home-manager.users` existiert aber nur, wenn `inputs.home-manager.nixosModules.home-manager` importiert wird, und das passiert **ausschließlich** in `modules/aspects/core/home-manager.nix:4` (`flake.modules.nixos.home-manager`, erreichbar nur über `core.nix:9`).
- Commit `880c2b1` ("feat: remove nixos.core from default", 2026-04-20) löschte `modules.nixos.core` aus der Default-Modulliste in `parts/configuration.nix` — das Template wurde nie nachgezogen. Ein aus dem Template erzeugter Host mit User crasht bei der Evaluation (`The option 'home-manager.users' does not exist`) oder läuft ohne jegliche Home-Manager-Konfiguration.
- Drift zum Live-Betrieb (`.dotnix/modules/hosts/dmi/configuration.nix`): `modules = [ core wsl development ]` — live listet `core` explizit. Template-User `terminal development` vs. Live-User `terminal development devops`; Template-User-Gruppen `[ "wheel" "networkmanager" ]` vs. live `[ "wheel" "docker" ]` (`.dotnix/modules/users/denis/configuration.nix`).

Warum wichtig: Das Template ist der `flake.templates.default`-Einstieg (public auf GitHub) und der einzige dokumentierte Weg für Dritte. Es beschreibt einen Zustand (Host ohne `core`), den der Besitzer selbst nirgendwo fährt und der mit der User-Datei nicht evaluierbar ist.

### HIGH: Der komplette `desktop`-Ast hat keinen erreichbaren Konsumenten

Beleg:
- Live-Konsument `.dotnix` enthält genau einen Host: `dmi` mit `modules = [ core wsl development ]` und User-Importen `terminal development devops` — kein `desktop`, kein `system`.
- Git-Historie von `.dotnix` (`git log --diff-filter=A -- modules/hosts/*`): der einzige je angelegte Host ist `dmi` (WSL); `--diff-filter=D` zeigt keine gelöschten Hosts. Es gab nie einen Desktop-Host in diesem Repo.
- Kein weiterer Konsument auffindbar: `~/repositories/private` enthält nur `.dotnix`, `.dotnix-aspects`, `agents`, `agents__worktrees`; `find /home/denis -maxdepth 3 -name flake.nix` liefert keine weitere dotnix-Referenz.
- Betroffener Umfang: `modules/aspects/desktop/**` (24 Dateien: niri, niri-bindings, dms, dms-settings, dms-greeter, dms-plugins, tuigreet, apps/*, terminal/*, shell/*, compositor/*) plus die system-seitigen Desktop-Abhängigkeiten — allesamt nur über `desktop.nix`/`system.nix`-Aggregatoren erreichbar, die niemand importiert.

Warum wichtig: Der Besitzer beklagt einen trägen niri+DMS-Desktop — dessen Konfiguration liegt in **keinem** der beiden untersuchten Repos. Entweder existiert ein drittes, unsichtbares Konsumenten-Repo (dann ist alles ok, aber die Analyse der anderen Forscher läuft ins Leere), oder der Desktop-Ast ist gepflegter, aber aktuell toter Code (24 aktiv gewartete Dateien, letzte Desktop-Commits frisch — z.B. "persist dms-greeter session state"). Diese Frage klärt auch, ob die Desktop-Findings der anderen Researcher (Performance von DMS/stylix) überhaupt den Live-Desktop beschreiben.

### MEDIUM: Live-Konsument pinnt eine PRE-Cleanup-Version der Aspects

Beleg:
- `.dotnix/flake.lock`: dotnix-Input gepinnt auf Rev `0c33875` (2026-09-15, "chore: update tmux extra configuration").
- `git merge-base --is-ancestor 8b408a9 0c33875` → **false**: der Aufräum-Commit (`8b408a9`) und 7 weitere Commits (u.a. `c3b8c3a` "move tuicr and workmux") sind im Live-Pin **nicht** enthalten; `git log 0c33875..HEAD` = 8 Commits.

Warum wichtig: Der WSL-Live-Host evaluiert noch gegen die alte, ungecleante Varianten des Aspects-Repos. Alle Dead-Code-/Struktur-Findings dieses Berichts gelten für HEAD; ob sie den Live-Betrieb bereits entlasten, entscheidet erst der nächste `flake.lock`-Update. Zudem: `.dotnix/flake.nix` referenziert `github:dbekasow/dotnix-aspects` (publish-first-Workflow), das Repo lokal auf `main` ohne unpushte Commits (`git branch -vv`: in sync mit `origin/main`).

### MEDIUM: Konsumenten erben das komplette Dev-Tooling (parts) inkl. `debug = mkDefault true`

Beleg:
- `modules/expose.nix:16-23`: `flake.flakeModule.imports = wrapMods (lib.pipe inputs.import-tree [ (i: i.addPath "${modules}/aspects") (i: i.addPath "${modules}/parts") ... ])` — `parts` wird mit ausgeliefert.
- Der Konsument importiert nur `inputs.dotnix.flakeModule` (`.dotnix/modules/flake/dotnix.nix`, `templates/dotnix/modules/parts.nix`), bekommt damit ALLE 9 parts-Dateien:
  - `modules/parts/treefmt.nix` — setzt `formatter` und treefmt-Programme im Konsumenten-Flake,
  - `modules/parts/devshell.nix` — `devshells.default` mit nh/nvd/nurl/nix-tree/…-Pakete im Konsumenten,
  - `modules/parts/pre-commit.nix` — git-hooks-flakeModule + prek-Hooks,
  - `modules/parts/flake-parts.nix:6` — **`debug = lib.mkDefault true`** wird im Konsumenten-Flake wirksam,
  - `modules/parts/templates.nix` — der Konsument-Flake veröffentlicht seinerseits `flake.templates.default` ("Dendritic NixOS configuration using dotnix") als Output,
  - `modules/parts/age.nix` — agenix-rekey-flakeModule.

Warum wichtig: Jeder `nix`-Befehl im Konsumenten (eval, `flake show`, rebuild) evaluiert zusätzlich Treefmt, Pre-commit, Devshell, agenix-rekey-Module. Das ist direkter Import-Graph-Ballast auf dem kritischen Pfad des „trägen" Setups und ein Struktur-Smell: eine NixOS-Aspekt-Bibliothek liefert ihren eigenen Repo-Entwicklungskram mit aus. (Laufzeit-Relevanz quantifiziert die Performance-Researcher; hier ist der Import-Beleg festgehalten.)

### MEDIUM: `nixos.nix` doppelt registriert — Dateiname und Modulname fallen auseinander

Beleg:
- `modules/aspects/core/nix.nix:2`: `flake.modules.nixos.nix = { lib, pkgs, ... }:`
- `modules/aspects/core/nix-substituters.nix:2`: `flake.modules.nixos.nix = {` — **derselbe Modulname aus einer zweiten Datei**.
- deferredModule-Merge macht beide additiv; `core.nix:12` importiert den gemeinsamen Namen `nix` (auch `bootstrap.nix`, live-Host via core).

Warum wichtig: Niemand, der `nix-substituters.nix` öffnet, erwartet, dass er denselben Modul füllt wie `nix.nix`. Dasselbe Muster in harmloser Form bei: `homeManager.dms` (`dms.nix:20` + `dms-settings.nix:2`), `homeManager.niri` (`niri.nix:19` + `niri-bindings.nix:2` + `apps/handy.nix:29`), `homeManager.tmux` (6 Dateien: `tmux.nix:2`, `tmux-bindings.nix:2`, `tmux-popups.nix:2`, `sesh.nix:58`, `workmux.nix:28`, `tuicr.nix:48`), `homeManager.helix-lsp` (9 Dateien in `editors/helix-lsp/`), `homeManager.kubernetes` (`kubernetes.nix` + `k9s.nix`), `homeManager.television` (`television.nix` + `television-nix.nix`), `nixos.impermanence` (9 Dateien), `homeManager.impermanence` (23 Dateien).

Einordnung: Das Collector-Muster ist die dokumentierte Dendritic-Konvention (Commit `36130fb` "move persistence configs into target aspect") und als solches **kein toter Code** — alle genannten Dateien sind über den gemeinsamem Modulnamen lebend. Aber zwei Fälle verletzen die eigene Nomenklatur: `television-nix.nix` registriert `homeManager.television`, konfiguriert aber `programs.nix-search-tv` (ein anderes Programm im Television-Modul), und `k9s.nix` hängt k9s-Config an `homeManager.kubernetes`. Antwort auf die Prompt-Frage „dms-settings.nix vs dms.nix": **kein inhaltliches Duplikat** — `dms.nix` macht Enable/Wiring/Upstream-Imports, `dms-settings.nix` setzt nur `programs.dank-material-shell.settings`; sie teilen sich nur den Modulnamen (Collector).

### MEDIUM: `dms-settings.nix` — 457 Zeilen hart gepinnte Werte

Beleg:
- `wc -l modules/aspects/desktop/shell/dms-settings.nix` → 457 Zeilen, ausschließlich `programs.dank-material-shell.settings = { ... }`.
- Werte sind **ohne** `mkDefault` gesetzt, z.B. `sortAppsAlphabetically = false;` (Z. 158), `clipboardEnterToPaste = false;` (Z. 451), `configVersion = 5;` (Z. 454), daneben Dutzende leere Attrsets/Listen (`registryThemeVariants = { };`, `desktopWidgetInstances = [ ];`, …).
- Merge-Folge: Diese Werte gewinnen gegen jeden Konsumenten-Wert, der nicht `mkForce` nutzt — ein User, der im eigenen Flake z.B. `sortAppsAlphabetically = true` will, muss die Library mkForcen.

Warum wichtig: Das ist der größte einzelne Ballast im desktop-Ast. Ein erheblicher Teil der Werte wirkt wie ein Dump der DMS-Upstream-Defaults (leere Container, `false`-Flags); ob das bewusstes Pinning (configVersion-Migration) oder Copy-Ballast ist, entscheidet der Besitzer. Für die Wartbarkeit: jede DMS-Version, die `configVersion` hochzählt oder Felder umbenennt, macht diese Datei zum Diff-Kandidaten.

### MEDIUM: Latenter Typfehler + halbfertiger ISO-Mechanismus in `parts/configuration.nix`

Beleg:
- `modules/parts/configuration.nix:33`: `hostname = lib.mkOption { type = str; default = null; };` — Typ `str` mit Default `null` ist eine Typverletzung, sobald der Default greift. Heute tritt sie nicht auf, weil `configuration.nix:44` (`{ dotnix = { inherit hostname host; }; }`) den Wert immer setzt — aber die Deklaration ist kaputt (`nullOr str` oder `str` ohne Default wäre korrekt). Genutzt wird die Option nur von `core/certificates.nix` (`config.dotnix.hostname`).
- `modules/parts/configuration.nix:8`: `buildOutput = lib.mkOption { type = str; default = "images.iso-installer"; };` — der Default zeigt auf `config.system.build.images.iso-installer`. **Kein Modul in beiden Repos definiert diesen Pfad** (grep nach `iso-installer`: 0 Treffer außer der Option selbst; der `bootstrap`-Aspekt — `modules/aspects/bootstrap.nix` — importiert nur fish/git/gnupg/locale/network/network-wifi/nh/nix/yubikey, enthält keinen ISO-Build). Kein Konsument setzt je `iso.enable = true` (grep in `.dotnix`: 0 Treffer für `iso`).

Warum wichtig: Der ISO-Paket-Mechanismus (`perSystem.packages."${hostname}-iso"`, configuration.nix:54-62) ist unverifizierter, nie ausgeübter Code — er würde beim ersten echten Versuch vermutlich auf dem nicht existierenden build-Pfad sterben. Unbenutzte Option + toter Mechanismus nach den Aufräum-Commits.

### LOW: Redundante nixpkgs-Default-Setzungen

Beleg (je Datei+Zeile; die zugehörigen nixpkgs-Modul-Defaults sind allgemein bekannte Werte — per Anweisung nicht live evaluiert, mit `nix repl`/grep in nixpkgs-Quelle nachprüfbar):

| Datei:Zeile | Setzung | nixpkgs-Default |
|---|---|---|
| `modules/aspects/system/bluetooth.nix:5` | `powerOnBoot = true;` | `true` |
| `modules/aspects/core/locale.nix:6` | `defaultLocale = lib.mkDefault "en_US.UTF-8";` | `"en_US.UTF-8"` |
| `modules/aspects/core/locale.nix:8-17` | 10× `LC_* = config.i18n.defaultLocale` | Wirkung redundant (nixpkgs setzt `LANG`; ungesetzte `LC_*` erben) |
| `modules/aspects/core/fonts.nix:16` | `antialias = true;` | `true` |
| `modules/aspects/core/fonts.nix:17` | `hinting.enable = true;` | `true` |
| `modules/aspects/core/fonts.nix:22` | `subpixel.lcdfilter = "default";` | `"default"` |
| `modules/aspects/core/fonts.nix:23` | `subpixel.rgba = "rgb";` | `"rgb"` |
| `modules/aspects/system/network.nix:28` | `firewall.enable = true;` | `true` |

Warum wichtig: Jede Zeile ist Ballast, die jemand bei jedem nixpkgs-Umzug gegenprüfen muss, ohne Verhalten zu ändern. Die `LC_*`-Spiegelung ist zusätzlich ein Wartungs-Link (Rename von `defaultLocale` bricht 10 Zeilen).

### LOW: `boot.zfs.forceImportRoot` doppelt gesetzt

Beleg:
- `modules/aspects/system/boot.nix:22`: `zfs.forceImportRoot = false;` (hart, im `boot = {...}`-Block, direkt neben `supportedFilesystems.zfs = false;`)
- `modules/parts/configuration.nix:46`: `{ boot.zfs.forceImportRoot = lib.mkDefault false; }` (weich, global für jeden Host)

Warum wichtig: Dieselbe Aussage an zwei Stellen mit unterschiedlicher Priorität. Beim nächsten ZFS-Thema muss man beide finden. Eine kann weg (die harte in boot.nix wäre die konsistente, da dort auch der ZFS-Kontext liegt).

### LOW: Substituter-Streuung über 4 Dateien

Beleg:
- `modules/aspects/core/nix-substituters.nix:4-11`: `substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" ]` + Keys — `https://cache.nixos.org` samt Key ist der nix-eigene Default-Substituter, explizit also redundant.
- `modules/aspects/development/editors/helix.nix:5-6`: helix.cachix.org; `modules/aspects/development/ai/llm-agents.nix:5-6`: cache.numtide.com; `modules/aspects/desktop/compositor/niri.nix:6-7`: niri.cachix.org — jeweils `nix.settings.substituters`/`trusted-public-keys` im eigenen Aspekt.

Warum wichtig: Additiver Listen-Merge macht das funktional korrekt, aber die „Wo sind meine Substituter?"-Frage ist nur per grep über core UND development UND desktop zu beantworten. Duplikat-Minderung: `cache.nixos.org`-Zeilen können aus `nix-substituters.nix` raus (Default), die Datei behält nur nix-community.

### LOW: Template-Mirror konsistent, aber Live-Only-Aspekte im Template unsichtbar

Beleg:
- Live-Konsument lebt das Collector-Muster selbst vor: `.dotnix/modules/users/denis/features/{aws,azure,kubeconf,repositories}.nix` registrieren **alle** `flake.modules.homeManager.devops` — 4 Dateien, 1 Modulname, importiert über `devops` in der User-Datei. Das Template zeigt nichts davon (User: nur `terminal development`).
- Template hostet `flake.modules.nixos.dell-precision-5570` (templates/.../hardware.nix) — konsistent benutzt in templates/.../configuration.nix. Kein toter Verweis. (Dell Precision 5570 = die echte Laptop-Hardware des Besitzers; im Live-WSL-Repo existiert kein Pendant — ein weiteres Indiz für das fehlende Laptop-Konsumenten-Repo, siehe High-Finding 3.)

Warum wichtig: Nicht defekt, aber das Template zeigt nicht die Verdrahtung, die der Besitzer tatsächlich fährt (devops-Collector, core im Host). Wer dem Template folgt, landet beim kaputten High-Finding 2.

### Verifiziert NICHT tot (Abgrenzung)

- **`fonts.nix`** (core) — über `desktop.nix:6` referenziert; **`performance.nix`** (core) — über `system.nix:12`; **`nix-ld.nix`** (core) — über `development.nix:7`; die Ordner-Zugehörigkeit (core) sagt also nichts über Lebendigkeit.
- **Aggregator-Referenzen lösen alle auf**: core (fish→`term/shell/fish.nix:6`, git→`development/vcs/git.nix:37`, llm-agents→`development/ai/llm-agents.nix:2`), bootstrap (gnupg→`term/secrets/gpg.nix:2`, alle weiteren verifiziert). Keine dangling Referenz nach den Aufräum-Commits.
- **Uncommitted `sesh.nix`**: Status ` M` bestätigt, Datei nicht gelesen/verändert (Vorgabe).

## HardQuestions

1. **Wo ist der Desktop konfiguriert?** Weder `.dotnix` (historisch nie ein Nicht-WSL-Host) noch ein anderes auffindbares Repo erreicht den `desktop`-/`system`-Ast. Läuft der träge niri+DMS-Desktop gegen ein drittes, hier unsichtbares Repo — oder gegen dieselbe Library in einem Zustand, den niemand mehr baut? Solange das ungeklärt ist, kann die Forschung nicht sagen, ob der desktop-Ast „live-Code" oder der größte gepflegte Tote im Repo ist. (Metapher: Dell Precision 5570 existiert als Template-Hardware-Modul — der zugehörige Konsument fehlt.)
2. **Template bewusst kaputt oder nur veraltet?** Nach `880c2b1` (core aus Default) importiert `templates/dotnix`-Host kein `core` mehr, die Template-User-Datei braucht aber zwingend das home-manager-NixOS-Modul aus `core`. Soll das Template `core` listen (wie live) — und wer validiert `flake.templates.default` überhaupt (kein CI-Job im Repo, der eine Template-Instanz evaluieren würde)?
3. **Wie soll das parts-Leak enden?** Soll `flake.flakeModule` wirklich `modules/parts` mit ausliefern (debug=true, treefmt, pre-commit, devshell, templates-Output im Konsumenten-Flake), oder braucht es zwei Exporte (`flakeModule` nur aspects + configuration-parts; Dev-Tooling nur fürs eigene Repo)? Und: Darf der Live-Pin (aktuell 8 Commits hinter HEAD, pre-Cleanup) weiter auf `github:` zeigen, während lokal entwickelt wird — oder wäre `git+file://` (im Live-flake.nix auskommentiert vorhanden) während der Umstrukturierung ehrlicher?
