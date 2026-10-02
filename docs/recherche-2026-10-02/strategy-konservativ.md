# Strategie KONSERVATIV — Gezielte Kleinstdiffs, kein Umbau

Richtung: bestehendes Dendritic-Muster bleibt unverändert. Keine Re-Granularisierung, kein Host-Umzug, keine Architektur-Änderung, keine Verschiebung von Groups/Tiers. Alle drei Besitzer-Beschwerden (Struktur, Wartbarkeit, Desktop-Trägheit) werden ausschließlich mit kleinsten, verifizierten Diffs und Löschungen angegriffen.

## Pitch

Alle neun Orakel-Gutachten konvergieren unabhängig voneinander auf dasselbe Urteil: Das Muster ist richtig, die Ausführung ist das Problem. Die Dendritic-Invarianten halten vollständig (oracle-dendritic: „keine konditionalen Imports, saubere Klassendisziplin"), die Aspekt-Granularität ist „genau richtig", core/system sind „qualitativ hochwertig", und die Trägheit hat nachweislich keine strukturelle Ursache — sie liegt in Ghostty-Shader, Akku-Profil, fastfetch, LSP-Dopplung und Dauerläufern. Jede Umbau-Option verändert Architektur ohne einen einzigen belegbaren Gewinn für die drei Beschwerden. Die konservative Strategie holt ~90 % der Wirkung mit ~25 Zeilen: Ein-Zeilen-Diffs (Shader aus, Akku-Profil, debug=false, TTL), Löschungen (3 tote Module, Helix-Eigen-Input, dms-settings auf echte Deltas) und zwei Vertragsreparaturen (Template, CI-Fixture). Umbauten sind Anti-Empfehlungen der Orakel selbst.

## Schritte

### Phase 0 — Rahmen klären (Voraussetzung, ~0,5–1 h)

Der einzige sichtbare Live-Host ist `dmi` (WSL2, ohne `system`-Aspekt); der Desktop-Laptop-Konsument liegt außerhalb des Horizonts (Azure DevOps). Ohne ihn laufen alle Desktop-Fixes ins Leere.

1. **Laptop-Konsumenten identifizieren**: Flake-Quelle des Desktop-Hosts klären, verifizieren welcher Aspects-Pin dort fährt (oracle-dead-dupes Empfehlung 1). Ergebnis dokumentieren (eine Zeile im README des Konsumenten-Repos).
2. **Stand-Gap schließen**: Consumer-`flake.lock` nach dem Cleanup updaten — der WSL-Host fährt laut Orakel 8+ Commits alten Stand inkl. unverifizierter Lock-Änderungen.

### Phase 1 — Trägheits-Quick-Wins (config-seitig, ~1 Arbeitstag)

Reihenfolge = Ursachen-Rangfolge der Orakel (runtime-perf, desktop, term, development). Alles rückbaufähig, je ein Commit.

1. **GPU-Last pro Terminal abschalten**: `modules/aspects/desktop/terminal/ghostty.nix:16` `background-blur = 20` → `false`; `:22` `custom-shader-animation = true` → `false` (Shader läuft danach nur beim Cursor-Warp-Event). 10 min, P1 laut oracle-desktop.
2. **Akku-Drossel aufheben**: `modules/aspects/desktop/shell/dms-settings.nix:209` `batteryProfileName = "power-saver"` → `"balanced"`. Eine Zeile — die wahrscheinlichste Einzelursache für zähes UI im Akkubetrieb (oracle-runtime-perf P1).
3. **fastfetch aus tmux-Panes nehmen**: `modules/aspects/term/monitoring/fastfetch.nix:23-26` — `fish_greeting` um `if not set -q TMUX` guarden. 15 min, entfällt pro Pane/Popup.
4. **LSP-Doppelung auflösen**: `modules/aspects/development/editors/helix-lsp/nix.nix:3,21` — `nil` streichen (nixd-Config bleibt), `statix`/`deadnix` aus extraPackages; `helix-lsp/markdown.nix:5,16` — `marksman` streichen (markdown-oxide bleibt). Halbierte Serverzahl pro Buffer. ~1 h.
5. **Nix-Substituter-Miss-Cache**: `modules/aspects/core/nix.nix:32` `narinfo-cache-negative-ttl = 30` → streichen (Default 3600). Eine Zeile, spart bei jedem Build/Switch mit fehlenden Pfaden.
6. **Dauerläufer entschlacken** (je nach Ausgang der Messung, Nr. 8):
   - `modules/aspects/desktop/shell/dms.nix:12` `programs.dsearch.enable = true` — Option prüfen (Verdacht stiller Eval-Bruch, kein Input definiert sie laut desktop-Report); wenn tot: löschen; wenn lebendig: auf `graphical-session.target` begrenzen oder deaktivieren.
   - `modules/aspects/development/devops/docker.nix:16` `linger = true` → Socket-Aktivierung, falls Docker auf dem Desktop-Host läuft.
   - `modules/aspects/term/mailing/maildir.nix:9,17` — Doppel-Sync auflösen: `hooks.preNew = "mbsync --all"` (`:17`) entfernen ODER Timer `*:0/15` (`:9`) auf `hourly` — Besitzer-Entscheidung, 15-Min-Grundlast halbiert.
   - `modules/aspects/desktop/apps/handy.nix` — `StartLimitIntervalSec`/`StartLimitBurst` setzen (Restart-on-failure-Sturm vermeiden).
7. **Bar-Polling probefahren**: `dms-settings.nix` — `cpuUsage`/`memUsage` aus `rightWidgets`, `audioVisualizerEnabled` testweise `false`. Differenziert probefahren, zurückbauen was fehlt (oracle-desktop Nr. 6).
8. **Messprotokoll-Session (vor 6–7!):** eine Session `systemd-cgtop` + GPU-Top im Idle und beim Scrollen, DMS-Bar sichtbar/überlagert, Ghostty zu/auf, Netz/Akku. ~1 h — verifiziert die Rangliste empirisch statt zu glauben. `thermald` (`modules/aspects/system/power.nix`) nur setzen, wenn Messung Throttling zeigt (sonst spekulative Zeile).

### Phase 2 — Struktur-/Wartbarkeits-Quick-Wins ohne Architektur-Eingriff (~2 Arbeitstage)

1. **Template reparieren** (P1, ~1 h): `templates/dotnix/modules/hosts/myHost/configuration.nix:4-7` — `core` in die `modules`-Liste aufnehmen (Factory injiziert es nachweislich NICHT — `modules/parts/configuration.nix:37-45` mergt nur `host.modules ++ userModules ++ Metadaten`). Ohne `core` ist das Template für jeden Dritten eval-broken.
2. **README-Lügen korrigieren** (~1 h): `README.md:21` `modules/options.nix`→`modules/parts/configuration.nix`; `:46` „injecting core modules automatically" streichen (Realität: nur Host-Metadaten/stateVersion); Pfad-Konventionen (wallpaper/secrets/certificates) einmal dokumentieren.
3. **CI-Consumer-Fixture** (~2–4 h): neuer Job in `.github/workflows/flake-check.yml`: `nix flake new /tmp/fixture -t .#dotnix` + `nix flake check` im Fixture. Testet den kompletten öffentlichen Vertrag (expose.nix-Wrapping, Factory, Template) — die Keuzzeile: alle drei bisherigen Verrottungen (Template, README, debug-Default) wären davon gefangen worden. Gleichzeitig falschen Kommentar `flake-check.yml:26-27` („covers:"-Liste ist lokal-prek, nicht CI) korrigieren.
4. **debug-Default streichen**: `modules/parts/flake-parts.nix:5` `debug = lib.mkDefault true` löschen (Upstream-Default false). Sofort weniger Eval-Kosten bei jedem `flake show`/`nix`-Kommando im Konsumenten. 1 Zeile.
5. **3 tote Module löschen**: `modules/aspects/core/yubikey-lock.nix`, `modules/aspects/desktop/greeter/tuigreet.nix`, `modules/aspects/system/boot-limine.nix` (je einzige Referenz = eigene Registrierung; Import-Tree macht Entfernen gratis). 30 min.
6. **dms-settings.nix kurieren** (~2–4 h): `modules/aspects/desktop/shell/dms-settings.nix` (457 LOC) auf die ~24 echten Abweichungen vom Upstream-Default reduzieren, `configVersion`-Zeile und `mkDefault`-Wraps streichen. Killt den Doppel-Writer-Churn (DMS migriert bei jedem Start 5→33, HM schreibt Alt-Stand zurück) — der größte Einzelgewinn für Desktop-Wartbarkeit.
7. **Helix-Eigen-Input entfernen** (~1 h): `flake.nix:36-37` streichen, Overlay+Substituter-Block `modules/aspects/development/editors/helix.nix:1-8` streichen, `helix` aus den development-Imports. Der Input ist faktisch tot (Bot bump ihn seit 9 Wochen nicht, Lock-Stand 2026-07-23, `follows = "nixpkgs"` macht den Eigen-Cache blind) — Kosten ohne Nutzen; nixpkgs-Helix ist aktueller.
8. **Kleinreparatur-Kombo** (~1 h): `hostname`-Typfehler `modules/parts/configuration.nix:33` (`type = str; default = null`); totes `difftastic`-Modul streichen (aktiviert, aber von git nie erreicht); `television`-Granularitäts-Fusion und Namens-Hygiene (`k9s.nix`→`kubernetes.nix` usw.) NUR als Gelegenheits-Commits — renames sind dank Import-Tree mechanisch gratis, aber kein eigenständiger Termin wert.

### Phase 3 — Lock-/Pipeline-Hygiene (nachlaufend, ~0,5–1 Tag)

1. **Auto-Merge-Kadenz halbieren**: `.github/workflows/flake-update.yml` Cron `0 4 * * 1` → `0 4 1,15 * *`. Halbe wöchentliche DMS-Source-Rebuild-Frequenz (der Stack hat verifiziert keinen Binary-Cache). 1 Zeile.
2. **CI echten Build vor Auto-Merge**: `flake-check.yml` um `nix build .#nixosConfigurations.<host>...toplevel` (oder nix-fast-build) ergänzen — sonst erscheinen Build-Brüche (unstable!) erst beim `switch` auf dem Desktop. 2–3 h.
3. **Follows-Konsolidierung** (je 1 Zeile + `nix flake check` + Consumer-Dry-Run): `agenix-rekey`-Dev-Kette (devshell/treefmt/git-hooks), `niri.inputs.nixpkgs-stable.follows = "nixpkgs"` (Schiene ungenutzt, grep-verifiziert), `dank-qml-common` auf eine Rev für Shell+Greeter. Reduziert den Duplicate-Cluster (30/57 Lock-Nodes).
4. **Hibernation-Warnkommentar**: `modules/aspects/system/power.nix` — Btrfs-Swapfile braucht `resume_offset` per Kernel-Param (Consumer-seitig). Einziges echtes Funktionsrisiko der core/system-Dimension (stiller Session-Verlust am Ziel-Laptop). 15 min.
5. **Optional, nur wenn Public Release real wird**: Export-Split `modules/expose.nix` (Dev-Tooling aus dem Konsumenten-Export, `age-rekey.nix:10-19` persönliche Master-Identities in Optionen überführen). Bewusst vertagt: es bricht den Konsumenten-Vertrag und ist der einzige Punkt dieser Strategie, der über Kleinstdiffs hinausgeht — debug-Streichung (Phase 2.4) deckt den Eval-Anteil bereits ab.

### Explizit NICHT tun (Anti-Empfehlungen, jeweils orakelgestützt)

- **Granularität umbauen** — oracle-dendritic: „ein Tool, eine Datei, ein Aspekt ist der Kernwert; die einzige Granularitäts-Störung läuft in die Gegenrichtung".
- **Hosts ins Repo ziehen** — bewusste, funktionierende Erweiterung; die Case-Bug-Klasse wird vom CI-Template-Test (Phase 2.3) günstiger eliminiert.
- **Groups an Tiers angleichen** — strukturell unmöglich ohne Zerstörung der Themen-Ordnung (oracle-dendritic HQ1).
- **Impermanence in Collector-Dateien rekonstruieren** — Aufwand ohne Verhaltensgewinn.
- **Assertions-/Constraint-Layer für Komposition** — Over-Engineering; Fehler sind beim ersten Boot selbst-erklärend (oracle-core-system).
- **disko-Aspekt entschlacken** — die +7 s Eval pro Host sind bekannt, aber disko ist funktionale Notwendigkeit des Ziel-Hosts; kein konservativer Hebel. Bewusst akzeptiert.

## Risiken + Gegenmaßnahmen

| Risiko | Grad | Gegenmaßnahme |
|---|---|---|
| Desktop-Laptop fährt älteren Aspects-Pin → Phase-1-Fixes wirken dort nicht sofort | hoch (Stand-Gap ist belegt) | Phase 0 vor allem anderen; nach Cleanup Consumer-Lock updaten; Wirkung erst dann bewerten |
| `dms-settings`-Reduktion: gepinnte Werte aus configVersion 5 ≠ Defaults der aktuellen DMS-Revision → sichtbares Verhalten ändert sich | mittel | Vorher geplante Diff-Liste der ~24 echten Deltas gegen gepinnten Rev reviewen; eine Woche Probefahrt; git revert-ready; Alternativ-Fallback: bewusstes Voll-Pinning dokumentieren statt reduzieren |
| Ghostty ohne Blur/Shader ist Optik-Verlust (Geschmack des Besitzers) | gering-mittel | Nur `custom-shader-animation = false` statt Shader-Komplett-Entfernung; Blur individuell zurückdrehen |
| LSP-Konsolidierung entfernt Server, die der Besitzer aktiv nutzt (nil-vs-nixd-Präferenz) | gering | Beide Server bleiben als Pakete verfügbar; nur die `language-servers`-Liste wird eindeutig; Rückbau = 1 Zeile |
| dsearch/thermald/docker ohne Messung = Raten | mittel | Messprotokoll-Session (Phase 1.8) ZWINGEND vor 1.6/thermald; nur anfassen, was die Messung zeigt |
| Follows-Änderungen (Phase 3.3) brechen Eval-Bindungen upstream | gering-mittel | Nach jeder Zeile: `nix flake check` + Consumer-Dry-Run; Fallback dokumentieren (Pin-Kommentar) |
| Hibernation-Fix ist Consumer-seitig, kein Bibliotheks-Diff | gering | Warn-Kommentar in `power.nix` (Bibliothek) + Kernel-Param im Konsumenten-Repo; als Pair-Session mit dem Besitzer einplanen |

Ehrlichkeit über die Grenzen der Richtung: Der Export-Split und die Taxonomie-Moves (`core/fonts.nix`→`desktop/` usw.) sind von den Orakeln empfohlen und werden hier bewusst nur teilweise vertagt/optional behandelt. Begründung: beide sind Wartbarkeits-, keine Beschwerde-Hebel — kein Orakel attestiert ihnen Wirkung auf Trägheit, und der Vertragbruch (Konsumenten-Import) wiegt schwerer als der Gewinn, solange das Repo primär Eigenverbrauch ist.

## Aufwandsschätzung

| Phase | Umfang | Aufwand |
|---|---|---|
| 0 — Rahmen klären | Laptop-Pin, Consumer-Lock | 0,5–1 h |
| 1 — Trägheits-Quick-Wins | 8 Einzeldiffs + Messsession | ~1 Arbeitstag |
| 2 — Struktur/Wartbarkeit | Template, README, CI, Löschungen, dms-Kur | ~2 Arbeitstage |
| 3 — Lock/Pipeline | Kadenz, Build-CI, follows, Hibernate | 0,5–1 Arbeitstag |
| **Gesamt** | ~25 geänderte Zeilen + Löschungen + 1 CI-Job + 1 Messsession | **~4–5 Personentage** |

Zum Vergleich: jede Umbau-Alternative (Re-Granularisierung, Host-Migration, Export-Rewrite) kostet allein ein Vielfaches an Aufwand UND an Risiko (Breaking Changes am Konsumenten-Vertrag), ohne dass ein einziges Orakel ihr Wirkung auf die drei Beschwerden attestiert.

## Erwartete Wirkung auf Struktur/Wartbarkeit/Performance-Trägheit (ehrlich)

| Dimension | Wirkung | Begründung (ehrlich) |
|---|---|---|
| **Struktur** | **mittel** | Die konkreten Struktur-Lügen (Template eval-broken, README-Phantome, ungetesteter Export-Vertrag, 3 tote Module) werden behoben — das sind genau die Fundstellen der Beschwerde. Aber: das Muster selbst (Groups≠Tiers, Collector-Inline-Beiträge, Namespace-Doppelung) bleibt, wie es ist. Wer „Struktur" als Muster-Kritik meint, bleibt unzufrieden. Die Orakel-Befundlage sagt aber: Die Kritik-Punkte waren Ausführung, nicht Muster. |
| **Wartbarkeit** | **hoch** | Größter Einzugewinn dieser Strategie: dms-settings 457→~40 LOC (killt configVersion-Churn), CI-Fixture verhindert Verrottung strukturell (Root-Cause), Helix-Eigen-Input + tote Module weg, Doppel-LSP/doppel-Sync aufgelöst, README wird wahr, CI-Kommentar hört auf zu lügen. Alles mit Löschungen und 1-Zeilen-Diffs, nichts davon braucht Umbau. |
| **Performance-Trägheit** | **mittel bis hoch** (config-seitig), **gesamthaft mittel** | Die identifizierten Ursachen werden direkt angegriffen: GPU-Last (Shader/Blur), Akku-Drossel, Pane-Latenz (fastfetch, LSP), Dauerläufer (dsearch, docker-linger, mbsync), Substituter-Noise — hochkonfident laut zwei Perf-Orakeln. Ehrliche Einschränkungen: (1) Die reale Aufteilung auf dem Laptop ist bis zur Messsession unbelegt — daher Phase 1.8 vor 1.6/7. (2) Die +7 s disko-Eval pro Host bleibt bewusst stehen (kein konservativer Hebel). (3) Der DMS-Stack bleibt ohne Binary-Cache — Phase 3.1 halbiert nur die Frequenz, behebt nicht die Ursache. (4) Läuft der Desktop unter WSLg/Windows, greifen config-Hebel nur teilweise — Kern/system sind dafür entlastet (oracle-core-system: einziger produktiver Host importiert `system` gar nicht). |
