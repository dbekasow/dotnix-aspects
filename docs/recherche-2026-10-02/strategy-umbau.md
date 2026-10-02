# Strategie B — Umbau: Dendritische Disziplin-Reparatur statt Neubau

Basis: 10 Forschungsberichte + 6 Orakel-Gutachten aus `/tmp/dotnix-research/`; alle im Papier zitierten Befunde am Repo HEAD `ac7724c` (Branch `main`) stichprobenartig verifiziert. Maßstab: `dendritic-nix`-Skill. Konsumenten-Realität: sichtbar nur WSL-Host `dmi` (`.dotnix`, Pin 8 Commits hinter HEAD, pre-Cleanup); sehr wahrscheinlich existiert ein unsichtbarer Laptop-Konsument (frische Desktop-Commits, `dell-precision-5570`-Hardwaremodul), der die `desktop`-Ast-Konfiguration tatsächlich fährt.

## Pitch

Das Repo braucht keine neue Architektur — die dendritische Mechanik ist konform (unabhängig verifiziert: keine konditionalen Imports, Klassendisziplin intakt, Collector/Constants korrekt). Gebrochen ist die Ausführungsdisziplin: Der öffentliche Vertrag evaluiert nicht (Template-Case-Bug + fehlendes `core`), das README beschreibt Phantom-Dateien, die Bibliothek injiziert Dev-Tooling samt `debug = true` in jeden Konsumenten, sechs Aspekt-Namen lügen (Datei≠Aspekt≠Programm), und `dms-settings.nix` spiegelt 457 Zeilen fremdes DMS-Schema mit eingefrorener `configVersion = 5`. Der Umbau repariert das in vier verifizierbaren Phasen: Vertrag + CI-Fixture, Export-Split, Namens-/Ortshygiene, Schema-Snapshot-Kuration. Ergebnis: Dateinamen werden wieder zuverlässige Dokumentation, Onboarding funktioniert, jeder `nix`-Befehl im Konsumenten wird schneller — die Runtime-Trägheit des Desktops bleibt inhaltlich und wird durch saubere Struktur erst richtig anwendbar.

## Befundlage (Warum Umbau, nicht Neubau)

1. **Pattern-Mechanik hält** (Orakel-Konsens, independently verified): Granularität ist genau richtig (1 Tool = 1 Datei = 1 Aspekt in der großen Mehrzahl); Mischmodell User=Feature / Host=Registry ist eine tragfähige, bewusste Bibliotheks-Erweiterung. Ein Paradigmenwechsel wäre Geldverbrennung.
2. **Der öffentliche Vertrag ist gebrochen** (verifiziert): `templates/dotnix/modules/hosts/myHost/configuration.nix:11` setzt `members = [ "myUser" ]`, aber `templates/dotnix/modules/users/myUser/default.nix:2` definiert `user = "myuser"` → `attrVals`-Fehler in `modules/parts/configuration.nix:40`; Host-Liste (`configuration.nix:4-8`) enthält kein `core` → `home-manager.users.*` existiert nicht (einziges HM-NixOS-Modul: `modules/aspects/core/home-manager.nix`). README (`README.md:21,46`) referenziert `modules/options.nix`/`factories.nix` — beide existieren nicht. Root Cause des Verrottens: CI evaluiert nie eine Konsumenten-Instanz (`.github/workflows/flake-check.yml` prüft nur die Bibliothek), der `flake.flakeModule`-Export-Vertrag ist ungetestet.
3. **Schnittstelle verschmiert** (verifiziert): `modules/expose.nix:16-23` exportiert Aspekte **und** komplette `parts/` — jeder Konsument erbt devshell (16 Pakete), treefmt/`formatter`, pre-commit-Hooks, `flake.templates.default` und `debug = mkDefault true` (`modules/parts/flake-parts.nix:5`), das flake-parts zur Evaluation eines Introspektions-Spiegels der gesamten Konsumenten-Config zwingt (Eval-Kosten auf jedem `nix`-Befehl, ungemessen, aber mechanismisch belegt).
4. **Namen und Orte divergieren** (verifiziert): 6 echte Name≠Datei-Verstöße (`skills.nix`→`ai-tools`, `k9s.nix`→`kubernetes`, `gpg.nix`→`gnupg`+`gpg-agent`, `yubikey.nix`→`yubikey`+`yubikey-pam`, `television-nix.nix`→`television` konfiguriert `programs.nix-search-tv`, `tuigreet.nix`→`tui-greeter`); zusätzlich wohnt `core/fonts.nix` im Desktop-Tier, `core/performance.nix` im System-Tier, `core/nix-ld.nix` im Development-Tier. 3 Module sind von niemandem erreichbar: `core/yubikey-lock.nix`, `desktop/greeter/tuigreet.nix`, `system/boot-limine.nix` (Referenz-Grep: null Treffer außerhalb der eigenen Datei).
5. **Schema-Snapshot-Brechen**: `desktop/shell/dms-settings.nix` (457 LOC, `configVersion = 5` in :454) ist zu ~92 % Upstream-Default-Klon; DMS migriert intern bis v33, HM schreibt bei jedem Switch den Alt-Stand zurück (Doppel-Writer-Ping-Pong, Migrationskette bei jedem Shell-Start). `desktop/shell/qt-theme.nix` ist nachweislich wirkungslos (Stylix-Priorität gewinnt). `desktop/shell/dms.nix:12` setzt `programs.dsearch.enable = true` — Option existiert in keinem gepinnten Input (Eval-Bruch-Verdacht).
6. **Latente Typ-/Mechanismus-Fehler**: `modules/parts/configuration.nix:33` `type = str; default = null`; ISO-Mechanismus (`iso.buildOutput`-Default `"images.iso-installer"`) zeigt auf einen Pfad, den kein Modul definiert; `boot.zfs.forceImportRoot` doppelt gesetzt (`system/boot.nix:22` hart + `configuration.nix:46` weich).

