# Querschnitts-Gutachten 3/6 — Migrations-/Umbau-Roadmap (.dotnix-aspects)

Datum: 2026-10-02 · Basis: 10 Forschungsberichte + 8 Orakel-Gutachten (/tmp/dotnix-research/), Schlüsselbelege stichprobenartig selbst am Repo verifiziert (expose.nix, flake-parts.nix:5 `debug`, Template-Case-Mismatch `myUser`/`myuser`, fehlendes `core` im Template-Host, `resume_offset`-Fehlen repo-weit, fastfetch ohne TMUX-Guard, `configVersion = 5` in dms-settings.nix:457, helix-Input flake.nix:36-37, `batteryProfileName = "power-saver"` dms-settings.nix:209, Ghostty `custom-shader-animation = true` + `background-blur = 20`, 3 tote Aspekte ohne Aggregator-Referenz, `hostname = mkOption { type = str; default = null; }`, CI-Workflows eval-only + floating Action-Tags, age-rekey.nix:10-19 mit hardcoded persönlichen Pubkeys).

## Vorab-Einordnung (was der Plan NICHT umreisst)

Die Architektur ist richtig und bleibt: Aspekt-Bibliothek + `config.dotnix`-Registry-Factory (`modules/parts/configuration.nix`) + Konsumenten-Repo mit Hosts/Usern. Alle Orakel bestätigen die dendritische Mechanik (keine konditionalen Imports, Klassendisziplin, keine Doppel-Imports). Der Umbau ist Ausführungs- und Schnittstellen-Hygiene, kein Musterwechsel. Anti-Empfehlungen der Orakel bleiben verbindlich: Host-Registry behalten, Impermanence-Inline-Beiträge behalten, Dateien nicht für Tier≠Group-Gleichheit verschieben (außer den 3 echten Fehlplatzierungen), keine Assertions-Schicht für Komposition bauen, Stylix/NUR-Upstream-Pins nicht kollabieren.

## Roadmap (Phasen)

### Phase 0 — Absicherung & Klärung (ca. 4–8 h)

