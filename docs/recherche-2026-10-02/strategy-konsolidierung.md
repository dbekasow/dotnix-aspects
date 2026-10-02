# Strategie C — Substrat-Konsolidierung (.dotnix-aspects)

Richtung: Flächenlast der Inputs/Pins/Vendor-Flakes reduzieren, Update-Bot/Pipeline reparieren, nixpkgs-Kanal-Strategie disziplinieren. Struktur nur so weit anfassen, wie die Konsolidierung es erfordert.

Stichprobenverifikation am Repo (2026-10-02, read-only): flake.nix (helix:36-37, niri-Fork:52, tote agenix-Override-Flagge:5), flake.lock via jq (58 Nodes, helix `079a789` = 2026-07-23, nixpkgs ×2 = `3181085`/`cf5e765`, dank-qml-common ×2 = `a88b16e`/`660b044`), .github/workflows (Cron, @main-Floating, Auto-Merge), modules/aspects/development/editors/helix.nix, modules/parts/flake-parts.nix (`debug = mkDefault true`), modules/aspects/desktop/shell/dms.nix:12 (`dsearch`), grep Stable-Schiene (0 Referenzen), Consumer-Pin `.dotnix` (`0c33875`, 2026-09-15, 8 Commits hinter HEAD). Alle Zahlen im Papier daraus oder aus den Forschungsberichten mit Orakel-Widerlegung gewichtet.

## Pitch

Das Substrat ist überladen und seine Pflegeautomatik defekt: 58 Lock-Nodes, 21 Inputs, ein persönlicher niri-Fork als Compositor-Quelle, eine ungenutzte Stable-Schiene mit zweiter nixpkgs-Instanz, divergierende dank-qml-common-Revs in Shell und Greeter — und ein Wochentakt-Bot, der helix seit 9 Wellen unbemerkt eingefroren lässt und nur eval-geprüfte Wellen per Auto-Merge ins main flutet (22 der 186 Commits sind Update-Merges). Konsolidierung statt Umbau: helix-Eigen-Input streichen, Pipeline pinnen und mit echtem Build-Gate versehen, Kadenz halbieren, gezielte follows kollabieren Dev-Doppel-Toolchain und Stable-Schiene, dank-qml-common vereinheitlichen, Fork zurückrollen. Ergebnis: eine nixpkgs-Instanz, ~46 Nodes, halb so große, vertrauenswürdige Update-Wellen — bei unangetasteter Aspekt-Struktur.

## Schritte

### Phase 0 — Klärung (Besitzer, vor jedem Griff)

1. **Laptop-Konsument identifizieren.** Der trägen Desktop-Konfiguration fehlt in beiden sichtbaren Repos der Konsument: `.dotnix` führt historisch nur Host `dmi` (WSL2, `modules = [ core wsl development ]`), das Template zielt auf `dell-precision-5570`; gleichzeitig belegen frische Desktop-Commits (Performance-Tuning 2026-09-11, Greeter-Persistenz) einen Live-Betrieb außerhalb des Horizonts (oracle-dead-dupes). Substrat-Fixes wirken auf den Desktop erst über dessen Lock-Update — ohne Klärung läuft die Wirkung ins Leere.
2. **Eine nix-Lauf-Diagnose (Owner auszuführen):** `nix flake lock --update-input helix` lokal, Rev-Sprung bewusst reviewen und committen. Klärt in einer Minute, ob Nix selbst den Move verweigert oder nur die Bot-Action (oracle-lock-hygiene N1).

### Phase 1 — Update-Pipeline reparieren (Vertrauen vor Diät)