## Schritte

### Phase 0 — Rahmen klären + Baseline sichern (0,5 Tag)

Kein Repo-Commit; Voraussetzung für alles Desktop-Berührende.

1. **Laptop-Konsumenten identifizieren**: Flake-Quelle des Desktop-Hosts klären (Clone auf dem Laptop / Azure-Branch), aktuellen Aspects-Pin dort feststellen. Ohne dies laufen Phase-4-Verifikationen ins Leere (Orakel-Dead-Dupes, Prio 1).
2. **Baseline messen** (nix erlaubt ab hier für den Ausführer): `nix flake check`, `nix flake show`, `nix eval .#nixosConfigurations...` in Bibliothek **und** Live-Konsument (`/home/denis/repositories/private/.dotnix`), Zeiten notieren — Vergleichszahlen für Phase 2/4.
3. **Pin-Gap schließen**: uncommittete `M flake.lock` im Konsumenten committen; Lock-Update bewusst erst **nach** Phase 2 planen.

### Phase 1 — Öffentlichen Vertrag reparieren + Verrottungs-Root-Cause abschalten (0,5 Tag)

Ziel: Template evaluiert, README sagt die Wahrheit, CI testet den Export-Vertrag ab sofort.

1. `templates/dotnix/modules/hosts/myHost/configuration.nix`: `members = [ "myuser" ]` (Case-Fix) **und** `core` in die `modules`-Liste aufnehmen (analog Live-Host `dmi`: `[ core ... ]`) — sonst existiert `home-manager.users` nicht.
2. `templates/dotnix/modules/users/myUser/default.nix`: bleibt konsistent (Name klein); optional Verzeichnis `myUser/` → `myuser/` für 1:1 (Template ist frische Flake, Rename gratis).
3. `README.md`: Phantom-Referenzen (:21, :46) ersetzen durch Realität — Registry/Factory = `modules/parts/configuration.nix`, Export = `modules/expose.nix`; „injecting core automatically"-Aussage (:46) streichen. Neu dokumentieren: (a) Host-Registry-Schema (`dotnix.<host>.{modules,members,iso}`), User-as-Feature-Story; (b) Layout-Kontrakt: `modules/hosts/<host>/secrets/*.pub`, `modules/hosts/<host>/certificates/`, `modules/users/<user>/secrets/home-key.pub`, Consumer-Wurzel `yubikey.pub`/`masterkey.age` (heute undokumentiert, eval-perf belegt den Crash); (c) Tier-vs-Gruppe-Absatz: Tier-Dateien an `modules/aspects/{core,system,desktop,terminal,development,bootstrap}.nix` sind die verbindlichen Kompositionslayer, Gruppen (`core/`, `term/`, …) sind Fachdomänen-Regale — Namensgleichheit ist Zufall; (d) Impermanence-Audit-Einzeiler `grep -rn 'home.persistence' modules/`; (e) `dotnix`-Namespace-Bedeutungen (4 Ebenen, nie im selben Kontext).
4. `.github/workflows/flake-check.yml`: neuen Job „consumer-fixture": `nix flake new /tmp/fixture -t .#dotnix` → `nix eval /tmp/fixture#nixosConfigurations.myHost.config.system.build.toplevel.drvPath` (dry-eval, kein Build). Falschen „covers:"-Kommentar (:26-27, Hooks laufen nur lokal via prek) entfernen. **Das ist der strukturelle Riegel gegen jede künftige Drift.**
5. Beipack (je 1 Zeile): `modules/parts/configuration.nix:33` → `types.nullOr str` (oder Default streichen); ISO-Submodule + `perSystem.packages`-Block entfernen (Pfad `images.iso-installer` existiert nirgends, `iso.enable` wird nie gesetzt); `modules/aspects/system/boot.nix:22` streichen (global via `configuration.nix:46` abgedeckt).