**Was:**
1. Laptop-Konsumenten klären (0,5 h): Flake-Quelle des Desktop-Hosts identifizieren (Clone auf Laptop / Azure-Branch), verifizieren, welcher Aspects-Pin dort fährt. Beleg-Lage: `.dotnix` hat historisch nur Host `dmi` (WSL: `core wsl development`), der gesamte `desktop`-Ast ist von keinem sichtbaren Konsumenten erreicht — trotzdem sprechen frische Performance-Commits für einen unsichtbaren Laptop-Konsumenten.
2. Auto-Merge für die Refactor-Dauer stillegen (0,1 h): `.github/workflows/flake-update.yml` — Schedule deaktivieren (`workflow_dispatch` only). Struktur-PRs dürfen nicht mit der Montags-Lock-Welle (19 Inputs, PR #26-Muster) kollidieren.
3. CI-Consumer-Fixture bauen (2–4 h): neuer Job in `.github/workflows/flake-check.yml`: Template nach `/tmp` kopieren → `nix eval .#nixosConfigurations.myHost.config.system.build.toplevel.drvPath` (dry-eval, kein Build). Gleichzeitig den falschen Kommentar `flake-check.yml:26-27` („covers: treefmt, …") streichen — CI deckt keine Hooks. Diese Fixture evaluiert erstmals den kompletten öffentlichen Vertrag (expose-Wrapping, Factory, Template, Aspekt-Merges).
4. Baseline-Messung am Ziel-Desktop (1–2 h, nach Punkt 1): `systemd-analyze`, `pidstat`-Idle-Profile (dsearch, DMS, handy, dockerd notieren), `powerprofilesctl` auf AC + Akku, `time nixos-rebuild dry-activate` als Eval-Baseline. Ohne Baseline sind die Performance-Effekte der Phasen 1+3 nicht nachweisbar.

**Warum zuerst:** Die Fixture ist das Sicherheitsnetz für jede folgende Phase (Wiring-Orakel: „Keuzzeile" — Template-Bruch, README-Drift und `debug`-Default wären alle von einer Fixture gefangen worden). Die Konsumenten-Klärung entscheidet, ob die Desktop-Runtime-Hebel überhaupt am gefahrenen Pin ankommen. Die Messbasis macht Erfolg messbar.

**Verifikation:** Fixture-Job läuft grün (nach Template-Fix in Phase 1; initial rot ist der Beweis, dass sie funktioniert); Messprotokoll existiert; Auto-Merge aus.

**Risiko + Gegenmaßnahme:** Fixture entdeckt sofort den bekannten Template-Bruch (`myUser`≠`myuser`, fehlendes `core`) — gewollt; Fix folgt in Phase 1. Falls der Laptop-Konsument nicht auffindbar ist: Desktop-Runtime-Änderungen (Phase 3) als Bibliotheks-Änderungen deklarieren und Deploy-Pin offen lassen.

### Phase 1 — Vertrags-/Artefakt-Reparatur + Quick Wins (ca. 8–12 h)

**Was:**
1. Template reparieren (0,5 h): `templates/dotnix/modules/hosts/myHost/configuration.nix` — `members = [ "myuser" ]` (Case-Fix) UND `core` in die `modules`-Liste (ohne core existiert `home-manager.users` nicht → Eval-Crash; Beleg: einzige HM-NixOS-Import-Stelle ist `core/home-manager.nix`).
2. README reparieren (1 h): Phantom-Referenzen `modules/options.nix`/`factories.nix` (README.md:21,46) auf `modules/parts/configuration.nix` umbiegen; Core-Injektions-Behauptung streichen (Commit 880c2b1 hat sie bewusst entfernt); Pfad-Konventionen dokumentieren (`modules/hosts/<host>/secrets/*.pub`, `modules/users/<user>/secrets/home-key.pub`, Consumer-Wurzel `yubikey.pub`/`masterkey.age`); Kompositions-Matrix (core standalone, system⇒Hardware, impermanence⇒disko).
3. `debug = mkDefault true` streichen (0,1 h): `modules/parts/flake-parts.nix:5` — Upstream-Default `false` genügt; spart Eval-Kosten bei jedem outputs-walkenden Kommando des Konsumenten.
4. Helix-Eigen-Input entfernen (1 h): `flake.nix:36-37`, Overlay+Substituter-Block in `editors/helix.nix`, `helix` aus `development.nix`-Imports — der Lock ist 2 Monate alt (Bot friert ihn seit PR #18 ein), `follows = "nixpkgs"` macht helix.cachix.org blind, nixpkgs-Helix ist current genug. Vorher `nix eval nixpkgs#helix.version` gegenprüfen.
5. LSP-Flut halbieren (0,5–1 h): `nil` + `statix`/`deadnix` aus `editors/helix-lsp/nix.nix` (nixd ist der konfigurierte Server), `marksman` aus `markdown.nix` (markdown-oxide behält).
6. Terminal-/Desktop-Latenz-Quick-Wins (je 0,1–0,3 h): `fastfetch`-Guard `if not set -q TMUX` in `monitoring/fastfetch.nix:25` (läuft sonst in jedem tmux-Pane); Ghostty `custom-shader-animation = false` + `background-blur`-Entscheidung in `terminal/ghostty.nix:16-22`; `batteryProfileName` in `dms-settings.nix:209` auf `"balanced"` oder bewusst dokumentiert lassen (klären per `powerprofilesctl` im trägen Moment).
7. Toten Code entfernen (0,5–1 h): `core/yubikey-lock.nix`, `desktop/greeter/tuigreet.nix`, `system/boot-limine.nix` (von keinem Tier/Template erreicht — verifiziert), `term/shell/bash.nix` (No-Op-Aspekt), toter Firefox-Pref `media.autoplay.enabled` (firefox.nix:70), gvfs-Doppelung (`thunar.nix:13`).
8. Options-Fehler beheben (0,25 h): `parts/configuration.nix:33` `hostname`: `nullOr str` oder Default streichen (Typverletzung `default = null` bei `type = str`).
9. Host-seitig (Konsumenten-Repo, 1–2 h inkl. Test): `resume_offset` pro Hardware-Host setzen (`boot.kernelParams = [ "resume_offset=<filefrag -v /swap/swapfile>" ]`) — Btrfs-Swapfile + `resumeDevice` ohne Offset heißt: Hibernate schreibt sauber, Resume liefert frische Session = stiller Session-/Datenverlust. In `system/power.nix` Warn-Kommentar ergänzen. Test: Hibernate → Kaltstart → Session intakt.
10. `narinfo-cache-negative-ttl` von 30 s auf Default 3600 s (`core/nix.nix:30`) — Misses werden sonst alle 30 s gegen alle Substituter neu angefragt.

**Warum jetzt:** Alles ist klein, unabhängig, gut belegt und bricht nichts — schafft aber sofort spürbare Effekte (Terminal-Latenz, Editor, Eval) und macht den öffentlichen Vertrag wahr (Template + README). Die Fixture aus Phase 0 verifiziert die Template-Änderung automatisch.

**Verifikation:** Fixture + `nix flake check` grün; `time`-Vergleich Shell-Start (mit/ohne fastfetch-Guard); `hx --version` = nixpkgs-Release; Hibernate-Kaltstart-Test; subjektiver Akku-Vergleich (`powerprofilesctl set balanced` vs. `power-saver`).

**Risiko + Gegenmaßnahme:** Helix-Entfernung kippt nur, wenn ein konkretes master-Feature nach dem 07-23 unreleased gebraucht wird — dann Option B (follows streichen + Bump-Rhythmus, aber Bot-Anomalie zuerst klären). LSP-Auswahl ist Geschmack — Besitzer-Veto einholen (30-Sekunden-Frage je Server). `batteryProfileName` ist bewusste Entscheidung, kein Bug — dokumentieren statt blind ändern.

### Phase 2 — Export-Vertrag formen (breaking, ca. 4–8 h)

**Was:**
1. `modules/expose.nix` splitten (2–4 h): Produkt-Export (`flake.flakeModule`) = `aspects/**` + `parts/{flake-parts.nix (ohne debug-Zeile), configuration.nix, age.nix}`; `parts/home-manager.nix` konservativ mitnehmen (ohne Eval nicht 100 % klärbar). Dev-Tooling (`parts/{devshell,treefmt,pre-commit,templates}.nix`, `systems`-Default) raus — nur noch Bibliothek-eigene Evaluation (flake.nix importiert weiter alles) oder Opt-in-Export (`flakeModules.devTools` konform via extras/flakeModules.nix). **Achtung:** `parts/flake-parts.nix` MUSS im Export bleiben — ohne ihn ist `flake.modules` undefiniert und alle 132 Aspekte tot. `parts/age.nix` bleibt (rekey-App, Template-Justfile hängt dran).
2. Konsumenten-Migration (1–2 h): reales Konsumenten-Repo ergänzt eine Import-Zeile für Dev-Tooling (falls gewünscht) und updated den Pin — während des Refactors ehrlicherweise `git+file://` (in `.dotnix/flake.nix` auskommentiert vorhanden), am Ende zurück auf `github:`.
3. Persönliche Config aus öffentlichen Aspekten lösen (2–4 h): `core/age-rekey.nix:10-19` — `masterIdentities` als `dotnix`-Option (Registrierung in `parts/configuration.nix`), persönliche Pubkeys/Pfade ins Konsumenten-Repo. Für den Public Release Pflicht (fremde Konsumenten-Secrets würden sonst an die Pubkeys des Autors rekeyt); `age-rekey.nix:9` unguarded `lib.readFile` zusätzlich mit `pathExists`-Guard wie `certificates.nix:6` absichern.

**Warum nach Phase 1:** Der Split ist der einzige echte Breaking Change des Plans — er braucht die Fixture als Regressionsschutz und das reparierte Template als Referenz-Instanz. Der age-rekey-Umbau ändert die Options-Oberfläche, die die Fixture mittestet.

**Verifikation:** Fixture grün; Konsumenten-Repo `nix flake check` + `nix run .#rekey`-Dry-Run grün; Konsumenten-Outputs enthalten keine Devshell/formatter/templates mehr (`nix flake show`).

**Risiko + Gegenmaßnahme:** Jeder externe Konsument bricht still — Gegenmaßnahme: koordinierter Hinweis (README-Breaking-Note) + Owner-Konsumenten im selben Zug migrieren. `parts/home-manager.nix`-Entfernung nur, wenn Konsumenten-Rebuild beweist, dass kein Aspekt ihn braucht.

### Phase 3 — Desktop-Stack kurieren (ca. 6–12 h)

**Was:**
1. `dms-settings.nix` reduzieren (2–4 h): von 457 LOC auf die ~24 echten Abweichungen (~40 LOC) — 180 Keys existieren im gepinnten DMS-Schema nicht mehr (tote Keys, werden bei jedem Start von der v21/v13/v16-Migration gelöscht), 172 sind exakte Upstream-Defaults. `configVersion = 5` (Zeile 454) streichen — DMS migriert intern bis Version 33, HM schreibt bei jedem Switch den Alt-Stand zurück = permanentes Churn-Ping-Pong + Doppel-Writer-Konflikt mit DMS-Runtime. Vorher `barConfigs`/`controlCenterWidgets`/`appIdSubstitutions`/`cursorSettings`/`powerMenuActions` gegen Upstream-Defaults diffen (nur echte Deltas behalten).
2. `dms.nix:41-64` mkForce-niri-Block löschen (1 h): Upstream erzeugt beim gepinnten Rev identische `config.kdl` inkl. Border-Fix und optional-Includes — der lokale Block reimplementiert nur. Vorher gerenderte `config.kdl` diffen (old vs. new).
3. dsearch-Entscheidung (0,5–1 h): `dms.nix:12` startet danksearch (Go-Indexer mit File-Watcher, dauerhaft ab Session-Start; Option kommt aus nixpkgs — KEIN Eval-Bruch, nur Runtime-Kosten). Runtime-Config lesen (welche Pfade indexiert?), auf Dokumente begrenzen oder auf `graphical-session.target` gaten oder deaktivieren, falls Launcher-Dateisuche ungenutzt.
4. Theming-SSOT erklären (1–2 h): DMS-matugen (themed Shell + ~20 Template-Ziele) als Single-Source-of-Truth; Stylix-Targets auf das reduzieren, was matugen nicht abdeckt; `qt-theme.nix` löschen (wirkungslos — Stylix-Plain-Assignment schlägt `mkDefault`). Vorher Stylix-Qt-Modul auf Priorität prüfen.
5. `programs.dsearch.enable`-Zeile bleibt (nixpkgs-Modul existiert — Desktop-Researcher-Verdacht Eval-Bruch ist damit entkräftet); aber Wirkung am Live-Host verifizieren.
6. Kleinreparaturen (0,5 h): niri.nix:15 polkit-Kommentar korrigieren („DMS ships its own polkit agent" — veralteter Wortlaut), tote gammastep-appConfig + geolocation-Aspekt entfernen (DMS enabled geoclue2 eh per Default), `services.journald`-Limit setzen (`SystemMaxUse=1G`, @log-Subvol ist persistent), thermald NACH Messung (Phase 0) ergänzen falls Throttling belegt, handy StartLimit setzen.
7. Optional nach Messung: Bar-Widgets (`cpuUsage`/`memUsage`) / Wetter-Widget differenziert probefahren; docker-`linger`-Entscheidung für Desktop-Host.

**Warum nach Phase 2:** dms-settings ist der größte Einzelballast der Wartbarkeit und hängt am empfindlichsten am DMS-Bump-Takt — der Reduktions-Diff muss gegen den GEPINNTEN Rev laufen, daher vor dem nächsten DMS-Bump und getrennt vom Export-Split (verschiedene Fehlerebenen).

**Verifikation:** DMS-Runtime-Änderungen (Settings-GUI) überleben den nächsten HM-Switch; DMS-Start-Journal zeigt keine 5→33-Migrationskette mehr; Idle-CPU-Messung vor/nach (dsearch, Bar-Widgets); gerenderte `config.kdl` identisch.

**Risiko + Gegenmaßnahme:** Reduktion ändert DMS-Verhalten an Rändern, wenn versehentlich ein LIVE-Key als Default gestrichen wird — Gegenmaßnahme: jede gestrichene Zeile gegen SPEC-Abgleich (die Auswertung existiert) und einmal optisch gegen die laufende DMS-GUI diffen. Reduktion NIEMALS im selben PR wie ein DMS-Input-Bump.

### Phase 4 — Struktur, Taxonomie & Options-API (ca. 4–8 h)

**Was:**
1. Namens-Hygiene-Sweep (1–2 h; Renames sind dank import-tree mechanisch gratis): `skills.nix`→`ai-tools.nix`; `k9s.nix` in `kubernetes.nix` mergen; `television-nix.nix`→`nix-search-tv.nix` mit Aspekt `homeManager.nix-search-tv` + `terminal.nix`-Import anpassen (löst die Granularitäts-Fusion zweier Programme auf einem Aspektnamen); `gpg.nix`→`gnupg.nix`+`gpg-agent.nix`; `yubikey.nix` splitten `yubikey`/`yubikey-pam`; Tier-Importlisten im selben Commit mitziehen (Aspect-Name-Änderungen ändern `flake.modules`-Keys).
2. Taxonomie-Fehlplatzierungen verschieben (1–2 h): `core/fonts.nix`→`desktop/`, `core/nix-ld.nix`→`development/`, `core/performance.nix`→`system/` (Aggregator-Imports mechanisch mitziehen). Struktur-Lüge auflösen: git-Familie (`vcs/git*.nix`) und `ai/llm-agents.nix` either zu `core/` moven (Aktivierungs-Realität: core.nix importiert sie) oder im core.nix-Kommentar als bewusste „Arbeitsplatz-Basis" deklarieren. `bootstrap.nix`-Überlappung als bewusste Installer-Minimalmenge dokumentieren. KEINE weiteren Moves — Tier≠Group-Divergenz ist Pattern-Normalzustand und wird im README dokumentiert (ein Absatz), nicht umgebaut.
3. Options-API dokumentieren (1–2 h): `description` für `core/users-profile.nix:3-8`, `parts/configuration.nix` (host/iso-Submodule), `dotnix.git.credentials`/`repositories` — Hausstandard siehe `tmux-bindings.nix`/`tmux-popups.nix` (dort vorbildlich inkl. Duplikat-Assertionen). `theme`-Option (users-profile.nix:7) konsumieren (stylix.nix:8/tuicr.nix:13 als Single Source) oder streichen.
4. Impermanence-/Audit-Konvention ins README (0,5 h): Inline-Contributions als dokumentierte Konvention + `grep -rn 'home.persistence' modules/`-Einzeiler.
5. disko-Eval-Entscheidung (0,5 h + Messung): disko kostet +7 s pro Host-Eval (größter messbarer Eval-Block, fällt bei jedem `nixos-rebuild` an). Option: disko aus dem `system`-Aggregator herausnehmen, Hosts importieren es explizit (semantische Änderung — Besitzerentscheidung; Gegenprobe: `time nixos-rebuild dry-activate` vor/nach). Alternativ: akzeptieren und dokumentieren.
6. ISO-Mechanismus (0,5 h): `buildOutput`-Default `"images.iso-installer"` zeigt auf einen Pfad, den kein Modul beider Repos bereitstellt; kein Konsument setzt `iso.enable`. Entweder Mechanismus entfernen oder erstmals real ausüben — Besitzerentscheidung.

**Warum nach Phase 2/3:** Aspekt-Renames ändern die öffentliche Key-Oberfläche (`flake.modules.*`) — nach dem Export-Split ist klar, welche Keys Vertrag sind, und die Fixture fängt falsch gezogene Importlisten. Taxonomie-Moves sind pure `git mv`s, aber sie vermischen sich schlecht mit Funktions-PRs — daher gebündelt in einem Struktur-PR.

**Verifikation:** Fixture + `nix flake check` grün (import-tree macht Moves eval-sicher); `grep`-Findbarkeit: jeder Aspekt unter seinem Namen auffindbar; Eval-Zeit vor/nach disko-Entscheidung gemessen.

**Risiko + Gegenmaßnahme:** Renames brechen Konsumenten, die alte Keys referenzieren — Prüfung: einzige bekannten Konsumenten (`.dotnix`: nur `wsl`, `devops` direkt) + Laptop-Repo (Phase 0 geklärt) verwenden keine der umbenannten Keys. Im Zweifel: alten Namen als Alias-Import leer weiterexistieren lassen (1 Zeile) oder im Breaking-Note-PR des Phase-2-Fensters ankündigen.

### Phase 5 — Lock- & Pipeline-Hygiene (ca. 3–6 h)

**Was:**
1. CI härten (2–3 h): GitHub-Actions auf Commit-SHAs pinnen (`@v3`/`@main` → SHA, insbesondere `update-flake-lock@main` — floating Action passt zeitlich zum Helix-Freeze-Beginn bei PR #18); Auto-Merge nur nach echtem Build-Gate (`nix build .#nixosConfigurations.<host>.config.system.build.toplevel` oder nix-fast-build) — sonst erscheinen Build-Brüche erst am Desktop; alternativ Auto-Merge streichen und manuell mergen.
2. Update-Kadenz halbieren (0,1 h): Cron `0 4 * * 1` → `0 4 1,15 * *` — der AvengeMedia-Stack (dms, dms-plugins, dank-greeter) hat KEINEN Binary-Cache (verifiziert; auch keiner konfigurierbar, da Upstream keinen anbietet), jede Welle = lokale Source-Rebuilds von Shell+Greeter+Plugins. Halbe Kadenz = halbe Rebuild-Frequenz + halbe Review-Last.
3. Follows selektiv (0,5–1 h): agenix-rekey-Dev-Kette kollabieren (`devshell`/`treefmt-nix`/`pre-commit-hooks` → Root-Inputs bzw. `git-hooks`; DevShell-only, nie im Modul-Pfad, risikoarm); `niri.inputs.nixpkgs-stable.follows = "nixpkgs"` + Kommentar (niri-stable ungenutzt, grep-verifiziert — killt Zweit-nixpkgs + wöchentlichen Churn). **NICHT tun:** Stylix/NUR-flake-parts-Upstream-Pins kollabieren und agenix-rekeys eigenes flake-parts auf Root zwingen — 24 Wellen eval-grün dagegen (Lock-Orakel-Urteil).
4. niri-Fork dokumentieren oder zurückrollen (0,2 h): `github:epireyn/niri-flake` (Fork, aktuell synced mit sodiboo) — Grund von Commit 417528f als Kommentar an flake.nix, oder zurück auf `sodiboo` (Fork als einzige Compositor-Quelle = Verfügbarkeitsrisiko).
5. dank-qml-common vereinheitlichen (0,5 h): Root-Input + follows für dms und dank-greeter — aktuell zwei divergierende Revs desselben QML-Fundaments in einem System (wandern wöchentlich getrennt auseinander).
6. Helix-Bot-Anomalie abhaken (0,25 h): falls Phase 1 den Input entfernt hat, entfällt das Thema; sonst `nix flake lock --update-input helix` manuell + Action pinnen (siehe 1).

**Warum zuletzt:** Lock-/Pipeline-Änderungen sind quer zu allem — sie sind am sichersten, wenn der funktionale Umbau abgeschlossen ist und der nächste Wellen-Zyklus die neue Pipeline erstmals unter Realbedingungen fährt.

**Verifikation:** Nächste Lock-Welle: kleinerer Diff (nur rollierende Inputs), Auto-Merge nur nach Build-Gate, Lock ohne nixpkgs-stable-Churn; `nix flake check` grün; rekey-Dry-Run grün (nach Follows-Änderung).

**Risiko + Gegenmaßnahme:** Follows-Overrides sind die einzige Stelle, wo dieser Plan Upstream-Pins überstimmt — auf die Dev-Kette beschränkt (bewertet risikoarm), Bibliotheks-Pins bleiben. Build-Gate verlängert CI-Laufzeit — mit nix-fast-build oder eval-only-Fallback für PRs außerhalb der Welle handhabbar.

## Verbotene Gleichzeitigkeiten (Wechselwirkungen)

1. **expose.nix-Split × Konsumenten-Lock-Bump:** nie beides gleichzeitig in flight — sonst ist ein Bruch nicht zuordenbar. Reihenfolge: Split landen lassen → Konsumenten-Pin bewusst updaten (Phase 2).
2. **dms-settings-Reduktion × DMS/dms-plugins-Input-Bump:** die Reduktion wird gegen den GEPINNTEN Rev gedifft; ein Bump im selben PR ändert das Schema unter den Händen. Struktur-PRs generell nicht in der Montags-Wellen-Woche landen (Phase 0: Auto-Merge aus).
3. **Aspekt-Renames (Phase 4) × Export-Split (Phase 2):** beide verändern die öffentliche Key-Oberfläche. Nacheinander, jeder mit eigener Fixture-Grün-Phase.
4. **Taxonomie-Moves × Tier-Importlisten-Änderungen:** nur im selben Commit — ein `git mv` ohne Importlisten-Update lässt den Aspekt still verschwinden (import-tree folgt Dateien, Tier-Listen folgen Namen; benannte Imports bleiben von Moves unberührt, Namens-Änderungen nicht).
5. **flake-parts/nixpkgs-Follows-Änderungen × Rekey-Operationen:** nach jeder Follows-Änderung einmal `nix run .#rekey`-Dry-Run — agenix-rekey ist der einzige Konsument des alten flake-parts im Eval-Pfad.
6. **Helix-Input-Entfernung × LSP-Konsolidierung:** gleiche Subsysteme, verschiedene Dateien — in EINEM Rebuild verifizieren, nicht in zwei halbfertigen Zuständen live testen.
7. **Host-seitige Änderungen (resume_offset) × Bibliotheks-Impermanence-Änderungen:** verschiedene Repos, aber derselbe Boot-Pfad — nicht am selben Tag switchen; Library zuerst auf Konsumenten-Pin bringen, dann Host-Fix fahren.
8. **`M modules/aspects/term/shell-ux/sesh.nix`** (uncommittete User-Arbeit): in keinem Phase-PR berühren; vorher einbinden oder separat landen lassen.
9. **dsearch-Deaktivierung × DMS-Settings-Reduktion:** nicht gleichzeitig — wenn die Launcher-Suche bricht, muss eindeutig sein, welche Änderung es verursacht hat.

## Quick Wins (unabhängig vom Plan, sofort safe)

1. `debug = mkDefault true` streichen — `modules/parts/flake-parts.nix:5`, eine Zeile, spart Eval-Kosten bei jedem `nix flake show`/outputs-Walk des Konsumenten.
2. fastfetch-TMUX-Guard — `modules/aspects/term/monitoring/fastfetch.nix:25`, `body = "if not set -q TMUX; fastfetch; end"`, eliminiert die spürbarste Terminal-Latenz (jedes Pane/Popup).
3. Ghostty `custom-shader-animation = false` (+ `background-blur`-Entscheidung) — `desktop/terminal/ghostty.nix:16-22`, stoppt permanente GPU-Render-Loop jedes sichtbaren Terminals.
4. `batteryProfileName = "balanced"` — `dms-settings.nix:209`, behebt zähes UI im Akkubetrieb (oder bewusst als `"power-saver"` dokumentieren).
5. `resume_offset` host-seitig setzen — Konsumenten-Repo, verhindert stillen Session-Verlust beim ersten Deckel-Hibernate des Ziel-Laptops.
6. `hostname`-Options-Typ fixen — `parts/configuration.nix:33`, `nullOr str` oder Default streichen (latenter Eval-Fehler).
7. Tote Aspekte löschen — `yubikey-lock.nix`, `tuigreet.nix`, `boot-limine.nix`, `bash.nix` (Null-Verhalten, Null-Referenzen, verifiziert).
8. Toter follows-Override weg — `flake.nix:6` (`agenix.inputs.home-manager.follows` — agenix hat den Input entfernt, jede Eval printed eine Warning).
9. `narinfo-cache-negative-ttl` 30 s → 3600 s — `core/nix.nix:30`, halbiert wiederholte Substituter-Anfragen bei Misses.
10. journald-Limit — `services.journald.settings.SystemMaxUse = "1G"`, eine Zeile gegen unbegrenzte Log-Ausbreitung auf dem persistenten @log-Subvol.
11. CI-Kommentar korrigieren — `flake-check.yml:26-27` behauptet Hook-Coverage, die CI nie liefert (verhindert falsche Sicherheit, gratis).
12. Toter Firefox-Pref ersetzen/löschen — `firefox.nix:70` `media.autoplay.enabled` (seit ~FF41 wirkungslos).

## Aufwand

| Phase | Inhalt | Aufwand | Kumuliert |
|---|---|---|---|
| 0 | Klärung, Fixture, Baseline, Auto-Merge aus | 4–8 h | 4–8 h |
| 1 | Template/README/debug, Helix raus, LSP, Latenz-Quick-Wins, toter Code, resume_offset | 8–12 h | 12–20 h |
| 2 | expose-Split, Konsumenten-Migration, age-rekey-Entkopplung | 4–8 h | 16–28 h |
| 3 | dms-settings-Reduktion, mkForce-Block weg, dsearch, Theming-SSOT | 6–12 h | 22–40 h |
| 4 | Naming-Sweep, Taxonomie, Options-Doku, disko-Entscheidung | 4–8 h | 26–48 h |
| 5 | CI-Härtung, Kadenz, selektive Follows, Fork, qml-common | 3–6 h | 29–54 h |

Gesamt: ca. 29–54 h (≈ 4–7 Arbeitstage verteilt über mehrere Wochen; Phasen 1 und 3 enthalten Besitzer-Entscheidungen, die die reine Umsetzungszeit nicht verlängern, aber Kalenderzeit brauchen). Empfohlene PR-Granularität: Phase 1 als 2 PRs (Vertrag/Artefakte vs. Perf-Quick-Wins), Phase 2 als 1 koordinierter PR + Konsumenten-Commit, Phase 3 als 2 PRs (dms-settings vs. Rest), Phase 4 als 1 Struktur-PR, Phase 5 als 1 Pipeline-PR.

## Risiken und Unbekannte des Gesamtplans

- **Laptop-Konsument ungeklärt (Phase 0.1):** Bis zur Klärung sind alle Desktop-Runtime-Wirkungen (Phase 1.6, Phase 3) Bibliotheks-Aussagen — ob sie am gefahrenen Desktop ankommen, entscheidet der dortige Pin (`.dotnix`-WSL-Pin ist selbst 8 Commits hinter HEAD, pre-Cleanup).
- **Magnituden ungemessen:** `debug`-Kosten, fastfetch-Latenz (50–300 ms Schätzung), dsearch-Last sind statisch belegt, nicht gemessen — Phase 0.4 (Baseline) und die je-Aktionen-Verifikation schließen das.
- **Besitzer-Entscheidungen im Plan:** batteryProfileName, LSP-Auswahl, difftastic (Veto vor Streichen), Helix master-Feature-Bedarf, disko aus system-Tier, ISO-Mechanismus, Fork-Begründung — je 30-Sekunden-Fragen, die in den Phasen explicitly markiert sind.
- **Template-Eval-Bruch ist statisch bewiesen, nicht evaluiert** (nix-Kommandos waren der Recherche verboten) — die Fixture liefert den Beweis gratis mit.
- **Keine nix-Kommandos seitens des Orakels:** Alle „führe aus"-Schritte (nix flake check, rekey-Dry-Run, Messungen) sind Owner-Aktionen; der Plan nennt sie als Verifikations-Kriterien.