1. **Actions pinnen.** `.github/workflows/flake-update.yml:22`: `DeterminateSystems/update-flake-lock@main` → feste Version bzw. Commit-SHA; ebenso `flake-checker-action@main` (`.github/workflows/flake-check.yml`) und `determinate-nix-action@v3`. Das @main-Floating ist der zeitliche Hauptverdächtige des helix-Freezes (Beginn mit erster Welle nach dem Floating, PR #18, 2026-08-03; helix seither 9 Wellen auf `079a789`/2026-07-23 eingefroren, obwohl Upstream täglich aktiv und die URL ungepinnt — flake.nix:36-37).
2. **Echtes Gate vor Auto-Merge.** `flake-check.yml` um eine Consumer-Fixture ergänzen: Template instantiieren (`nix flake new -t .#dotnix`) und `nixosConfigurations.myHost.config.system.build.toplevel.drvPath` evaluieren (besser: `nix build`) — das aktuelles Gate (`nix flake check`) evaluiert nur und baut keine Closures, Build-Brüche erscheinen sonst erstmals beim `nixos-rebuild switch` auf dem Desktop. Minimal-Alternative: Auto-Merge (`flake-update.yml:33-36`) streichen und PRs manuell mergen. Nebenbei den falschen CI-Kommentar korrigieren (`flake-check.yml:26-27` behauptet Hook-Coverage, die Hooks laufen nur lokal via prek).
3. **Tote Override-Flagge entfernen.** `flake.nix:5` `agenix.inputs.home-manager.follows = "home-manager"` — agenix hat den Input entfernt; jede Eval warnt (`input 'agenix' has an override for a non-existent input`, eval-perf.md).
4. **Wellen-Beobachtung:** nach 1+2 die nächsten 2 Bot-Wellen prüfen — bewegt sich helix wieder (falls Input behalten wird, s. u. Alternative) und schrumpft der Diff?

### Phase 2 — Input-Diät: tote/falsch gepinnte Inputs

1. **Helix-Eigen-Input streichen** (Empfehlung mit hoher Konfidenz, oracle-development HQ1: „Kosten ohne Nutzen (heute)"):
   - `flake.nix:36-37` (Input + follows), `modules/aspects/development/editors/helix.nix:1-8` (Overlay + helix.cachix.org-Substituter-Block), `modules/aspects/development.nix:5,16` (Imports).
   - Begründung: Der „master"-Zweck ist tot (Lock 2 Monate alt, eigene Automatik bewegt ihn nachweislich nicht mehr); `follows = "nixpkgs"` macht helix.cachix.org praktisch blind (CI baut gegen Helix-Eigenlock, Kombination helix@07-23 × nixpkgs@09-27 wurde nie dort gebaut) → lokaler Rust-Rebuild sobald Toolchain-Inputs wandern; nixpkgs-unstable liefert eine currente Helix-Release gratis.
   - Effekt: 1 Substituter weniger global (5 → 4 auf dem Desktop-Host), Lock −3 Nodes (helix, rust-overlay, base16-helix), kein Rust-Rebuild-Risiko mehr.
   - Dokumentierte Alternative, falls konkrete master-Features fehlen: Input behalten, aber `follows` streichen (cachix wird trefferfähig) UND Bump-Rhythmus etablieren — die dafür nötige Disziplin fehlt jedoch seit 9 Wochen; Standard-Empfehlung bleibt Streichen, bei Bedarf bewusst neu einführen.
2. **niri-Fork zurückrollen oder begründen.** `flake.nix:52` `github:epireyn/niri-flake` → `github:sodiboo/niri-flake` (Fork ist synced, Wechsel in 417528f 2026-08-24 „fix: resolve nix check warnings" ohne dokumentierten Grund; einzelner persönlicher Fork als einzige Compositor-Quelle ist Verfügbarkeitsrisiko). Falls der Grund real war: als Kommentar an flake.nix dokumentieren statt Fork pflegen; besser PR upstream.
3. **Substituter-Query-Last senken.** `modules/aspects/core/nix.nix:32` `narinfo-cache-negative-ttl = 30` → 3600 — Misses werden sonst alle 30 s gegen alle Substituter erneut angefragt (oracle-development Empfehlung 3).

### Phase 3 — Lock-Konsolidierung: gezielte follows, keine Diät-Kosmetik

1. **Zweite nixpkgs-Instanz entfernen.** `niri.inputs.nixpkgs-stable.follows = "nixpkgs"` in flake.nix + Guard-Kommentar („bricht niri-stable, absichtlich — ungenutzt"). Beleg: niri-stable/xwayland-satellite-stable haben 0 Referenzen in modules/ + templates/ (grep verifiziert), `nixpkgs-stable` (`cf5e765`, nixos-26.05) rollt als einziger Stable-Knoten wöchentlich als sinnloser Lock-Churn. Ergebnis: exakt eine nixpkgs-Instanz — die Kanal-Disziplin, die die Follows-Architektur verspricht, wird damit erst vollständig.
2. **agenix-rekey-Dev-Doppel-Toolchain kollabieren.** `agenix-rekey.inputs.devshell.follows = "devshell"`, `...treefmt-nix.follows = "treefmt"`, `...pre-commit-hooks.follows = "git-hooks"` (gleiche Upstreams, Rename API-kompatibel; reine DevShell-Bestandteile, nie im Pfad der nixosModules/homeManagerModules — oracle-lock-hygiene verifiziert). ~−6 Nodes; die 2024er-Relikte (devshell dd6b809/2024-10-07, treefmt-nix 9e09d30/2024-12-25, pre-commit-hooks a5a9613/2025-01-03) verschwinden. Wichtig: `nix flake update` kann sie prinzipiell nicht bewegen — nur follows kollabieren Transitiv-Pins aus Upstream-Lockfiles (oracle-lock-hygiene W2, bewiesen am dank-qml-common-Doppel-Move in PR #26).
3. **dank-qml-common vereinheitlichen.** Neuer Root-Input `dank-qml-common` + `dms.inputs.dank-qml-common.follows = "dank-qml-common"` + `dank-greeter.inputs.dank-qml-common.follows = "dank-qml-common"` → eine Rev des QML-Fundaments für Shell UND Greeter (aktuell `a88b16e` vs `660b044`, wandern wöchentlich getrennt auseinander — Inkonsistenz-Risiko im DMS-Stack bei jedem Bump). Vor dem Merge Greeter-Build als Probe.
4. **Bewusst NICHT tun:** stylix/NUR/agenix-rekey-Transitive (flake-parts ×3, fromYaml, base16-*, tinted-*, systems) per follows kollabieren und den Lock auf „schöne 30 Nodes" diäten. Begründung: Das sind Upstream-Lock-Pins, kein Versäumnis dieses Repos; sie erscheinen nie in wöchentlichen Diffs (Review-Noise-These vom Orakel widerlegt — PR-Bodies #18–#26 enthalten keine Alt-Nodes), 24 Wellen eval-grün, und ein follow schafft ein ungetestetes Pairing (altes flake-parts × neues nixpkgs-lib wäre durch ersetzt — statisch riskanter als der status quo, der empirisch läuft). Ausnahme ist nur die Dev-Kette aus 3.2, weil sie eval-pfadneutral ist. Ebenso NICHT: einen AvengeMedia-Substituter „konfigurieren" — es existiert kein öffentlicher (verifiziert am DMS-Flake: kein nixConfig); die verbleibenden Hebel sind Kadenz (Phase 4) und ggf. ein eigener Cache (für 1 Workstation abgelehnt: Betriebsaufwand > Nutzen).

### Phase 4 — Kadenz- und Kanal-Disziplin

1. **Kadenz halbieren.** `.github/workflows/flake-update.yml:6` Cron `0 4 * * 1` → `0 4 1,15 * *`. Halbiert die lokalen Source-Builds des DMS/greeter/Plugins-Stacks (kein Binary-Cache existiert, jede Welle = mittelgroßer lokaler Build) und die Review-Last; nixpkgs-unstable bleibt ein rollierendes Ziel, Aktualität bleibt ausreichend. Manuelle Welle bei Bedarf bleibt über `workflow_dispatch` möglich (Security-Fixes).
2. **Kanal-Strategie festschreiben: unstable + volle Follow-Kopplung behalten.** Selektives Release-Pinning des DMS-Stacks würde die Follow-Architektur aufbrechen (zwei nixpkgs-Welten im Desktop — genau das, was die Architektur vermeidet). Die Entscheidung samt Preis (wöchentlich/biweekly lokale DMS-Builds) als Kommentar in flake.nix/README dokumentieren.
3. **Consumer-Pin-Gap schließen.** `.dotnix` working-tree pinnt `0c33875` (2026-09-15, 8 Commits hinter Library-HEAD `ac7724c`, Aufräum- und Performance-Commits nicht enthalten), committeter Pin noch älter (`2496fd2`), Lock-Änderung uncommittet (oracle-dead-dupes). Nach Abschluss der Phasen 1–3: Consumer-Lock updaten, committen; Regel „push before rebuild" einführen (Library-Push vor Consumer-Rebuild), sonst gilt weiterhin: gearbeiteter Stand ≠ gefahrener Stand.

### Phase 5 — Grenzhebel (Struktur nur soweit die Konsolidierung erfordert)

1. **debug-Default streichen.** `modules/parts/flake-parts.nix:5` `debug = lib.mkDefault true` — als Teil des flake.flakeModule-Exports ein eval-Kosten-Default für jeden Konsumenten (flake show/repl/outputs-walkende Tools forcieren die gesamte Optionen-Struktur; Upstream-Default ist false). Eine Zeile Substrat-Export-Hygiene. Der volle Parts-Split (devshell/treefmt/pre-commit/templates aus `expose.nix` raus) ist Struktur-Strategie und hier bewusst nicht mitgeführt.
2. **DMS-Substrat-Folgekosten im Review-Blick behalten.** `modules/aspects/desktop/shell/dms.nix:12` aktiviert bedingungslos `programs.dsearch` (danksearch-Dauer-Indexer mit File-Watcher, wantedBy default.target) — ein Hidden-Daemon, der mit dem DMS-Substrat-Adopt mitkommt. Runtime-Bewertung gehört zur anderen Richtung; das Enable selbst ist beim nächsten DMS-Substrat-Review zu gate (z. B. target graphical-session oder Opt-out).

## Risiken + Gegenmaßnahmen

- **Helix-Freeze-Wurzel ohne nix-Lauf nicht beweisbar** (Action@main-Verhaltensänderung vs. Runner-Tarball-Cache vs. GitHub-API-Anomalie). Gegenmaßnahme: Phase 0.2 (eine Minute Owner-Diagnose) + Phase 1.1 + Wellen-Beobachtung Phase 1.4. Fällt helix (Alternative behalten), MUSS die Wurzel vorher geklärt sein, sonst friert master erneut ein.
- **nixpkgs-stable-Follow bricht niri-stable-Semantik** (Stable-Paket würde gegen unstable gebaut). Abgefedert: niri-stable ist ungenutzt (grep-verifiziert, Rollback-Pfad im Lock existiert ohnehin nicht), Guard-Kommentar dokumentiert die bewusste Entscheidung; Rollback = Zeile streichen.
- **dank-qml-common-Vereinheitlichung kann eine Seite brechen**, wenn dms und dank-greeter gegen ihre je eigenen Pins getestet sind und die QML-Basis-API driftet. Gegenmaßnahme: Rev des Hauptkonsumenten dms (`660b044`) wählen, Greeter-Build als Probe vor dem Merge; Rollback = follows streichen.
- **agenix-rekey × git-hooks-Rename** (pre-commit-hooks → git-hooks.nix): API-kompatibel, DevShell-only, nie im Modul-Pfad (oracle-verifiziert) — Restrisiko ~0; trotzdem ein rekey-Dry-Run nach Phase 3.2.
- **Biweekly-Kadenz vergrößert den Sprung pro Welle** → größere Rebuild-Bursts und später einlaufende nixpkgs-Fixes. Gegenmaßnahme: Build-Gate (Phase 1.2) vor Auto-Merge; `workflow_dispatch` für Ad-hoc-Wellen.
- **Fork-Rollback kann legitimen Grund zerstören** (417528f löste „nix check warnings"). Gegenmaßnahme: vor Rollback Upstream auf die Warnungen prüfen; falls real → PR upstream statt Fork.
- **Consumer-Horizont:** Der Desktop-Laptop-Konsument liegt außerhalb der sichtbaren Repos; alle Substrat-Fixes wirken auf ihn erst nach dessen Lock-Update, und die Trägheits-Diagnose „träger Desktop" kann aus keinem der beiden Repos geführt werden. Gegenmaßnahme: Phase 0.1/4.3. Bis dahin ist jede Aussage zur Live-Wirkung Provisorium.
- **Bewusst akzeptiert:** Lock-Nodezahl selbst ist kein Performance-Faktor (identische Revs deduplizieren im Store; eval-perf.md: Alt-/Doppel-Nodes ~0 Eval-Kosten). Diese Strategie verkauft keine Laufzeit-Verbesserung durch Lock-Diät — die Laufzeit-Hebel (Ghostty-Shader, Akku-Profil, dsearch, fastfetch, LSP-Doppelung) liegen in den anderen Richtungen.

## Aufwandsschätzung

| Phase | Umfang | Aufwand |
|---|---|---|
| 0 Klärung | Laptop-Konsument klären, helix-Diagnose-Lauf | 1 h + 1 nix-Kommando (Owner) |
| 1 Pipeline | Actions pinnen, Build-Gate/Fixture, Kommentar, Override-Flagge | 4–6 h (davon Fixture 2–4 h) |
| 2 Input-Diät | helix entfernen inkl. Rebuild + Smoke-Test, Fork, TTL | 1,5–2 h |
| 3 Lock-Konsolidierung | 3 follows-Gruppen + `nix flake check` + rekey-Dry-Run + Greeter-Probe | 1,5–2 h |
| 4 Kadenz/Kanal | Cron, Dokumentation, Consumer-Lock | 1 h |
| 5 Grenzhebel | debug-Zeile, dsearch-Notiz | 0,25 h |
| **Gesamt** | | **~9–12 h (1,5–2 Arbeitstage) + 2–4 Wochen Wellen-Beobachtung** |

Alle Phasen einzeln revertierbar (je ein Commit); keine Reihe muss auf die andere warten außer: Phase 4.3 (Consumer-Lock) erst nach 1–3.

## Erwartete Wirkung auf Struktur/Wartbarkeit/Performance-Trägheit

- **Struktur: gering.** Keine Umstrukturierung von Aspekten/Aggregatoren; Konsolidierung wirkt auf flake.nix, Workflows und Lock. Einzig messbarer Struktur-Effekt: eine nixpkgs-Instanz, weniger Duplicate-Diskussion im Lock-Review, dokumentierte Fork/Kanal-Entscheidungen. Wer Struktur-Schmerz (Taxonomie-Brüche, Aspect≠Dateiname, Parts-Leak) fixen will, ist mit der Struktur-Richtung besser bedient.
- **Wartbarkeit: hoch.** Vertrauenswürdige Update-Pipeline (helix-Anomalie geklärt/eliminiert, gepinnte Actions, echtes Gate statt Eval-only-Auto-Merge — 22/186 Update-Commits sind ab dann geprüfte, halb so große Wellen), Lock 58 → ~46 Nodes, eine Dev-Toolchain statt zweier, eine dank-qml-common-Rev statt zwei divergenten, Fork-Risiko weg, Consumer-Pin-Gap geschlossen. Das ist die Richtung mit dem besten Wirkung/Aufwand-Quotienten auf die „Wartbarkeit"-Klage des Besitzers.
- **Performance-Trägheit: mittel — ehrlich eingeordnet.** Spürbar bei jedem Update/Rebuild-Zyklus: DMS/Greeter/Plugins-Local-Builds halbiert (biweekly), helix-Rust-Rebuild-Risiko auf allen development-Maschinen eliminiert, Substituter-Last −1 Endpoint und Miss-Requery 30 s → 1 h, Eval-Warnung weg, Konsumenten-Eval ohne debug-Default. NICHT verbessert: die Laufzeit-Trägheit des Desktops selbst — Lock und Inputs sind nach Orakel-Befund kein Laufzeitfaktor; die dortigen Hebel (Ghostty-Animations-Shader, batteryProfileName=power-saver, dsearch-Dauerindexer, fastfetch pro Pane, doppelte LSP-Server) liegen außerhalb des Substrats. Wer „träger Desktop im Betrieb" fixen will, findet die Ursachen in den Runtime-Befunden, nicht hier; wer „träges Update-/Rebuild-Erlebnis und unwartbares Input-Gestrüpp" fixen will, findet sie vollständig hier.