Verifikation: Fixture-Job grün; `nix flake check` Bibliothek grün; Template-Kopie von Hand einmal instantiieren und evaluieren.

### Phase 2 — Export-Schnittstelle verschmälern: Aspekt-Bibliothek ≠ Dev-Tooling-Lieferant (0,5 Tag)

1. `modules/expose.nix`: `(i: i.addPath "${modules}/parts")` ersetzen durch explizite Dateiliste der konsumenten-pflichtigen Parts: `parts/flake-parts.nix`, `parts/configuration.nix`, `parts/age.nix` (+ `parts/home-manager.nix`, sofern der Fixture-Job ihn braucht — konservativ drinlassen). Dev-Tooling (`parts/{devshell,treefmt,pre-commit,templates}.nix`) bleibt ausschließlich in der Library-Eigen-Evaluation (`flake.nix` import-tree lädt weiterhin alles).
2. `modules/parts/flake-parts.nix:5`: `debug = lib.mkDefault true;` streichen (Upstream-Default `false`; wer Introspektion will, setzt es im eigenen Repo — Prioritätsarithmetik erlaubt ohnehin ein schlichtes `debug = false`).
3. Dev-Tooling als Opt-in verfügbar halten: separater Export (z. B. `flake.flakeModules.devTools`-Alias) statt nur Löschen — schützt unsichtbare Konsumenten, die die Devshell/Formatter evtl. nutzen.
4. Nach Landung: `flake.lock` im Live-Konsumenten updaten (bringt Cleanup-Commit `8b408a9` + Split zum WSL-Host; Pin-Gap aktuell 8 Commits).

Verifikation: Fixture-Job grün; `nix flake show` im Konsumenten zeigt keinen devshell/formatter/templates-Output mehr; grep über `modules/aspects/` nach `inputs.`-Verbrauchern, die nur entfernte Parts registrieren (insbesondere agenix-rekey); Eval-Zeit Vergleich Baseline.

### Phase 3 — Namens- und Ortshygiene: one feature = one name (0,5–1 Tag)

