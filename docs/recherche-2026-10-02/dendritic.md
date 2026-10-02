# Research 2/10 — Dendritic-Konventionen & Aspekt-Struktur

Repo: `/home/denis/repositories/private/.dotnix-aspects` (Stand HEAD `ac7724c`, Working tree: `M modules/aspects/term/shell-ux/sesh.nix` — unangetastet).
Maßstab: `dendritic-nix`-Skill (`SKILL.md`, `references/setup.md`, `references/aspect-patterns.md`).
Umfang: 146 `.nix`-Dateien unter `modules/` + `templates/`, 4.632 LOC; Klassen-Count der Aspect-Definitionen: 120× `homeManager`, 54× `nixos`, plus `generic` (2 Verwendungsstellen).

## Summary

Das Repo ist ein **echtes Dendritic-Setup auf flake-parts-Basis** — aber in einer Variante, die das Pattern um zwei eigene Erweiterungen baut: (1) Es ist eine **Aspekt-Bibliothek**, die per `flake.flakeModule`-Output an Consumer (Templates) ausgeliefert wird, mit einem Input-Rebasing-Wrapper (`modules/expose.nix`); (2) Hosts sind **keine Features**, sondern Einträge einer eigenen `dotnix`-Registry (`attrsOf submodule` in `modules/parts/configuration.nix`). Die Mechanik der Aspekte selbst ist konform: `flake.modules.<class>.<name>`, Import-Regeln sauber (keine konditionalen Imports, keine Cross-Class-Verstöße, keine doppelten Imports entlang eines Consumer-Pfads), User sind Features, `generic`-Klasse und Collector-Muster sind in Gebrauch.