Renames und Moves sind dank import-tree mechanisch gratis („File names are documentation, not mechanism") — nur Tier-Importlisten im selben Commit anpassen.

1. **Renames/Splits** (Aspektname = Dateiname = Programm):
   - `modules/aspects/development/ai/skills.nix` → `ai-tools.nix`
   - `modules/aspects/development/devops/k9s.nix` → `kubernetes.nix`
   - `modules/aspects/term/secrets/gpg.nix` → splitten in `gnupg.nix` + `gpg-agent.nix`
   - `modules/aspects/core/yubikey.nix` → splitten in `yubikey.nix` + `yubikey-pam.nix`
   - `modules/aspects/term/monitoring/television-nix.nix` → `nix-search-tv.nix` mit eigenem Aspekt `homeManager.nix-search-tv`; `terminal.nix`-Importliste ergänzen — löst die Fusion zweier verschiedener Programme (`television` vs. `nix-search-tv`) unter einem Aspektnamen, die aktuell die Tier immer gemeinsam zieht.
2. **Ortshygiene** (nur eindeutige Fehlplatzierungen; Aggregatoren referenzieren nach Name): `core/fonts.nix` → `modules/aspects/desktop/` (Desktop-Tier-Import), `core/nix-ld.nix` → `modules/aspects/development/` (Development-Tier-Import), `core/performance.nix` → `modules/aspects/system/` (System-Tier-Import). **Nicht** verschieben: `fish`, `git`, `llm-agents` — fachlich korrekt in `term/`/`development/` platziert und Core-Tier-Mitglieder; Tier-Quer-Schnitt ist dokumentierter Normalzustand (Phase-1-README-Absatz).
3. **Tote Module löschen** (Referenz-Grep verifiziert: null Treffer außerhalb der eigenen Datei): `modules/aspects/core/yubikey-lock.nix`, `modules/aspects/desktop/greeter/tuigreet.nix`, `modules/aspects/system/boot-limine.nix`. Git-Historie konserviert sie; README-Notiz „Alternativen entfernt — siehe Historie". Falls der Owner sie als wählbare Bibliotheks-Exporte will: stattdessen README-Abschnitt „Alternativen" (boot-limine, tui-greeter, yubikey-lock) mit Hinweis, dass `system`-Tier `boot-systemd` pinnt.
4. Optional kosmetisch: `desktop/shell/` → `desktop/dms-shell/` (Namensdopplung mit `term/shell/` = Login-Shells).

Verifikation: Fixture-Job + `nix flake check` grün; Namens-Konsistenz-Grep (jede Datei `<X>.nix` definiert `flake.modules.<class>.<X>` bzw. dokumentierte Feature-Splits); Konsumenten-Grep auf umbenannte Aspektnamen (`television`, direkt importiert?) vor dem Rename-Commit.

### Phase 4 — Schema-Snapshot kuratieren (0,5 Tag + Owner-Entscheidungen)

Voraussetzung: Phase 0 (echter Desktop-Konsument bekannt), sonst Verifikation unmöglich.

1. `modules/aspects/desktop/shell/dms-settings.nix` (457 LOC → ~40): auf echte Deltas reduzieren (~24 skalare Abweichungen; `barConfigs`, `appIdSubstitutions`, `cursorSettings`, `controlCenterWidgets`, `powerMenuActions` vorher gegen gepinnten Upstream-Rev diffen); `configVersion = 5` streichen (DMS verwaltet und migriert selbst — intern bis v33); `mkDefault`-Wraps (:8-9) entfernen (kein zweiter Writer mehr). Killt die Migrationskette bei jedem DMS-Start und den HM-vs-DMS-Rücksetz-Loop.
2. `modules/aspects/desktop/shell/qt-theme.nix` löschen — nachweislich wirkungslos (Stylix-Plain-Assignment gewinnt gegen `mkDefault`); stattdessen eine Theming-SSOT-Entscheidung dokumentieren (DMS-matugen vs. Stylix-Targets gezielt deaktivieren — Owner-Entscheid).
3. `modules/aspects/desktop/shell/dms.nix:12`: `nix eval` prüfen, ob `programs.dsearch` irgendwo existiert — nein (Befund): Zeile löschen (Eval-Bruch präventiv). `dms.nix:41-64`: gerenderte niri-`config.kdl` alt/neu diffen; bei Identität den `lib.mkForce`-Hack-Block löschen (Upstream generiert die Config inzwischen korrekt inkl. Border-Fix).

Verifikation: gerenderte `settings.json` vor/nach am echten Desktop diffen (nur erwartete Deltas, Owner-Review); DMS-Start ohne Migrationslog; HM-Switch ohne DMS-Restart-Reset; `config.kdl`-Diff leer.

### Phase 5 — Anbau (Riders, 0,5–1 Tag; teils Heimat in anderen Richtungen)

Nur wenn Phase 1–4 grün: helix-Eigen-Input streichen (9 Wochen stale, Zweck „master" läuft ins Leere), LSP-Doppelung auflösen (nixd+nil, marksman+markdown-oxide), agenix-rekey-Dev-Kette via follows kollabieren, Update-Kadenz auf 2 Wochen, Build-Gate vor Lock-Auto-Merge, Ghostty-Shader-Animation/power-saver/dsearch-Daemon (Runtime-Hebel, inhaltlich). Struktur hat diese Hebel durch kleine, ehrlich benannte Dateien erst greifbar gemacht.

### Bewusst NICHT getan (Anti-Umbau, damit der Umbau klein bleibt)

- **Host-Registry → Host-Features-Migration**: nein. Die Registry ist die Factory-Seite des Patterns, trägt die members-getriebene Secrets-Generierung; Migration = Breaking Change ohne Bedarf. Die Case-Bug-Klasse stirbt am CI-Fixture (Phase 1) für ein Hundertstel des Aufwands.
- **Impermanence in Collector-Dateien reorganisieren**: nein. Inline (22× `homeManager.impermanence`) ist für Entfernbarkeit besser (App löschen = Persistenz-Spur weg); dokumentierter Audit-Einzeiler statt 22 Zusatzdateien.
- **Gruppen komplett an Tiers angleichen**: nein — zerstört die Fachdomänen-Ordnung (`fish` bleibt `term/shell`, egal welches Tier ihn importiert). Nur die 3 unklaren Fehlplatzierungen wandern (Phase 3.2).
- **Granularität weiter splitten**: nein. 1 Tool = 1 Datei ist genau richtig; einzige echte Granularitäts-Störung (television-Fusion) wird aufgelöst, nicht mehr Dateien erzeugt.
- **Neuarchitektur/Patternewechsel**: nein. Mechanik ist konform; alles Reibende ist Disziplin im Kleinen — Stunden, nicht Wochen.

## Risiken + Gegenmaßnahmen

1. **Unsichtbarer Laptop-Konsument (höchstes Risiko)**: Sehr wahrscheinlich fährt ein Desktop-Konsument einen Stand/Pin außerhalb des Sichtbaren (frische Desktop-Commits, Dell-5570-Modul). Der Export-Split (Phase 2) könnte dessen Workflow brechen, falls er die geerbte Devshell/den Formatter nutzt. Gegenmaßnahme: Phase-0-Klärung zwingend vor Phase-2-Merge; Dev-Tooling als Opt-in-Export (`flakeModules.devTools`) bereitstellen statt nur entfernen; Laptop-Repo greppen vor Merge.
2. **Erwartungsdelta Performance**: Struktur-Phasen machen `nix`-Befehle schneller (debug-Introspektion weg, weniger Modul-Merge im Konsumenten), aber **nicht** den laufenden Desktop flink. Gemessene Scaffolding-Kosten sind klein (import-tree + flake-parts: 0,15–0,5 s; +0,3 s Consumer-Wrapping) — ehrlich: spürbar bei jedem Befehl, kein Quantensprung. Die Runtime-Hebel (Ghostty-Shader, `batteryProfileName = "power-saver"`, dsearch-Daemon, DMS-Polling, fastfetch pro Pane) sind inhaltsseitig (Rider/andere Richtung). Gegenmaßnahme: Erwartung explizit setzen (dieses Papier, Pitch).
3. **Delta-Verlust bei dms-settings-Reduktion**: Ein bewusst gesetzter Wert könnte als Upstream-Default fliegen. Gegenmaßnahme: maschineller Diff der gerenderten `settings.json` am Live-Desktop, Owner-Approval des Diffs, Rollback = ein Revert-Commit.
4. **Aspect-Rename `nix-search-tv`**: Konsumenten, die `homeManager.television` direkt importieren (statt über `terminal`-Tier), verlieren den nix-search-Teil still. Gegenmaßnahme: Konsumenten-Grep vor dem Commit; Tier-Liste im selben Commit nachziehen; Fixture deckt den Template-Pfad ab.
5. **Debug-Verlust**: `debug = false` nimmt `flake.debug`-Introspektion im Konsumenten. Gegenmaßnahme: im eigenen Konsumenten-Repo setzbar (Priorität 100 schlägt entfernten Default gar nicht mehr — Zeile ist weg); Dokusatz im README.
6. **CI-Kosten**: Fixture-Job addiert ~10 s Eval pro Push (volle Template-Host-Eval 9–12 s gemessen). Akzeptabel; nötigenfalls nur bei PRs laufen lassen.
7. **disko-Eval-Block bleibt**: +7 s pro Host-Eval durch `disko` in der `system`-Tier sind ein Aktivierungs-/Inhaltsentscheid (Layout soll ja hin), kein Strukturfehler — wird hier bewusst nicht angefasst; dokumentiert als Owner-Entscheidung (opt-in pro Host wäre der Hebel).

## Aufwandsschätzung

| Phase | Inhalt | Aufwand |
|---|---|---|
| 0 | Konsumenten-Klärung + Baseline | 0,5 Tag |
| 1 | Template + README + CI-Fixture + Beipack | 0,5 Tag |
| 2 | Export-Split + debug + Lock-Update Konsument | 0,5 Tag |
| 3 | Renames/Splits/Moves + tote Module | 0,5–1 Tag |
| 4 | dms-settings + qt-theme + dsearch + niri-Hack | 0,5 Tag + Entscheidungen |
| 5 | Riders (optional) | 0,5–1 Tag |

**Kernumbau (Phase 0–4): ~2,5–3 Personentage** inkl. Verifikation; mit Ridern 3,5–4 Tage. Jede Phase landet einzeln grün (Fixture-Gate), jederzeit revertierbar; kein Big-Bang, keine Merge-Konflikte mit laufendem Betrieb (Live-WSL-Host fährt ohnehin einen 8-Commits-alten Pin).

## Erwartete Wirkung (ehrlich je Dimension)

| Dimension | Wirkung | Begründung |
|---|---|---|
| **Struktur** | **hoch** | Name=Datei=Aspekt wird 1:1 (6 echte Verstöße beseitigt, television-Fusion aufgelöst); Template/README wahrheitsgemäß; Export sauber getrennt (Bibliothek liefert keine Devshell mehr); 3 tote Module weg; Tier/Gruppe-Semantik + Layout-Kontrakt dokumentiert. Suche per Dateiname wird wieder zuverlässig — das ist der Kern der „wo gehört das hin?"-Klage. |
| **Wartbarkeit** | **hoch** | CI-Fixture schließt den Verrottungs-Root-Cause (Export-Vertrag wird ab sofort getestet — der Template-Bruch hätte ihn sofort gefangen); `dms-settings.nix` 457→~40 LOC eliminiert den größten Einzelposten (kein Schema-Diff je DMS-Bump, kein Doppel-Writer, keine Migrationskette); keine Phantom-Doku mehr; echte Deltas sind in 40 LOC reviewbar. |
| **Performance-Trägheit** | **Eval: mittel / Runtime-Desktop: gering (direkt)** | Eval-seitig: `debug`-Introspektion + Tooling-Parts aus jedem Konsumenten-`nix`-Befehl; mechanismisch belegt, in der Größenordnung ehrlich klein (Scaffolding gesamt ~0,5–1 s) — spürbar bei jedem rebuild/switch, kein Wundermittel. Runtime-seitig: Phase 4 killt die DMS-Start-Migrationskette (5→33) + den Rücksetz-Loop — echter, aber kleiner Startgewinn; die dominanten Trägheitsursachen (Ghostty-Shader-Loop, Akku-`power-saver`, dsearch-Dauerindexer, DMS-3-s-Polling, fastfetch je Pane) sind **inhaltlich**, nicht strukturell, und werden nur als Rider adressiert. Struktur macht sie durch kleine, ehrlich benannte Dateien erst sauber anwendbar. |

**Konfidenz**: Befundlage hoch (statisch verifiziert, Doppel-Prüfung durch Orakel); Eval-Magnitude mittel (debug-Kosten ungemessen, Richtung mechanismisch belegt); Desktop-_runtime-Zuordnung provisorisch bis der Laptop-Konsument bekannt ist (Phase 0).