Die Schwächen liegen in der **Konventions-Disziplin**, nicht in der Mechanik: Aspect-Name und Datei-Name fallen in ~10 Fällen auseinander (das Pattern-Pfeiler-„Dateinamen sind Dokumentation" ist damit tot), Collector-Beiträge werden inline in fremde Feature-Dateien gestreut statt in nach dem Collector benannten Dateien, die physischen Gruppen (`core/`, `system/`, …) divergieren von den logischen Tiers gleichen Namens, und die Bibliothek injiziert ihr eigenes Repo-Tooling (devshell, treefmt, pre-commit, templates, `debug = true`) in jede Consumer-Flake. Das Template `templates/dotnix` ist in aktueller Form nicht evaluierbar (Case-Mismatch `myUser`/`myuser`, fehlende `core`-Tier im Host), und das README dokumentiert eine ältere Architektur (`modules/options.nix`, `factories.nix` existieren nicht).

## Findings

### High — Template out-of-the-box nicht evaluierbar

Dateien: `templates/dotnix/modules/hosts/myHost/configuration.nix`, `templates/dotnix/modules/users/myUser/default.nix`, `modules/parts/configuration.nix`, `modules/aspects/core/users.nix`.

Beleg:
- `hosts/myHost/configuration.nix:9`: `members = [ "myUser" ];` (großes U) — `users/myUser/default.nix:2`: `let user = "myuser";` (kleingeschrieben). `parts/configuration.nix:47`: `let userModules = lib.attrVals host.members modules.nixos;` → `modules.nixos."myUser"` existiert nicht (definiert ist `nixos."myuser"`) → `missing attribute`-Fehler. Gleiches gilt für `generic."myUser"` via `core/users-profile.nix:18` (`imports = with self.modules; [ generic."${username}" ];`).
- `hosts/myHost/configuration.nix:4-9`: `modules = with nixos; [ dell-precision-5570 system development ];` — **keine `core`-Tier**. `nixos.core` ist aber die einzige Quelle für `nixos.home-manager` (`core/home-manager.nix:7`: `home-manager.sharedModules = [ modules.homeManager.core ]`), `users`, `age`. Ohne sie sind `home-manager.users.*` (gesetzt in `core/users-profile.nix:17` und Template `default.nix:7-11`) und `age.secrets` (`core/users.nix`, `users.users` via `config.dotnix.host.members`) Optionen, die nie deklariert wurden → Eval-Fehler.
- `README.md:21`: „See `modules/options.nix` for the host/user schema and `factories.nix` for how configurations are assembled" — **beide Dateien existieren im Baum nicht** (146 Dateien verzeichnet, kein `options.nix`, kein `factories.nix`). Tatsächliche Rolle spielen `modules/parts/configuration.nix` (Registry + `nixosConfigurations`) und `modules/expose.nix`.

Warum wichtig: Das Template ist der Onboarding-Pfad (flake.templates.default, `parts/templates.nix`). Wer es kopiert, rennt in zwei Eval-Fehler, bevor irgendetches baut; das README verstärkt das, indem es auf eine nicht existierende Architektur zeigt. Direkter Treffer auf die Wartbarkeits-Unzufriedenheit des Owners.

### High — Aspect-Name ≠ Datei-Name (Pattern-Pfeiler verletzt)

Das Pattern bezahlt seine Lesbarkeit damit, dass der Dateiname den Aspekt verrät („File names are documentation, not mechanism"; Skill: „one feature = one name"). Im Repo definiert eine Datei häufig Aspekte unter anderen Namen:

| Datei | Definierte Aspekte | Zeile |
|---|---|---|
| `modules/aspects/development/ai/skills.nix` | `homeManager.ai-tools` | :2 |
| `modules/aspects/desktop/greeter/tuigreet.nix` | `nixos.tui-greeter` | :2 |
| `modules/aspects/term/secrets/gpg.nix` | `nixos.gnupg` (:2), `homeManager.gpg-agent` (:8) | |
| `modules/aspects/core/yubikey.nix` | `nixos.yubikey` (:3), `nixos.yubikey-pam` (:8) | |
| `modules/aspects/term/monitoring/television-nix.nix` | `homeManager.television` (konfiguriert aber `programs.nix-search-tv`!) | :1-13 |
| `modules/aspects/core/nix-substituters.nix` | `nixos.nix` (reiner Collector-Beitrag) | :2 |
| `modules/aspects/desktop/compositor/niri-bindings.nix` | `homeManager.niri` | :2 |
| `modules/aspects/development/devops/k9s.nix` | `homeManager.kubernetes` | :2 |
| `modules/aspects/desktop/shell/dms-settings.nix` | `homeManager.dms` | :2 |

Beleg-Spitzen: `television-nix.nix:3`: `programs.nix-search-tv.enable = true;` unter dem Aspect `homeManager.television` — derselbe Aspect-Name wie `television.nix:2` (`programs.television.enable = true;`). `core.nix:13` importiert `yubikey-pam` — um zu wissen, dass das in `yubikey.nix` liegt, muss man greppen.

Warum wichtig: Das ist die Wartbarkeits-Kernlast: Aspekt-Suche per Dateiname scheitert in ~10 Fällen; `television`/`television-nix` ist zudem eine faktische Namenskollision zweier verschiedener Programme auf einem Aspect-Namen (Merge ist hier zufällig harmlos, weil disjunkte Options-Pfade).

### High — Bibliothek injiziert Repo-internes Tooling in jede Consumer-Flake

Dateien: `modules/expose.nix`, `modules/parts/{flake-parts,devshell,treefmt,pre-commit,templates}.nix`.

Beleg:
- `expose.nix:17-19`: `lib.pipe inputs.import-tree [ (i: i.addPath "${modules}/aspects") (i: i.addPath "${modules}/parts") … ]` — der `flake.flakeModule`-Output, den Consumer per `templates/dotnix/modules/parts.nix:2` (`imports = [ inputs.dotnix.flakeModule ];`) importieren, umfasst **auch komplett `modules/parts/`**.
- Damit landen im Consumer: `devshells.default` inkl. Namen „dotnix" und Package-Liste (`parts/devshell.nix:6-33`), treefmt-Defaults inkl. `formatter`-Output (`parts/treefmt.nix:7-19`), pre-commit-Hooks (`parts/pre-commit.nix:5-15`), **`flake.templates.default`** mit Beschreibung „Dendritic NixOS configuration using dotnix" (`parts/templates.nix:2-7`) und `debug = lib.mkDefault true` (`parts/flake-parts.nix:5`).
- `debug = true` zwingt flake-parts zur Eager-Evaluation der gesamten Modul-Config des Consumers (bessere Fehlermeldungen, spürbar langsamere Eval) — als Default an jeden Consumer vererbt, nur mit Kenntnis der Stelle über `mkForce` übersteuerbar.

Warum wichtig: Direkte Struktur→Performance-Brücke (Thema des Owners), plus Überraschungseffekt: die Consumer-Flake zeigt einen devshell, Formatter-Einstellungen und Templates, die sie nie deklariert hat; eigene treefmt-Programme des Consumers mergen mit den Bibliotheks-Defaults. Die Bibliothek sollte nur Aspekte + die zwingend nötigen Parts (Registry/`configuration.nix`, `home-manager`, `age`) wrappen.

### Medium — Collector-Beiträge inline gestreut statt nach Collector benannt

Das Collector-Muster ist die eine sanktionierte Ausnahme von „Aspect heißt wie das Feature" — aber die Konvention verlangt Signalisierung über den Dateinamen: „putting the contribution in a file named after the collector, inside the contributor's directory" (Skill, aspect-patterns.md, Collector).

Beleg: `homeManager.impermanence` wird in **22 Dateien** definiert (u. a. `term/shell/fish.nix:25`, `desktop/apps/firefox.nix:158`, `term/shell-ux/yazi.nix`, `desktop/shell/xdg.nix`, `development/vcs/gh.nix`, `term/mailing/aerc.nix`, …), `nixos.impermanence` in **9 Dateien** (u. a. `core/age.nix`, `core/nix.nix`, `core/ssh.nix`, `system/bluetooth.nix`, `system/network.nix`, `development/devops/docker.nix`). Analog `homeManager.tmux`-Beiträge in `sesh.nix:64`, `tuicr.nix:48`, `workmux.nix:28` (nicht-modifizierbar: `sesh.nix`), `homeManager.niri` in 4 Dateien, `homeManager.helix-lsp` in 10 Sprach-Dateien.

Warum wichtig: Funktional korrekt (Module-System merged), aber die Persistenz-Fläche einer App zu finden oder den Impermanence-Bestand zu auditieren ist nur per Repo-Grep möglich. Positiv-Gegenbeispiel im selben Baum: `tmux-bindings.nix`/`tmux-popups.nix` deklarieren `options.dotnix.tmux.bindings/popups` mit Duplikat-Key-Validierung (`tmux-bindings.nix:31,80`; `tmux-popups.nix:26,68`) — Contribution-Punkte mit Schema, so sollte es aussehen. `helix-lsp/` (Verzeichnis = Collector-Name, je eine Datei pro Sprache) ist die richtige Formel für viele Beiträge.

### Medium — Physische Gruppen divergieren von den logischen Tiers gleichen Namens

Dateien: `modules/aspects/{core,system,desktop,development,terminal}.nix` vs. Verzeichnisbaum.

Beleg (Tier-Importliste → tatsächlicher Wohnort):
- `core.nix:3-14` (nixos.core) importiert `fish` (wohnt in `term/shell/fish.nix`), `git` (`development/vcs/git.nix`), `llm-agents` (`development/ai/llm-agents.nix`).
- `system.nix:3-13` importiert `performance` (wohnt in `core/performance.nix`).
- `desktop.nix:3-11` importiert `fonts` (wohnt in `core/fonts.nix`).
- `development.nix:3-11` importiert `nix-ld` (wohnt in `core/nix-ld.nix`).
- `terminal.nix:35-39` importiert `ai-tools` (`development/ai/skills.nix`), `workmux`, `tuicr` (`development/ai/`).

Warum wichtig: Gruppen sind lt. Skill „for humans only" — legitim. Aber hier tragen Gruppe und Tier **denselben Namen** (core/=Tier core), während die Mitgliedschaft auseinanderläuft: `core/fonts.nix` gehört zum Desktop-Tier, `core/performance.nix` zum System-Tier, `term/shell/fish.nix` zum Core-Tier. Die Namensgleichheit suggeriert eine Entsprechung, die nicht existiert — die häufigste Quelle für „wo muss ich suchen?"-Reibung. README-Tabelle (`README.md:10-17`) beschreibt die Gruppen, nicht die Tiers.

### Medium — Core-Aspekte nicht self-contained: verdeckte Abhängigkeit von der dotnix-Registry

Dateien: `modules/aspects/core/{users,age,age-rekey,nh,users-profile}.nix`, `modules/aspects/development/devops/docker.nix`, `modules/aspects/core/certificates.nix`, `modules/parts/configuration.nix`.

Beleg:
- `users.nix:6`: `users.users = lib.genAttrs config.dotnix.host.members (…)` — die Option `dotnix.host` ist nur über `parts/configuration.nix:31-37` (`flake.modules.nixos.dotnix.options.dotnix = { hostname; host; }`) deklariert. Gleiches Muster: `age.nix:13`, `age-rekey.nix:6`, `nh.nix:11`, `users-profile.nix:17`, `docker.nix:12`, `certificates.nix:5`.
- `age-rekey.nix:6`: `secretsDir = "${inputs.self}/modules/hosts/${config.dotnix.hostname}/secrets";` und `certificates.nix:5` (certDir) — die **Bibliothek schreibt dem Consumer den Verzeichnisbaum vor** (`modules/hosts/<hostname>/secrets`), ein verstecktes Layout-Kontrakt, das in keinem README steht (das Template-Verzeichnis erfüllt ihn zufällig nicht — dort existiert kein `secrets/`).
- README claim dagegen: „Each aspect is a self-contained flake-parts module" (`README.md:8`).

Warum wichtig: Ein Consumer, der einzelne Core-Aspekte ohne den `dotnix`-Registry-Aspekt in eine bestehende NixOS-Config importiert, erhält undefined-option-Fehler. Das ist in einer Aspekt-Bibliothek der wichtigste Selbstständigkeits-Versprechensbruch.

### Medium — Hosts sind keine Features: eigene Registry statt Import-basierter Host-Aspekte

Dateien: `modules/parts/configuration.nix`, `templates/dotnix/modules/hosts/myHost/configuration.nix`, `templates/dotnix/modules/users/myUser/default.nix`.

Beleg: Hosts werden als Werte einer flake-parts-Option deklariert — `configuration.nix:29-43`: `options.dotnix = mkOption { type = attrsOf hostSubModule; }` mit `modules`/`members`/`iso`; `:45-60` baut zentral `nixosConfigurations` per `lib.mapAttrs` über `config.dotnix`. Der NixOS-Aspekt `dotnix` (`configuration.nix:31-37`) ist ein Singleton, der pro Host die Optionen `hostname`/`host` deklariert und mit `{ dotnix = { inherit hostname host; }; }` befüllt wird. Kein Host-Aspekt, keine `flake-parts.nix`-Boilerplate pro Host — Abweichung von „a host is just a feature that mostly imports" (Skill). **User sind dagegen Features im Lehrbuch-Sinn**: `myUser/default.nix:4-16` definiert `nixos."${user}"`, `homeManager."${user}"`, `generic."${user}"` mit `home-manager.users.<user>.imports = [ hm."<user>" ]` (Multi-Context) und Tier-Importen.

Warum wichtig: Gemischtes Modell — User-level composition ist dendritisch, Host-level ist ein eigener Dialekt (mit echten Vorteilen: `iso`-Suboption, hostname-Injektion, kein Boilerplate pro Host). Kosten: Hosts sind nicht importier-/erweiterbar wie Features, und `members` bindet User an Host via String-Liste statt über Import-Graph (die Case-Mismatch-Bugs ober wären im Import-Modell strukturell unmöglich).

### Medium — Alternativ-Aspekte verwaist und tiers-gekoppelt

Dateien: `modules/aspects/system/boot-limine.nix`, `modules/aspects/desktop/greeter/tuigreet.nix`, `modules/aspects/core/yubikey-lock.nix`, `modules/aspects/system.nix`.

Beleg: Erreichbarkeits-Scan über alle Tier-Importlisten + Template: `nixos.boot-limine`, `nixos.tui-greeter`, `nixos.yubikey-lock` werden von keinem Tier und vom Template importiert. `system.nix:5-6` pinnen `boot boot-systemd` fest in die System-Tier.

Warum wichtig: Als Bibliothek sind das wählbare Alternativen (limine statt systemd-boot, tuigreet statt dms-greeter) — aber ein Consumer, der `boot-limine` zusätzlich zur `system`-Tier importiert, merged zwei konfigurierende Boot-Aspekte (Konflikt-Potential), und wer limine will, muss sich eine eigene System-Tier ohne `boot-systemd` nachbauen. Das Inheritance-Muster (Tier-Varianten als Aspekt-Ketten, z. B. `system-core` ohne Boot-Entscheidung) wäre der Pattern-gemäße Weg.

### Low — Namespace „dotnix" dreifach belegt

Beleg: (1) flake-parts-Registry `options.dotnix` (`parts/configuration.nix:29`), (2) NixOS-Optionen `dotnix.hostname`/`dotnix.host` (`configuration.nix:31-37`), (3) Home-Manager-Feature-Optionen `dotnix.tmux.bindings`/`dotnix.tmux.popups` (`tmux-bindings.nix:31`, `tmux-popups.nix:26`). Drei semantisch unverwandte Bedeutungen eines Wortes — HM-Kontext „dotnix.tmux" hat nichts mit der Host-Registry zu tun.

### Low — „shell" doppelt vergeben

Beleg: `modules/aspects/desktop/shell/` (DankMaterialShell = Desktop-Shell: `dms.nix`, `thunar.nix`, `qt-theme.nix`, `xdg.nix`) vs. `modules/aspects/term/shell/` (Login-Shells: `fish.nix`, `bash.nix`, `nushell.nix`). Gleiche Ordnungs-Bezeichnung für zwei Fachdomänen.

### Low — Bracket-Konvention ungenutzt

Beleg: Kein Verzeichnis trägt Kontext-Marker wie `[N]`/`[NDn]` (Suche über den Baum negativ). Die Konvention ist im Skill optional, würde aber gerade hier (Gruppe↔Tier-Divergenz, s. o.) die Scanbarkeit verbessern, da „ist das ein Feature oder eine Gruppe?" aktuell nur per Blick in die Datei entscheidbar ist.

### Compliance-Bestand (keine Verstöße gefunden)

- **Keine konditionalen Imports**: `lib.mkIf` im Baum ausschließlich auf Modul-Inhalt (`core/stylix.nix:53`, `term/shell-ux/tmux.nix:144`, `term/monitoring/fastfetch.nix:23`, `development/vcs/git-credentials.nix:27`) — nie um `imports`-Einträge. Entspricht der wichtigsten Struktur-Regel.
- **Keine Cross-Class-Import-Verstöße**: `nixos.*` importiert nur `nixos.*` (+ erlaubt `generic.*` in `users-profile.nix:14,18`); `homeManager.*` analog; `home-manager.sharedModules = [ modules.homeManager.core ]` (`core/home-manager.nix:7`) ist das reguläre Multi-Context-Muster.
- **Keine doppelten Imports entlang eines Pfades**: `homeManager.core` erreicht den User-Kontext ausschließlich über `sharedModules`; Tier-Importlisten sind überschneidungsfrei (grafische Prüfung aller Tier-Listen).
- **`generic`-Klasse korrekt und sparsam**: Options-Aspekt `generic.users-profile` (`users-profile.nix:9-14`) + per-User Werte-Aspekt `generic."<user>"` (Template) — das ist das Constants-Muster für User-Attribute (fullname/email/theme), an der richtigen Stelle.
- **Keine geschlossenen Modul-Argumente** (`{ pkgs }:` ohne `...`): keine Funde.

## HardQuestions

1. **Gruppen- vs. Tier-Semantik:** Sollen die physischen Gruppen die Tiers abbilden (Dateien verschieben: `fish`/`git`/`llm-agents` unter `core/`, `performance` unter `system/`, `fonts` unter `desktop/`, `ai/*` unter `term/`), oder sollen Tiers als bewusste Kompositionslayer dokumentiert und die Gruppen als reine Themen-Regale deklariert werden? Ersteres erhöht die Wartungskosten kurzfristig, zahlt aber auf die Kernklage „wo gehört das hin?" ein.
2. **Collector-Beiträge:** Inline-Beiträge beibehalten (22× `impermanence` in App-Dateien, 1 Datei pro Feature) oder auf die Skill-Konvention umstellen (Beitragsdatei benannt nach dem Collector, z. B. `fish/impermanence.nix` — bzw. das `helix-lsp/`-Muster verallgemeinern)? Trade-off: Dateizahl/LoC vs. Auffindbarkeit und saubere Entfernbarkeit einer App samt ihrer Persistenz-Spuren.
3. **Library-Schnittstelle:** Soll `flake.flakeModule` nur Aspekte + Minimal-Parts (Registry, home-manager-Wiring, age) ausliefern und Repo-Tooling (devshell/treefmt/pre-commit/templates, `debug = true`) aus dem `wrapMods`-Baum heraus — oder ist „batteries included" bewusste Entscheidung? Und: sind Hosts als Registry-Einträge gesetzt, oder soll auf Host-Features (Import-Graph) migriert werden, womit `members`-String-Listen und deren Case-Bugs strukturell entfielen?
