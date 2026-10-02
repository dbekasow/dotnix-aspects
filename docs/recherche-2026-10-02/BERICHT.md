# Endbericht: Recherche .dotnix-aspects

**Basis:** `/home/denis/repositories/private/.dotnix-aspects`, HEAD `ac7724c` (Branch `refactor/public-release`; Working Tree `M modules/aspects/term/shell-ux/sesh.nix` — User-Arbeit, in allen Gutachten unangetastet, in keinem PR berühren). Sichtbarer Konsument `.dotnix`: nur WSL-Host `dmi` (`modules = [ core wsl development ]`), pinnt `0c33875` — 8 Commits hinter HEAD, `M flake.lock` uncommittet. Laptop-Desktop-Konsument außerhalb des sichtbaren Horizonts (Azure-DevOps-Remote). Material: 30 Gutachten in `/tmp/dotnix-research/`. Hierarchie bei Widersprüchen: Orakel > Researcher, Querschnitt > Dimensions-Orakel, Judge > Strategiepapiere. Widerlegte Befunde (z. B. „disko +7 s") tauchen nur in §9 auf und begründen keine Empfehlung.

## 1. Executive Summary

**Pattern unschuldig, Ausführung schuldig.** Alle strukturtragenden Dendritic-Invarianten halten — keine konditionalen Imports, saubere Klassendisziplin, keine Doppel-Imports, Granularität „ein Werkzeug = eine Datei = ein Aspekt" genau richtig; dreifach unabhängig verifiziert (cross-struktur-verdikt.md). Die Struktur-Klage entsteht aus vier Ausführungslücken: (1) verrotteter Bibliotheks-Vertrag — Template eval-broken, README beschreibt Phantom-Dateien, CI evaluiert den Export-Pfad nie; (2) Export-Leak — `expose.nix` liefert Dev-Tooling samt `debug = true` in jeden Konsumenten; (3) ~6 echte Dateiname≠Aspektname-Verstöße inkl. television-Fusion; (4) undokumentierter Tier≠Group-Schnitt. Die Desktop-Trägheit ist nicht strukturell: Top-Ursachen sind Ghostty-Animations-Shader + Blur, Akku-Profil `power-saver` ohne thermald, DMS-Dauerclient-Bündel, dsearch-Datei-Indexer, fastfetch pro tmux-Pane (cross-desktop-langsam.md) — alles konditional zum ungeklärten Laptop-Konsumenten. Eval-seitig ist die Bibliothek sauber (Scaffolding 0,1–0,5 s; die disko-+7-s-These ist als Messartefakt widerlegt; größter echter Block: nixpkgs-pipewire, +3,9 s). Strategie: Der Judge gewinnt B (Umbau) als Rückgrat, mit A's Runtime-Quick-Wins an Position 1 und C's Substrat-Reparatur — Mischplan ~6–8 Personentage in sechs Phasen mit Übergangskriterien. Erste Handlung: Laptop-Flake-Quelle und Pin klären; ohne sie wirkt kein Desktop-Fix am gefahrenen System.

## 2. Struktur — Befund & Urteil

**Verdikt (cross-struktur-verdikt.md, Konfidenz hoch): Das Dendritic-Pattern ist nicht das Problem — die Ausführung ist es.** Verifizierter Compliance-Bestand:

- Keine konditionalen Imports: `mkIf` ausschließlich auf Modul-Inhalt (`core/stylix.nix:53`, `term/shell-ux/tmux.nix:144`, `term/monitoring/fastfetch.nix:23`, `development/vcs/git-credentials.nix:27`).
- Klassendisziplin: `nixos.*`/`homeManager.*` (+ `generic.*` nur an `core/users-profile.nix:14,18`); `home-manager.sharedModules = [ modules.homeManager.core ]` (`core/home-manager.nix:7`) = reguläres Multi-Context.
- Keine Doppel-Imports entlang eines Consumer-Pfads (Tier-Listen paarweise disjunkt geprüft); keine geschlossenen Modul-Argumente; `mkMerge` statt `//`; kanonisches `mkFlake + import-tree ./modules` (`flake.nix:68-69`).
- Collector (Impermanence in 22 Dateien), Constants, Options-Collector `dotnix.tmux.bindings`/`popups` mit Duplikat-Key-Validierung: pattern-gemäß bis vorbildlich.
- 146 `.nix`-Dateien, 4.571 LOC, 120 `homeManager`- + 54 `nixos`-Aspekt-Definitionen.

### 2.1 Architektur: Bibliothek ohne Hosts — richtig, mit einer bislang unbezahlten Rechnung

Optionen (cross-struktur-verdikt.md): **A** Split behalten + Vertrag fixen (empfohlen) · **B** Hosts reinziehen (Host-Secrets/Zertifikate in öffentlichem Repo bzw. Aufgabe des Public Release) · **C** Bibliothek auflösen (Public-Release aufgegeben, zweiter Konsument verlöre geteilte Basis) · **D** Host-Registry → Host-Features migrieren (Breaking Change über alle Core-Aspekte ohne Gegenwert; der einzige reale Bug dieser Klasse ist ein Ein-Zeichen-Fix + CI-Test).

**Urteil: Option A.** Die Aufteilung ist die einzige, die Geheimhaltung und Veröffentlichung gleichzeitig erlaubt; die Absicht ist belegt (LICENSE, README „reusable library", Template, GitHub-Remote, Branch `refactor/public-release`; zwei reale Konsumenten). Ehrliche Kostenrechnung: Der Split ersetzt das natürliche Feedback des kanonischen Patterns (echte Hosts unter `nix flake check`) durch einen Vertrag, der bis heute implizit und ungetestet war — genau deshalb sind Template, README und der Desktop-Ast gegen einen unsichtbaren Konsumenten verrottet. Der Template-CI-Job ist daher kein Nice-to-have, sondern das strukturelle Missing Piece der Architektur. Last-Condition: Wäre die Veröffentlichungsabsicht Fiktion, kippt die Abwägung zu Option C (Zwei-Host-Einzelbetrieb).

### 2.2 Template/README/CI — die wirkmächtigste Abweichung

- **Case-Mismatch:** `templates/dotnix/modules/hosts/myHost/configuration.nix:9` `members = [ "myUser" ]` vs. `users/myUser/default.nix:2` `user = "myuser"` → `lib.attrVals` (`modules/parts/configuration.nix:39`) wirft `attribute 'myUser' missing` (von oracle-eval-perf reproduziert: Template-Eval bricht nach 8,8 s).
- **Fehlendes `core`:** Host-Module `[ dell-precision-5570 system development ]` (`configuration.nix:4-8`) — `nixos.home-manager` ist nur über `nixos.core` erreichbar (einzige Import-Stelle: `core/home-manager.nix:4`); die User-Datei setzt `home-manager.users.*` → zweite Eval-Error-Klasse. **Beide Fixes zusammen nötig** (Judge Widerspruch 2: Strategie A hätte das Template nach eigenem Fix weiterhin kaputt).
- **Dritte Bruchklasse** (oracle-eval-perf HQ3): Nach Case+core-Fix crasht der unguardete `lib.readFile`-Pfad in `core/age-rekey.nix:8-9,29-31`, solange der Konsument die geforderten Dateien nicht liefert.
- **README lügt:** `README.md:21` referenziert `modules/options.nix`/`factories.nix` (beide existieren nicht; real: `modules/parts/configuration.nix` + `modules/expose.nix`); `README.md:8` „self-contained" und `:46` „injecting core modules automatically" beschreiben eine Architektur, die seit `880c2b1` (2026-04-20, bewusste Entfernung) nicht existiert.
- **Root Cause:** `.github/workflows/flake-check.yml` evaluiert nur die Bibliotheks-Flake; `templates/dotnix` ist eine eigene Flake; kein `checks`-Output existiert. Der Kommentar `flake-check.yml:26-27` („covers: treefmt, deadnix, …") behauptet Hook-Coverage, die nur lokal via prek läuft. Eine CI-Consumer-Fixture (`nix flake new -t .#dotnix` + `drvPath`-Eval) hätte alle drei Bruchklassen im PR gefangen — die „Keuzzeule" (oracle-wiring).

### 2.3 Export-Schnittstelle zu breit

`modules/expose.nix:16-23` exportiert `aspects/` UND komplettes `parts/` — jeder Konsument erbt devshell (16 Pakete, `parts/devshell.nix:12-36`), treefmt/`formatter`, prek-Hooks, `flake.templates.default` und `debug = lib.mkDefault true` (`parts/flake-parts.nix:5`; flake-parts spiegelt bei `debug` die gesamte Consumer-Config als `flake.debug`/`allSystems` — Eval-Ballast auf jedem outputs-walkenden Kommando, Magnitude ungemessen). **Achtung vor dem naiven Fix** (oracle-wiring Verschärfung 2): `parts/flake-parts.nix` ist die einzige Quelle der `flake.modules`-Option und MUSS im Export bleiben, sonst sind alle 132 Aspekte tot; ebenso `parts/configuration.nix` (Factory) und `parts/age.nix` (rekey-App, Template-Justfile hängt dran); `parts/home-manager.nix` konservativ mitnehmen. Richtiger Split: **Produkt/Dev** — Dev-Tooling als Opt-in (`flakeModules.devTools`), `debug`-Zeile streichen. `mkDefault` (1500) ist mit schlichtem `debug = false` (100) übersteuerbar — das Problem ist das Nicht-Wissen, nicht die Prioritätsarithmetik (oracle-dendritic High 3).

### 2.4 Namen, Orte, Taxonomie

- **~6 echte Dateiname≠Aspektname-Fälle** (von 9 behaupteten; 3 sind sanktionierte Feature-Splits: `nix-substituters.nix`, `niri-bindings.nix`, `dms-settings.nix`): `skills.nix`→`ai-tools`, `k9s.nix`→`kubernetes`, `tuigreet.nix`→`tui-greeter`, `gpg.nix`→`gnupg`+`gpg-agent`, `yubikey.nix`→`yubikey`+`yubikey-pam`, und der schlimmste Fall: `television-nix.nix:2` konfiguriert `programs.nix-search-tv` unter demselben Aspektnamen `homeManager.television`, den `television.nix` für ein anderes Programm belegt — faktische Fusion, die Tiers immer gemeinsam ziehen. Die Konvention steht commitfest (`31e30d3` „set aspect names to file name"). Renames sind dank import-tree mechanisch gratis (Tier-Importlisten im selben Commit mitziehen).
- **Tier≠Group:** `core.nix:3-14` importiert `fish` (term/shell), `git` (development/vcs), `llm-agents` (development/ai); `system.nix` importiert `performance` (core/); `desktop.nix` importiert `fonts` (core/); `development.nix` importiert `nix-ld` (core/). Der Querschnitt ist dendritischer Normalzustand (Tiers = Kompositionslayer, Gruppen = Themenregale); der Defekt ist die **Namensgleichheit** `core/`↔Tier `core`. Fix: README-Absatz + die 3 echten Fehlplatzierungen verschieben (fonts→desktop/, nix-ld→development/, performance→system/). Vollständige Angleichung ist unattainbar und zerstört die Themen-Ordnung (oracle-dendritic HQ1).
- **Registry-Kopplung ist Design, nicht Unfall:** `users.nix:6,28`, `age.nix:13`, `age-rekey.nix:6`, `nh.nix:11-13`, `certificates.nix:5`, `docker.nix:12`, `dms-greeter.nix:11` lesen `config.dotnix.*` — die members-getriebene Secrets-Generierung trägt die Factory. Zu dokumentieren: Layout-Kontrakt (`modules/hosts/<host>/secrets/*.pub`, `modules/users/<user>/secrets/home-key.pub`, Consumer-Wurzel `yubikey.pub`/`masterkey.age`). Herauszuziehen: persönliche Master-Identitäten aus `age-rekey.nix:10-19` (Public-Release-Security-Blocker, §6). Typ-Falle nebenbei: `parts/configuration.nix:33` `type = str; default = null`.

### 2.5 Granularität: genau richtig

shell-ux 14, monitoring 10, files 10, helix-lsp 9 Dateien — ein Werkzeug pro Datei, einzeln komponierbar, über Tiers en bloc gezogen. Eval-Kosten der Dateizahl: 0,1–0,5 s gemessen — kein Faktor (eval-perf, oracle-eval-perf). Die einzige echte Granularitäts-Störung läuft in Richtung **Unter**-Splitting (television-Fusion), nicht Über-Splitting. Verdichten wäre ein Rückschlag gegen den Kernwert des Patterns.

### 2.6 Tote Module

`core/yubikey-lock.nix`, `desktop/greeter/tuigreet.nix`, `system/boot-limine.nix` (je null externe Referenzen; der unabhängige Python-Graph von oracle-dead-dupes findet keine weiteren Toten) plus No-Op `term/shell/bash.nix`. In einer Bibliothek sind nicht importierte Aspekte Exporte — aber für nie gewählte Alternativen gilt (Judge Phase 2, cross-anti D7): **löschen oder als wählbare Exporte im README listen**; kein Varianten-/Gating-Framework bauen.

**Erste Aktion (cross-struktur-verdikt):** Template fixen (Case + `core`), README auf Realität, CI-Consumer-Fixture — zusammen <2 h und schaltet die Verrottungswurzel ab; Struktur-Fixliste kumuliert ≈ 6–8 h (ohne Export-Split).

## 3. Wartbarkeit — Top-Interventionen

Top-10 aus cross-wartbarkeit-top10.md (Hebelkraft = Impact auf tägliche Arbeit ÷ Aufwand). Zwei Hierarchie-Korrekturen bereits eingearbeitet: dsearch = Runtime-Entscheidung, nicht „toter Code löschen" (Judge Widerspruch 1); disko-Perf-Begründung (+7 s) ist widerlegt — es bleibt die Wartbarkeits-Frage (oracle-eval-perf HQ1).

| Nr | Intervention | Warum (täglicher Hebel) | Impact | Aufwand |
|---|---|---|---|---|
| 1 | Verbraucher-Vertrag absichern: Template reparieren (Case-Fix + `core`) + CI-Verbraucher-Fixture + README korrigieren | Export ist das Produkt, wird aber nie in der Konsumenten-Rolle getestet; 4 bestätigte Brüche (Template-Case, fehlendes core, README-Phantome, dsearch-Verdacht) wären von der Fixture im PR gefangen worden | hoch | 4–5 h |
| 2 | Alltagsreibung eliminieren: fastfetch-TMUX-Guard + Finder-/LSP-Konsolidierung | Jedes tmux-Pane zahlt 100–300 ms fastfetch, jeder .nix/.md-Buffer startet 2–3 LSP-Server, jede fish-Serie sourced 4 Finder-Schichten (2 davon tot) — höchster Impact pro Arbeitsstunde | hoch | 2 h |
| 3 | DMS-Stack entkernen: dms-settings.nix auf ~24 echte Deltas kürzen; dsearch als Runtime-Entscheidung (begrenzen/gaten/deaktivieren); mkForce-Block nach Gegenprobe entsorgen | 457-LOC-v5-Snapshot (180 tote Keys, `configVersion = 5` bei `:454` vs. DMS-intern 33) kämpft wöchentlich gegen DMS-Bumps und jeden HM-Switch (Doppel-Writer) | hoch | 3–4 h |
| 4 | Update-Pipeline reparieren: Helix-Input streichen, Actions pinnen, Build-Gate vor Auto-Merge | Kern-Editor seit 9 Wellen still eingefroren (2026-07-23); wöchentlicher Auto-Merge mit eval-only-Gate lässt Build-Brüche erst am Desktop erscheinen | hoch | 3–4 h |
| 5 | Export-Split: Dev-Tooling aus dem flakeModule-Export; `debug = false` | Jeder nix-Befehl des Konsumenten evaluiert Bibliotheks-Devshell/treefmt/prek + debug-Introspektions-Spiegel mit; Konsumenten führen Outputs, die sie nie deklariert haben | mittel-hoch | 3–4 h (+1 Zeile Konsument) |
| 6 | Struktur- & Namens-Sweep: 3 tote Module löschen, Datei-Lage an Aktivierung angleichen, Renames, Options-Hygiene | Kernklage „wo muss ich suchen?": Ordner und Aggregator laufen auseinander; 6 Dateinamen verraten den Aspekt nicht | mittel | 4 h |
| 7 | Lock-Pflege selektiv: agenix-rekey-Dev-Kette kollabieren, nixpkgs-stable-follows, dank-qml-common vereinheitlichen, Fork begründen | Wöchentliche Update-PRs reviewbar; QML-Basis von Shell und Greeter läuft nicht mehr auseinander; zweite nixpkgs-Instanz + Churn weg | mittel | 1,5 h |
| 8 | Hibernation-Kette vervollständigen: `resume_offset` host-seitig + Warn-Kommentar | `suspend-then-hibernate` an jedem Deckel; ohne Offset bootet der Laptop nach Hibernate mit FRISCHER Session (stiller Datenverlust, keine canhibernate-Warnung) | hoch (Schwere) | 1–2 h |
| 9 | Personal-Config aus öffentlichen Aspekten lösen: `masterIdentities` als Option, Pfad-Konventionen dokumentieren | `age-rekey.nix:10-19` hardcodiert private Pubkeys + Konsumenten-Layout in jeden fremden Merge — Public-Release-Sicherheits- und Funktionsblocker | mittel-hoch | 3 h |
| 10 | disko aus dem system-Collector lösen (Layout pro Host deklarieren) | Layout-Modul wird von jedem system-Host geerbt; abweichende Hosts müssen überschreiben. Ursprüngliche Perf-Begründung (+7 s Eval) ist als Messartefakt widerlegt — übrig bleibt die Wartbarkeits-Frage: Layout gehört zur Host-Deklaration, nicht in den Collector | mittel | 1–2 h |

Gesamtaufwand Top-10 ≈ 25–28 h; die Top-5 allein ≈ 16–18 h. Empfohlene Reihenfolge (cross-wartbarkeit): sofort ohne Abstimmung die Einzeiler (fastfetch-Guard, `debug=false`); PR 1 = Nr. 1 komplett (die Keuzelle); PR 2 = Rest Nr. 2 + Helix-Streichung aus Nr. 4; Laptop-Klärung → PR 3 = Nr. 3 mit DMS-GUI-Gegenprobe; PR 4 = Nr. 4 Rest (Action-Pins, Build-Gate, Kadenz); PR 5 = Nr. 5 Export-Split koordiniert mit `.dotnix`; verteilt: Nr. 6/7/9/10; Nr. 8 host-seitig beim nächsten Laptop-Termin.

## 4. Desktop-Trägheit — Root-Cause-Ranking & Messplan

**Rahmenbedingung vorab (cross-anti E1, „Mutter aller Schein-Verdiener"):** Der träge Desktop fährt nach heutigem Erkenntnisstand aus keinem der sichtbaren Repos — `.dotnix` hat nur den WSL-Host `dmi`, das Template importiert `desktop` nicht einmal; frische Desktop-Commits (Performance-Pass `7d37ccc`, 2026-09-11) belegen aber live-Iteration eines unsichtbaren Laptop-Konsumenten. Alle Top-5-Befunde gelten konditional: „gilt, sofern der Laptop genau diese Aspekt-Datei bei (höchstens) diesem Stand fährt". Der Owner-Perf-Pass hat die Top-5 nicht berührt.

### Top-5 Root Causes

| # | Ursache | Beleg | Einordnung | Ort |
|---|---|---|---|---|
| 1 | **Ghostty-Dauerrenderloop:** animierter Custom-Shader in der Render-Loop + 20-px-Blur + Opacity 0.98 pro Frame jedes sichtbaren Terminals; terminalzentriertes Setup → fast immer ein Terminal sichtbar → konstante GPU-Compositing-Last als Grundrauschen | `desktop/terminal/ghostty.nix:16-22` (`background-blur = 20`, `custom-shader-animation = true` usw.) | **belegt** (config-evident); Runtime-Größenordnung messen (GPU-abhängig) | Repo (falls Laptop `desktop`-Tier bei aktuellem Stand zieht) |
| 2 | **Energie-/Thermik-Profil:** DMS schaltet auf Batterie per power-profiles-daemon auf `power-saver` (EPP/Governor maximal energiesparend → zähes UI); auf AC `performance`. Zweiter Strang: repo-weit kein thermald — auf dem Zielgerät (Dell Precision 5570, Intel-HX) fehlt der Drossel-Schutz | `desktop/shell/dms-settings.nix:209` (`batteryProfileName = "power-saver"`; `acProfileName = "performance"` `:204`); `system/power.nix:18` (PPD); `thermald` repo-weit 0 Treffer | **belegt** (Config-Fakt); ob es das Symptom erklärt, hängt am Trägheits-Regime → messen (Akku-vs-AC-Diskriminierung + Throttle-Kurve) | Einstellung: Repo; thermald-Gap: Konsument/Maschine (nixos-hardware könnte es liefern — am Host prüfen) |
| 3 | **DMS-Dauerclient-Bündel:** Bar-Polling alle 3 s (DankSocket-IPC, 6 s im Power-Saver), Fenstertitel-Marquee + Wave-Progress + Ripple, Audio-Visualizer, Wetter-Poll. Einzelteile entschärft (Blur aus, Wetter mit Backoff), aber die Summe ist die Grundlast des Dings, das man ständig sieht | `dms.nix:29-33` (enable*-Bündel), `dms-settings.nix:37,115-117,359-360` (barConfigs); Polling-Intervall DMS `DgopService.qml:19` (fremd-verifiziert am gepinnten Rev) | **belegt** (Config); Summenlast messen (Idle-CPU/GPU-Anteil von DMS) | Repo |
| 4 | **dsearch (danksearch) Datei-Indexer als permanenter Session-Dienst:** Bleve-Indexer mit File-Watcher und Parallel-Indexierung, `wantedBy = default.target` — Dauerlast im Idle plus Reindex-Bursts bei Datei-Churn (git-Repos, nix). Orakel-Widerspruch aufgeklärt: nixpkgs-Modul existiert (26.11, `module-list.nix:211`) → Eval-Bruch-Verdacht widerlegt, Dauerläufer bestätigt | `dms.nix:12` (Enable, selbst gelesen); nixpkgs `nixos/modules/programs/dsearch.nix` | Enable **belegt**; Lastniveau und indexierte Pfade messen (Runtime-Config wird dienstseitig generiert, repo-seitig nicht einsehbar) | Enable: Repo; Last: Maschine |
| 5 | **fastfetch in jeder interaktiven fish-Shell inkl. jedes tmux-Panels/Popups:** `fish_greeting` zahlt 50–200 ms für /sys-/proc-/Paket-/Disk-Reads; fish ist tmux-default-shell, Panes sind der Normalfall. Das Repo guardt den sesh-Autostart korrekt vor tmux, die Greeting nicht — Asymmetrie belegt: Versehen, kein Design | `term/monitoring/fastfetch.nix:23-25` (kein TMUX-Guard); `term/shell-ux/tmux.nix:10` (fish als default-shell); Guard-Vorbild `sesh.nix:51-55` | **belegt** (deterministisch); Betrag messen (`time fastfetch`) | Repo |

**Ränge 6–8 (falls das Symptom dort liegt):** docker rootless + `linger = true` ab Boot (`development/devops/docker.nix:6,16`; Präzedenz: der WSL-Host hat rootless docker soeben abgeschaltet, `.dotnix` Commit `cb367fc`) — plausibel, messen; mbsync-Timer alle 15 min + preNew-Doppelsync (`term/mailing/maildir.nix:8-9,17`) — plausibel, klein; Rebuild-/Eval-Spur: DMS-Stack ohne Binary-Cache (wöchentliche Source-Builds, §5) + `debug = true`/Tooling-Parts verteuern jeden Consumer-Eval (trifft nur die Wartungs-Spur, nicht die Desktop-Runtime; der disko-+7-s-Block ist widerlegt).

**Explizit entkräftet (keine Messzeit verschenken):** RAM-Druck durch Impermanence (läuft als btrfs-Rollback im initrd, `impermanence.nix:6-23`); niri selbst (keine Animations-Overrides, `skip-at-startup`, Mesa-Cache persistiert); DMS-Blur (aus, `dms-settings.nix:38`); Wetter-Retry-Loop (IP-Fallback + exponentieller Backoff + `nice -n 19 ionice -c3`); polkit-Agent-Problem (DMS liefert eigenen Agenten); Nix-GC-Sturm (weekly Timer, Daemon idle); settings.json-Doppel-Writer + 5→33-Migrations-Churn (echtes Wartbarkeitsproblem, aber Millisekunden-Runtime); Lock-Node-Bloat (dedupliziert im Store); Firefox-DoH/Extensions (real, aber nur relevant falls Symptom = „Browser zäh": `firefox.nix:44,64,110-128`).

### Messplan (~60 Minuten am Desktop; Reihenfolge = Informationsgewinn; je Schritt eine Zeile Ergebnis)

1. **(5′) Stand + Symptom-Regime klären.** Consumer-Clone lokalisieren; `git -C <clone> log -1`; flake.lock-Pin von `dotnix-aspects` gegen HEAD `ac7724c` vergleichen; Host-Modulliste auf `desktop`-Tier prüfen (Präzedenz: `dmi` lief 8 Commits hinterher). Symptom einordnen: träge auf **Akku** oder **Netzteil**, im **Idle** oder unter **Last**, bei welchen Interaktionen? Dazu `powerprofilesctl` an beiden Stromquellen.
2. **(8′) Idle-Inventur.** `systemd-cgtop -m --depth=3` 60 s beobachten; `pidstat 2 30 -u | sort -k8 -rn | head -15`. Erwartungsbild: dms, dsearch, handy, ggf. dockerd — alles > 1–2 % CPU im Leerlauf ist ein Fund.
3. **(7′) dsearch quantifizieren.** `systemctl --user status dsearch`; `journalctl --user -u dsearch -b | tail -30`; `pidstat -u -p $(systemctl --user show dsearch -p MainPID --value) 2 30`; `systemctl --user cat dsearch` → ExecStart/Config-Pfad folgen und lesen: **welche Pfade werden indexiert?** Dann gezielt Churn erzeugen (großes Repo `git checkout`, `nix build`) und dsearch-CPU im pidstat-Fenster beobachten. Bestätigt bei > 1–2 % Idle-CPU oder Churn-Spitzen > 25 %.
4. **(8′) Ghostty A/B (Ursache 1).** GPU-Monitor starten (`intel_gpu_top -l > /tmp/gpu.log &` bzw. radeontop/nvidia-smi je Karte), 60 s mit sichtbarem, idlendem Terminal messen; Vergleichsstart `ghostty --custom-shader-animation=false --background-blur=false --background-opacity=1`, erneut 60 s; zusätzlich Tippen/Scrollen subjektiv vergleichen. GPU-Delta > 10 % Renderlast = bestätigt.
5. **(6′) DMS A/B (Ursache 3).** `systemctl --user stop dank-material-shell` → 2 min Interaktionsgefühl (Fokuswechsel, Launcher, Workspace-Wechsel); DMS wieder starten, über die Settings-GUI testweise `cpuUsage`/`memUsage`, Marquee (scrollTitle), Visualizer deaktivieren — erneut fühlen (Layout: `barConfigs`).
6. **(10′) Thermik/Governor (Ursache 2).** `systemctl status thermald` (not-found = Lücke bestätigt, sofern nixos-hardware nichts liefert); `cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor | sort | uniq -c` + `energy_performance_preference`; `stress-ng --cpu 8 --timeout 600s &`, alle 30 s `sensors` — Takt-Einbruch bei steigender Temperatur = Throttling. Auf Akku: während eines trägen Moments `powerprofilesctl` (steht `power-saver`, ist 2a direkt bestätigt) und 2 min `powerprofilesctl set balanced` probefahren.
7. **(4′) fastfetch (Ursache 5).** `time fastfetch` 3× (kalt/warm); Pane-Öffnen spüren; Probe des Fixes: `functions fish_greeting` in einer fish leer überschreiben und Differenz fühlen.
8. **(4′) RAM/PSI.** `free -m; zramctl; swapon --show; cat /proc/pressure/memory /proc/pressure/cpu /proc/pressure/io`. io-PSI > 0 im Idle = Storage-Problem (LUKS+btrfs); memory-PSI > 5 % = RAM-Druck durch Anwendungen, nicht durch Persistenz-Strategie.
9. **(4′) Perceived-Perf-Poster.** `time xdg-open <irgendeine.pdf>` (Portal-Roundtrip; gegen direktes Öffnen vergleichen — `xdgOpenUsePortal = true`, `xdg-portals.nix:21`, bewusste Wahl); Firefox `about:performance` + typische Seite mit/ohne Extensions; `journalctl --user -u mbsync --since today | tail -20`.
10. **(4′) Fehlerlage + Widerlegungs-Checks.** `journalctl -b -p 3`; `journalctl --user -b -p warning | tail -50` (DMS-Restart-Loops?); `systemctl --user show handy -p NRestarts` (Crash-Loop?); `pgrep -af polkit` (erwartet: DMS-eigener Agent); `journalctl --user -u dank-material-shell -f` 3 min im Idle (erwartet: keine Wetter-Fehlerflut).

**Auswertungsmatrix:** Schritt 1 ordnet das Symptom dem Regime zu (Akku → Ursache 2 vorne; Idle → 3/4; Interaktion → 1/5; Rebuild → Rang 7). Schritte 2–3 entscheiden 3+4, Schritt 4 Ursache 1, Schritt 5 Ursache 3, Schritt 6 Ursache 2. Nach 60 min sind alle Top-5 bestätigt oder verworfen; Rest-Unsicherheit = Maschine.

**Diagnose-Lücken (von der Recherche aus nicht klärbar):** Laptop-Konsument unsichtbar (Azure-Remote ohne Credentials); kein Maschinenzugriff aus der Recherche-Umgebung (WSL2/bwrap-Jail — alle Runtime-Magnituden beim Besitzer); GPU-Modell unbekannt (iGPU- vs. Nvidia-Variante des 5570); dsearch-Runtime-Config maschinengeneriert; thermald-Lieferung via nixos-hardware erst am Host prüfbar; DMS-Upstream-Interna fremd-verifiziert (2 Gutachten konsistent am gepinnten Rev `a609b5f`); subjektives Symptombild (Interaktion vs. Idle vs. Browser vs. Rebuild) entscheidet die Rangfolge.

## 5. Eval & Rebuild

Konsolidierung aus cross-eval-strategie.md + oracle-eval-perf.md (dessen Messungen die Researcher-Messungsystematik korrigiert haben; vgl. §9).

### 5.1 Widerlegtes zuerst (Messartefakte)

- **disko +7 s/Host-Eval: Messartefakt.** Die Researcher-Baseline `perfW` schlug fehl (`Failed assertions: The 'fileSystems' option does not specify your root file system`, Abbruch nach 3,55 s) — `disko` ist die einzige `fileSystems`-Definition im Aspekt-Baum (`system/disko.nix:68-69`); verglichen wurde Abbruch-vs-Erfolg (10,84 s). Saubere Paarung (beide Seiten erfolgreich, interleaved 3×): **±0,0 s (±0,4 s Rauschen)** — auch nacktes Upstream-disko-Modul und Minimal-Tree kosten nichts Messbares (oracle-eval-perf). Konsequenz: kein Perf-Hebel; die Umsiedlung des Layouts auf Host-Ebene bleibt als **Wartbarkeits**-Entscheidung (§6, Maßnahme 29).
- **„bare nixosSystem 3,07–3,87 s":** ebenfalls fehlgeschlagene Evals (grub-Assertion); real 6,0–6,7 s.
- **„System-Andere ≈ +0 s": falsch.** System-Stack erfolgreich evaluiert +4,1 s über leeren Host, davon **pipewire allein +3,9 s** (nixpkgs-Upstream-Modul, nicht Library-Verschulden), network+network-wifi +0,85 s.
- **niri-flake ≈ +1,5 s: nicht reproduzierbar** (+0,0–0,9 s im Rauschen).
- **quickshell.drv als lokaler Build-Beweis: abgeschwächt** (drv-Präsenz ≠ Build auf der Messbox; die Cache-Losigkeit des Stacks ist trotzdem bewiesen — der Effekt tritt auf der Zielbox ein).

### 5.2 Reale Eval-Landschaft

Volles Host-Eval ~11 s (10,2–11,8 s); Bibliotheks-Scaffolding (import-tree + flake-parts über 141 Dateien) +0,1 s sauber gemessen (0,15–0,5 s unter Last); stylix ≤ 0,3 s; DMS ≈ +0,1 s; impermanence ≈ +0,2 s. **Die Bibliothek ist eval-seitig sauber; der größte Einzelblock (pipewire) ist nixpkgs.** Empfehlung (oracle-eval-perf): Eval-Realität dokumentieren und akzeptieren, kein weiteres Eval-Tuning. ISO-Pfad (`parts/configuration.nix:55-60`): forciert für `iso.enable`-Hosts eine zweite Voll-Eval bei `flake check/show` — heute 0 Hosts = 0 Kosten, bei künftigen ISO-Hosts einkalkulieren.

### 5.3 Rebuild-Pfad (der echte „Update fühlt sich träge an"-Mechanismus)

- **AvengeMedia-Trio (dms, dms-plugins, dank-greeter) ohne Binary-Cache** — bewiesen: kein nixConfig/substituter/Cachix in allen drei Flakes am gelockten Rev; ein öffentlicher Upstream-Cache existiert schlicht nicht (ist auch nicht konfigurierbar). Jede Input-Welle baut dms-Paket (QML/Wrapper) + greeter (Go-Binary) + 6 Plugins lokal aus Source. Dämpfung: die Quickshell-Engine kommt aus nixpkgs (`dms-greeter.nix:30`) und ist cache.nixos.org-gedeckt — kein wöchentlicher C++-Engine-Rebuild (oracle-lock-hygiene W3).
- **Helix-Eingefroren:** Der wöchentliche Bot bewegt den helix-Node seit PR #18 nicht mehr (9 Wellen, Lock `079a789` = 2026-07-23) — trotz unpinned URL und täglich aktivem Upstream. Zeitlich passend zum @main-Floating der update-Action (Hypothese; 1-Minuten-Diagnose beim Besitzer: `nix flake lock --update-input helix`). Planbarkeitsrisiko: der Freeze kann jederzeit springen → ungeplanter Rust-Rebuild + 2 Monate stale Editor.
- **Auto-Merge mit eval-only-Gate:** Cron `0 4 * * 1`, `update-flake-lock@main` floating, `gh pr merge --auto --squash` nach `nix flake check` (baut keine Closures). Build-Brüche erscheinen erstmals beim `nixos-rebuild` am Arbeitsgerät; 22/186 Commits sind Update-Merges.
- **`debug = mkDefault true`** (`parts/flake-parts.nix:5`): forciert den Introspektions-Spiegel auf jedem `flake show`/repl/outputs-Walk im Konsumenten; kleiner echter Hebel, ungemessen, null Effekt auf den Switch selbst.

### 5.4 Hebel (sortiert; „P" = vor allem Planbarkeit)

| # | Hebel | Wirkung | Aufwand |
|---|---|---|---|
| 1 | **Update-Kadenz halbieren** (P): Cron `0 4 * * 1` → `0 4 1,15 * *` (`.github/workflows/flake-update.yml:6`) | halbiert lokale DMS-Source-Build-Frequenz + Lock-Diff-Review-Last; Aktualität bleibt ausreichend (unstable ist rollierend); `workflow_dispatch` für Ad-hoc-Wellen bleibt | 0,1 h |
| 2 | **Helix-Entscheidung + Action pinnen** (P): `update-flake-lock@main`/`flake-checker-action@main` auf SHAs; helix-Input streichen (nixpkgs-Helix) oder bewusst bumpen | beendet die 9-Wellen-Anomalie; bei Drop: kein ungeplanter Rust-Rebuild, volle cache.nixos.org-Deckung („master"-Vorteil bei 2 Monate altem Lock faktisch null) | 0,5–2 h |
| 3 | **CI vor Auto-Merge bauen statt nur evaluieren** (P): `nix build .#nixosConfigurations.<host>.config.system.build.toplevel` (oder nix-fast-build) + Consumer-Fixture | Build-/Merge-Brüche (Option-Defekte, HM-Merge-Fehler) werden vor dem Merge gefangen statt montags am Desktop; die Welle wird planbar; testet zugleich den öffentlichen flakeModule-Vertrag | 2–4 h |
| 4 | **`debug = mkDefault false`**: Zeile in `modules/parts/flake-parts.nix:5` streichen | schnellere `flake show`/`check`/repl/outputs-Walks im Consumer (Spiegel entfällt); kein Effekt auf den Switch | 0,1 h |
| 5 | **Lock-Hygiene-Runde:** toter `agenix.inputs.home-manager.follows`-Override weg (`flake.nix:5`, druckt bei jeder Eval eine Warnung — reproduziert); agenix-rekey-Dev-Kette per follows kollabieren (devshell/treefmt-nix/pre-commit-hooks — DevShell-only, nie im Modulpfad); `niri.inputs.nixpkgs-stable.follows = "nixpkgs"` + Guard-Kommentar (niri-stable ungenutzt, grep-verifiziert) | **messbare Perf-Wirkung ehrlich ~0**; Dividende: Warnung weg, −6…−7 Nodes, eine Dev-Toolchain, eine nixpkgs-Instanz, kleinere wöchentliche Diffs; danach einmal `nix run .#rekey`-Dry-Run | 0,7–1,5 h |
| 6 | **ISO-Doppel-Eval dokumentieren** (`parts/configuration.nix:8`): buildOutput-Konvention + Kostenhinweis als Kommentar/README | verhindert künftige Eval-Überraschungen sobald ISO-Hosts dazukommen | 0,1 h |
| 7 | **disko-Umsiedlung** (kein Perf-Hebel!): Aspekt auf Modul-Import reduzieren, GPT/LUKS2/btrfs-Layout nach `modules/hosts/<host>/` (Vorlage `system/disko.nix:29-67`); vorher Gegenprobe `time nixos-rebuild dry-activate` vor/nach | Wartbarkeit: Hosts deklarieren ihr Layout statt es zu erben/überschreiben; Eval gemessen ±0 | 2–3 h |

Sequenz: 1+2 zuerst (sofortige Planbarkeits-Dividende, null Verhaltensrisiko) → 3 (der eigentliche Planbarkeits-Hebel, braucht die Fixture aus §6) → 4+5+6 im nächsten Anlass-PR → 7 als Besitzer-Entscheidung.

### 5.5 Bewusst NICHT (eval-/rebuild-seitig)

Lock-Diät auf ~30 Nodes um jeden Preis (stylix/NUR-Transitive per follows kollabieren — die gefrorene Kombination läuft seit 24 Wellen eval-grün; reine Ästhetik mit Pairing-Risiko) · DMS-Stack auf nixos-release pinnen (bricht die eine-nixpkgs-Follows-Architektur, zwei Desktop-Welten) · eigener Cachix für AvengeMedia (kein Upstream-Cache existiert; Betriebsaufwand > Nutzen bei 1 Workstation/1 Desktop; erst bei zweitem Host/CI-Buildfarm) · selektives Pinning einzelner Substrate gegen „Full-Rebuilds pro Welle" (Follow-Kopplung ist die Architektur).

### 5.6 Grenze zur Desktop-Trägheit

Alles oben wirkt auf den **Update-/Wartezeit-Pfad** (nix-Operationen), nicht auf den laufenden Desktop: Nach dem Switch ist der Desktop exakt so schnell wie vorher. Lock-Hygiene hat null Perf-Wirkung; Dateizahl/Import-tree ist gemessen kein Faktor; die Runtime-Ursachen liegen inhaltlich in §4. Wer „Rebuild/eval schneller + planbarer" von „Desktop flink im Betrieb" trennt, setzt die Messlatte richtig.

## 6. Priorisierter Maßnahmenplan

Gesamttabelle über alle Querschnitte, sortiert nach Wann (Sofort = ohne Abstimmung/heute; Kurz = PR-gebunden, 1–3 Wochen; Mittel = nach Stabilisierung). Wirkungen: S = Struktur, W = Wartbarkeit, P = Performance (Runtime bzw. Eval/Rebuild gekennzeichnet).

| # | Maßnahme (Belegort) | S | W | P | Aufwand | Wann |
|---|---|---|---|---|---|---|
| 1 | Laptop-Konsumenten identifizieren (Flake-Quelle, gefahrener Pin); `.dotnix`-Lock committen (`0c33875` → HEAD; `M flake.lock` mitcommitten) | Rahmen | Rahmen | Voraussetzung aller Desktop-Wirkung | 0,5–1 h | **Sofort** (Phase 0) |
| 2 | Auto-Merge für die Umbau-Dauer stilllegen (`workflow_dispatch` only) + Baseline-Messung am Ziel-Desktop (`systemd-cgtop`, `powerprofilesctl` AC/Akku, `time nixos-rebuild dry-activate`) | – | mittel | Messbasis | 0,5 h | **Sofort** (Phase 0) |
| 3 | Ghostty: `custom-shader-animation = false` + Blur-Entscheidung (`desktop/terminal/ghostty.nix:16-22`) | – | – | Runtime: hoch (GPU-Grundrauschen) | 10 min | **Sofort** (Phase 1) |
| 4 | Akku-Profil: im trägen Moment `powerprofilesctl`; dann `"balanced"` setzen oder `power-saver` als bewusst dokumentieren (`dms-settings.nix:209`) | – | – | Runtime: hoch (mobil) | 30 min | **Sofort** (Phase 1) |
| 5 | fastfetch-TMUX-Guard: `body = "if not set -q TMUX; fastfetch; end"` (`term/monitoring/fastfetch.nix:25`; Vorbild `sesh.nix:51-55`) | – | gering | Runtime: mittel (jedes Pane) | 15 min | **Sofort** (Phase 1) |
| 6 | LSP-Doppelung auflösen: `nil` raus (nixd bleibt), `marksman` raus (markdown-oxide bleibt), `statix`/`deadnix` aus extraPackages (`editors/helix-lsp/nix.nix:3,16-18`, `markdown.nix:5,16`) | – | gering | Runtime: mittel (Buffer-Server halbiert) | 1 h | **Sofort** (Phase 1) |
| 7 | `debug = lib.mkDefault true` streichen (`modules/parts/flake-parts.nix:5`) | gering | gering | Eval: klein (Consumer-Outputs-Walks) | 0,1 h | **Sofort** (Phase 1) |
| 8 | `narinfo-cache-negative-ttl` 30 s → Default 3600 (`core/nix.nix:30`) | – | – | Build-Latenz bei Misses | 5 min | **Sofort** (Phase 1) |
| 9 | mbsync auf EINEN Sync-Pfad festlegen (Timer `*:0/15` lockerer ODER `hooks.preNew` weg — Besitzer-Entscheid; `term/mailing/maildir.nix:9,17`) | – | gering | Runtime: 15-min-Grundlast halbiert | 15 min | **Sofort** (Phase 1) |
| 10 | dsearch als Runtime-Entscheidung: Runtime-Config lesen (welche Pfade?), auf Dokumente begrenzen ODER `graphical-session.target` ODER deaktivieren (`dms.nix:12`; NICHT als toten Code löschen) | – | – | Runtime: Idle-Last | 30 min | **Sofort** (Phase 1) |
| 11 | docker-linger/StartLimits + Bar-Widgets nur nach Messbefund (§4 Schritte 2/5; `docker.nix:16`, `handy.nix`) | – | – | Runtime: bedingt | 30 min | **Sofort** (Phase 1) |
| 12 | Consumer-Lock-Update nach Landung der Phase-1-Fixes (sonst wirkt nichts am gefahrenen System) | – | – | Wirkung erst dann live | 15 min | **Sofort** (Phase 1) |
| 13 | Template komplett reparieren: `members = [ "myuser" ]` UND `core` in Host-Liste (`templates/dotnix/.../configuration.nix:4-9`) | hoch | hoch | – | 30 min | **Kurz** (Phase 2) |
| 14 | README auf Realität: Phantom-Referenzen umbiegen, Core-Injektions-Behauptung streichen (bewusst entfernt in `880c2b1`), Pfad-/Layout-Kontrakt, Kompositions-Matrix (core standalone, system⇒Hardware, impermanence⇒disko), Tier≠Group-Absatz, Impermanence-Audit-Einzeiler `grep -rn 'home.persistence' modules/` | hoch | hoch | – | 1–2 h | **Kurz** (Phase 2) |
| 15 | CI-Consumer-Fixture: `nix flake new /tmp/fixture -t .#dotnix` + `nix eval .#nixosConfigurations.myHost.config.system.build.toplevel.drvPath`; falschen `covers:`-Kommentar ersetzen (`flake-check.yml:26-27`) | hoch | hoch | – | 2–4 h | **Kurz** (Phase 2) |
| 16 | `hostname`-Typfehler fixen (`nullOr str` oder Default streichen, `parts/configuration.nix:33`); tote Module (`yubikey-lock.nix`, `tuigreet.nix`, `boot-limine.nix`) + No-Op `bash.nix` löschen | mittel | mittel | – | 1 h | **Kurz** (Phase 2) |
| 17 | Actions pinnen (SHAs); Build-Gate vor Auto-Merge (Fixture zu `nix build`/nix-fast-build aufwerten); Kadenz `0 4 1,15 * *` | – | hoch | Rebuild/Pipeline: Planbarkeit | 3–4 h | **Kurz** (Phase 3) |
| 18 | Helix-Eigen-Input streichen: `flake.nix:36-37`, Overlay+Substituter-Block `editors/helix.nix:1-8`, Import aus `development.nix`; Smoke-Test `hx --version` = nixpkgs-Release (bei konkretem master-Feature-Bedarf: follows streichen + bewusster Bump) | – | mittel | Rebuild: kein Rust-Rebuild-Risiko | 1 h | **Kurz** (Phase 3) |
| 19 | Lock-Pflege selektiv: toter agenix-Override (`flake.nix:5`); agenix-rekey-Dev-Kette follows; `niri.inputs.nixpkgs-stable.follows = "nixpkgs"` + Guard; dank-qml-common vereinheitlichen (Greeter-Build als Probe); niri-Fork dokumentieren oder auf `sodiboo` zurückrollen; danach rekey-Dry-Run | – | mittel | ~0 (ehrlich); Review-Dividende | 1,5–2 h | **Kurz** (Phase 3) |
| 20 | Export-Split Produkt/Dev: `expose.nix` — Produkt = aspects + `parts/{flake-parts (ohne debug-Zeile), configuration, age}` (+ home-manager konservativ); Dev-Tooling als Opt-in `flakeModules.devTools`; Konsument +1 Import-Zeile; Laptop-Repo vorher greppen | hoch | mittel-hoch | Eval: Consumer-Nebenlast weg | 3–4 h | **Kurz** (Phase 4) |
| 21 | Personal-Config lösen: `masterIdentities` als `dotnix`-Option (Registrierung in `parts/configuration.nix`), persönliche Pubkeys/Pfade ins Konsumenten-Repo; `age-rekey.nix:9` unguarded `readFile` mit `pathExists`-Guard (Muster `certificates.nix:6`) | mittel | mittel-hoch (Public-Release-Blocker) | – | 3 h | **Kurz** (Phase 4) |
| 22 | dms-settings 457 → ~40 LOC echte Deltas, gegen den GEPINNTEN DMS-Rev diffen (`barConfigs`/`appIdSubstitutions`/`controlCenterWidgets`/`cursorSettings`/`powerMenuActions` vorher gegen Upstream-Defaults); `configVersion`-Zeile (`:454`) und `mkDefault`-Wraps streichen; **nie im selben PR wie ein DMS-Bump**; DMS-GUI-Gegenprobe | – | hoch | Startup-Churn weg (ms, kein Trägheits-Hebel) | 2–4 h | **Kurz** (Phase 4) |
| 23 | mkForce-niri-Block löschen nach gerenderter `config.kdl`-Gegenprobe (Upstream generiert identische Config inkl. Border-Fix; `dms.nix:41-64`) | – | mittel | – | 1 h | **Kurz** (Phase 4) |
| 24 | Theming-SSOT erklären: DMS-matugen (Shell + ~20 Template-Ziele) als SSOT; Stylix auf nicht abgedeckte Targets reduzieren; `qt-theme.nix` erst nach Stylix-Qt-Prioritätsprüfung löschen („wirkungslos" nur plausibel, nicht bewiesen) | – | mittel | – | 1–2 h | **Kurz** (Phase 4) |
| 25 | Hibernation vervollständigen: `boot.kernelParams = [ "resume_offset=<filefrag -v /swap/swapfile>" ]` pro Hardware-Host (Konsumenten-Repo) + Warn-Kommentar an `boot.resumeDevice` (`system/power.nix:29`); Test Hibernate → Kaltstart → Session intakt | – | hoch (stiller Session-Verlust) | – (Funktionslücke, kein Trägheits-Hebel) | 1–2 h | **Kurz**, host-seitig parallel |
| 26 | Namens-Hygiene-Sweep: `skills.nix`→`ai-tools.nix`, `k9s.nix`→`kubernetes.nix`, `gpg.nix`→`gnupg.nix`+`gpg-agent.nix`, `yubikey-pam` eigene Datei, `television-nix.nix`→`nix-search-tv.nix` mit eigenem Aspekt `homeManager.nix-search-tv` + `terminal.nix` anpassen; Tier-Listen im selben Commit | mittel | mittel | – | 1–2 h | **Mittel** (Phase 5, erst wenn Export-Split-PR eine Woche stabil) |
| 27 | 3 Fehlplatzierungen verschieben: `core/fonts.nix`→`desktop/`, `core/nix-ld.nix`→`development/`, `core/performance.nix`→`system/`; git-Familie + `llm-agents` zu core/ moven oder im `core.nix`-Kommentar als bewusste „Arbeitsplatz-Basis" deklarieren | mittel | mittel | – | 1–2 h | **Mittel** (Phase 5, im selben Commit wie Tier-Listen) |
| 28 | Options-API-Doku: `description` für `core/users-profile.nix:3-8` + `parts/configuration.nix` (iso/host-Submodule); `theme`-Option konsumieren (SSOT mit `stylix.nix:8`/`tuicr.nix:13`) oder streichen; Hausstandard: `tmux-popups.nix` | gering | mittel | – | 1–2 h | **Mittel** (Phase 5) |
| 29 | disko-Umsiedlung (Besitzer-Entscheidung): Layout nach `modules/hosts/<host>/` (Vorlage `system/disko.nix:29-67`), Aspekt behält Modul-Import + Optionen; Gegenprobe `time nixos-rebuild dry-activate` vor/nach. Eval-Delta gemessen ±0 — reine Wartbarkeits-/Semantik-Frage (Perf-These widerlegt) | mittel | mittel | – (±0) | 2–3 h | **Mittel** (Phase 5) |
| 30 | ISO-Default dokumentieren oder streichen: `buildOutput`-Default `"images.iso-installer"` zeigt auf einen Pfad, den kein Modul beider Repos bereitstellt; `iso.enable` wird nie gesetzt (`parts/configuration.nix:8,55-60`) | gering | gering | künftige doppelte ISO-Evals vermeiden | 30 min | **Mittel** (Phase 5) |
| 31 | Kleinreparatur-Kombo: journald `SystemMaxUse=1G`; handy `StartLimitIntervalSec/Burst`; Finder-Konsolidierung (`programs.skim.enableFishIntegration = false`, `fishPlugins.fzf` aus `fish.nix`); Popup-Gates bluetui/wifitui (`tmux-popups.nix:74,84`); toter Firefox-Pref `media.autoplay.enabled` (`firefox.nix:70`); gvfs-Doppelung (`thunar.nix:13`); polkit-Kommentar korrigieren (`niri.nix:15`); `narinfo`-Rest, difftastic-Veto, mail-Takt | – | gering | teils Runtime klein | 1–2 h | **Mittel**, verteilt |
| 32 | thermald nur nach Messung (§4 Schritt 6 zeigt Throttling → 1 Zeile in `system/power.nix`) | – | – | Runtime: ggf. hoch unter Last | 1 Zeile | **Mittel**, nach Messung |

Aufwand gesamt (Judge-Mischplan): **~6–8 Personentage** — Phase 0: 0,5 · Phase 1: ~1 · Phase 2: ~1 · Phase 3: 1,5–2 · Phase 4: ~1,5 · Phase 5: ~1. Uncommittete `sesh.nix` vorher separat landen lassen; Resume_offset und thermald laufen als Owner-Aktionen parallel.

## 7. Strategie-Empfehlung

**Score des Duells (judge.md; Summe ist nicht die Entscheidung — Gewichtung folgt der Sorgen-Liste des Besitzers: Struktur und Wartbarkeit zuerst):**

| Kriterium | A Konservativ | B Umbau | C Konsolidierung |
|---|---|---|---|
| Wirkung gegen Struktur-Sorge | 5 | **8** | 2 |
| Wirkung gegen Wartbarkeits-Sorge | 7 | **9** | 6 |
| Wirkung gegen Desktop-Trägheit | **8** | 3 | 3 |
| Bruchrisiko (10 = risikoarm) | **9** | 6 | 8 |
| Aufwandseffizienz (10 = gering) | **8** | 7 | 8 |
| **Summe** | **37** | **33** | **27** |

**Gewinner: B (Umbau) — als Rückgrat, mit A's Runtime-Paket als Pflicht-Import an Position 1 und C's Substrat als drittem Viertel.** Kante gegen A trotz höherer Summe: A verweigert genau die Disziplin-Ebene, die die Orakel der Struktur-Klage zuschreiben (Namens-Lügen, Export-Leak) — und A's Template-Fix wäre unvollständig gewesen (nur `core`, ohne Case-Fix; `attrVals` hätte weiterhin geworfen, judge.md Widerspruch 2). A's Runtime-Hebel sind fast alles Ein-Zeiler, die sich an jeden Plan ankleben lassen — umgekehrt lässt sich B's Strukturarbeit nicht in A retuschieren, ohne A's eigene Anti-These aufzugeben. A's Eigenverbrauchs-Prämisse ist auf `refactor/public-release` falsch (drei Orakel empfehlen übereinstimmend den Produkt/Dev-Split). C ist kein Ganzes, aber das orakelkonformeste Substrat-Papier (allein die helix-Freeze-Wurzel-Diagnose) und deckt die Pipeline-Achse, die A und B nur nachlaufend behandeln.

### Mischplan (Reihenfolge mit Begründung, ~6–8 Personentage)

| Phase | Inhalt (Herkunft) | Aufwand |
|---|---|---|
| 0 — Rahmen | Laptop-Konsument identifizieren; `.dotnix`-Lock committen; Auto-Merge stilllegen (`workflow_dispatch` only); Baseline-Messung (systemd-cgtop, powerprofilesctl AC/Akku, `time nixos-rebuild dry-activate`) — alle drei Papiere | ~0,5 d |
| 1 — Trägheits-Quick-Wins | Der gefühlte Schmerz ist der akute; Hebel sind Minuten-Arbeit: Ghostty-Shader/Blur, Akku-Profil nach `powerprofilesctl`-Befund, fastfetch-Guard, LSP-Dopplung, mbsync, docker-linger/StartLimits + Bar-Widgets nach Messbefund, dsearch als Runtime-Entscheidung (A Phase 1) | ~1 d |
| 2 — Vertragsreparatur | Template Case-Fix UND `core`; README auf Realität inkl. Pfad-/Layout-Kontrakt und Tier≠Group-Absatz; CI-Consumer-Fixture (erst eval-only, `drvPath`); `hostname`-Typfehler; tote Module + `bash.nix`; falscher CI-Kommentar (B Phase 1) | ~1 d |
| 3 — Substrat/Pipeline | Actions pinnen; Build-Gate vor Auto-Merge (Fixture zu echtem `nix build`/nix-fast-build aufwerten); helix-Eigen-Input streichen; toter agenix-Override weg; `nixpkgs-stable`-follows + Guard; agenix-rekey-Dev-Kette; dank-qml-common; niri-Fork dokumentieren/zurückrollen; Kadenz `0 4 1,15 * *`; Kanal-Strategie dokumentieren; push-before-rebuild-Regel (C Phasen 1–4). Bewusst NICHT: Lock-30-Nodes-Diät, Stylix/NUR kollabieren, eigener Cachix | 1,5–2 d |
| 4 — Export + Desktop-Stack | Export-Split (Aspekte + `parts/{flake-parts,configuration,age}`; `flake-parts.nix` MUSS bleiben; Dev-Tooling als Opt-in-`devTools`); dms-settings 457→~40 echte Deltas gegen den GEPINNTEN Rev (nie im selben PR wie ein DMS-Bump); niri-mkForce-Block nach `config.kdl`-Gegenprobe löschen; qt-theme nach Stylix-Prioritätsprüfung; Theming-SSOT-Doku (B Phase 2+4) | ~1,5 d |
| 5 — Namens-/Taxonomie-Hygiene | Renames/Splits; 3 Fehlplatzierungen im selben Commit wie die Tier-Listen; Options-API-Doku; disko-Entscheidung (Layout pro Host oder bewusst akzeptiert, mit `dry-activate`-Gegenprobe); ISO-Default dokumentieren oder streichen (B Phase 3) | ~1 d |

Parallel als Owner-Aktionen: `resume_offset` (Hibernate, konsumenten-seitig), thermald (nur nach Messung).

### Übergangskriterien (wann die nächste Phase startet)

- **0→1:** Laptop-Flake-Quelle identifiziert (oder nach 2 Wochen erfolgloser Suche als „blind" deklariert); Baseline-Notizen existieren. Ohne dieses Kriterium laufen Phase-1-Fixes ins Leere.
- **1→2:** Quick-Wins über den aktualisierten Consumer-Pin am Laptop angekommen und Trägheit re-bewertet (subjektiv + eine cgtop/pidstat-Kontrollmessung). Bleibt Rest-Trägheit: zuerst Messlücken schließen (thermald, dsearch-Pfade), nicht neue Hebel raten.
- **2→3:** Fixture-Job grün (er beweist zugleich den Case-Fix); README/Template wahr; Auto-Merge reaktivierbar.
- **3→4:** Zwei Bot-Wellen sauber durchs neue Build-Gate gelaufen; helix-Anomalie geklärt/beseitigt; Laptop-Repo auf devshell/formatter-Nutzung gegriffen (leer → Split sicher; Treffer → Opt-in-Import dokumentieren, dann Split).
- **4→5:** Konsumenten auf aktuellem Pin; dms-settings-Diff am Live-Desktop vom Besitzer abgesegnet; Export-Split gelandet. Renames erst, wenn der Split-PR eine Woche stabil ist.

### Verbotene Gleichzeitigkeiten (cross-umbau-plan)

1. `expose.nix`-Split × Konsumenten-Lock-Bump: nie beides in flight — sonst ist ein Bruch nicht zuordenbar.
2. dms-settings-Reduktion × DMS/dms-plugins-Input-Bump: die Reduktion wird gegen den GEPINNTEN Rev gedifft; Struktur-PRs generell nicht in der Montags-Wellen-Woche landen.
3. Aspekt-Renames × Export-Split: beide ändern die öffentliche Key-Oberfläche — nacheinander, je mit eigener Fixture-Grün-Phase.
4. Taxonomie-Moves × Tier-Importlisten: nur im selben Commit (sonst verschwindet der Aspekt still).
5. Follows-Änderungen × rekey: nach jeder Änderung einmal `nix run .#rekey`-Dry-Run.
6. dsearch-Deaktivierung × dms-settings-Reduktion: nicht gleichzeitig — wenn die Launcher-Suche bricht, muss die Ursache eindeutig sein.
7. Helix-Entfernung × LSP-Konsolidierung: gleiche Subsysteme — in EINEM Rebuild verifizieren.
8. `M modules/aspects/term/shell-ux/sesh.nix` (uncommittete User-Arbeit): vorher einbinden oder separat landen lassen, in keinem Phase-PR berühren.

### Risiken (judge.md)

Laptop-Konsument bleibt das Mutter-Risiko (alle Desktop- und Export-Aussagen sind Bibliotheks-Aussagen bis dessen Quelle und Pin bekannt) · ungemessene Magnituden: `debug`-Eval-Kosten, fastfetch-Latenz (50–200/300 ms geschätzt), dsearch-Last, Stylix-Qt-Priorität — je durch eine Messung/`nix eval` klärbar · helix-Freeze-Wurzel ohne Owner-nix-Lauf nicht final beweisbar · dms-settings-Reduktion kann bewusst gesetzte LIVE-Keys streifen — abgesichert durch maschinellen SPEC-/settings.json-Diff + Besitzer-Review; Rollback = ein Revert.

## 8. Anti-Empfehlungen

Aus cross-anti.md. Kernbotschaft: Die Architektur ist nicht das Problem — sie ist das Asset. Fast jede naheliegende „Struktur-Modernisierung" wäre Geld für nichts.

### Nicht tun

**Architektur & Struktur**
- **A1** Hosts in dieses Repo ziehen / Bibliothek zum Dotfiles-Flake machen — kippt die einzige Form, in der 132 Aspekte für einen Public Release Sinn ergeben; `config.dotnix` ist bewusst leer (`parts/configuration.nix:37-49` = reine Factory).
- **A2** Granularität radikal ändern — Eval-Kosten von 141 Dateien: 0,15–0,5 s gemessen; ein-Tool-eine-Datei ist der Kernwert; einzige Störung läuft in die Gegenrichtung (television-Fusion = Rename, kein Umbau).
- **A3** Alles auf eigene `enable`-Flags umstellen — Repo lebt „enabling is importing" (genau 2 `mkEnableOption` im Baum: `tmux-bindings.nix:40`, `tmux-popups.nix:31`; null eigene Flags in core/system); Gating-Werkzeug existiert bereits (`mkIf config.programs.<upstream>.enable`, `fastfetch.nix:23`). Nachzuziehen sind nur die ungegaten Popup-Einträge bluetui/wifitui.
- **A4** Host-Registry auf Host-Features migrieren — Registry ist die Factory-Seite (members-getriebene Secrets-Generierung: `users.nix`, `age.nix`, `nh.nix`, `docker.nix`); Migration = mehrtägiger Breaking Change ohne Bedarf; Case-Bug-Klasse stirbt an der CI-Fixture für ein Hundertstel des Aufwands.
- **A5** Kompositions-Assertions/Constraint-Layer bauen — core IST standalone (alle /persist-Fragmente liegen im Modulnamen `impermanence`; Live-Beweis: `dmi` fährt core ohne system); der echte Vertrag gehört als Kompositions-Matrix ins README.
- **A6** Gruppen↔Tier per Massenverschiebung angleichen — unattainbar und zerstört die Themen-Ordnung (`fish` bleibt Login-Shell, egal welches Tier es zieht); nur Doku-Absatz + 3 punktuelle Moves, nicht als Modernisierung verkaufen.
- **A7** Impermanence in 22 nach Collector benannte Beitragsdateien rekonstruieren — Inline ist für Entfernbarkeit besser (App löschen = Persistenz-Spuren weg); Audit ist ein grep-Einzeiler.

**Bibliotheksschnittstelle & Wiring**
- **B1** `parts/` pauschal aus dem Export entfernen — `parts/flake-parts.nix` ist die einzige Quelle der `flake.modules`-Option (sonst alle 132 Aspekte tot), `parts/configuration.nix` die Factory, `parts/age.nix` die rekey-App. Richtiger Split: Produkt/Dev.
- **B2** `core` in die Factory re-injizieren — `880c2b1` hat es bewusst entfernt; Re-Injektion wäre der eigentliche Breaking Change (Hosts, die bewusst kein core wollen, kämen es nicht mehr los). Falsch sind Doku und Template, nicht der Code.
- **B3** Export-Split/`debug=false` als Trägheits-Heiler buchen — es macht Consumer-Nix-Befehle schneller, die Desktop-Runtime bleibt exakt gleich.

**Lock & Inputs**
- **C1** `nix flake update` als Lock-Diät — die „alten" Nodes sind eingefrorene Upstream-Lock-Pins (byte-identisch mit agenix-rekey/stylix/NUR-Locks); `update` kann sie prinzipiell nie bewegen. Helix ist der andere Fall: dort ist der Freeze ein Pipeline-Defekt.
- **C2** Transitiv-Pins blind per follows kollabieren (58→~30) — Lock ist Metadaten, identische Revs deduplizieren im Store; stylix/NUR/agenix-rekey evaluieren gegen ihre getesteten flake-parts-Stände (24 Wellen eval-grün). Einzige risikoarme Ausnahme: agenix-rekey-Dev-Kette (DevShell-only, nie im Modulpfad), danach rekey-Dry-Run.
- **C3** Unstable→stable oder DMS-Stack auf release pinnen — bricht die eine-nixpkgs-Follows-Architektur (zwei Desktop-Welten); der Schmerz (wöchentliche Source-Builds) wird über Kadenz + Build-Gate gelöst.
- **C4** Eigenen AvengeMedia-Cachix bauen (kein öffentlicher Upstream-Cache existiert; Betriebsaufwand > Nutzen bei 1 Workstation) — und: Helix-Input behalten + „Bump-Rhythmus etablieren" ist ein Schwur auf eine Automatik, die nachweislich 9 Wochen nicht geliefert hat.

**Desktop, Runtime, Konvention**
- **D1** Stylix komplett wegwerfen oder drittes Theming-System einführen — Stylix ist eval-entlastet (≤0,3 s) und themed GTK/Firefox-Targets, die matugen nicht abdeckt; richtig ist die SSOT-Entscheidung + `qt-theme.nix`-Klärung.
- **D2** dms-settings „managen" statt kürzen (configVersion hochziehen, mkDefault-Flut, Voll-Pinning) — Pflege eines toten v5-Spiegels; `configVersion` NICHT pinnen (DMS verwaltet ihn selbst). Konservativ falsch ist auch der mkForce-niri-Block: Upstream liefert denselben Output — Block löschen, nicht „beim nächsten Bump mittesten". Klarstellung: dms-settings ist über den Collector-Namen `homeManager.dms` (`dms-settings.nix:2` = `dms.nix:20`) **immer live**, sobald `dms` importiert wird — Kürzung mit DMS-GUI-Gegenprobe fahren.
- **D3** polkit-gnome nachrüsten — DMS liefert eigenen Agenten (`PolkitService.qml`, nur via `DMS_DISABLE_POLKIT=1` abschaltbar); zu tun ist nur der Kommentar `niri.nix:15-16`.
- **D4** Firewall-Ports (5353/mDNS) ohne Laufzeit-Beweis öffnen — aktive Queries laufen als ESTABLISHED durch die Stateful-Firewall; blockiert sind nur unsolicited Announcements; `publish.enable = false` ist bewusste Posture (`network.nix:70-72`).
- **D5** An der gutgestellten Fläche weitergraben — zram 25 %/zstd/prio 100, Daemon auf idle, auto-optimise aus (begründet), weekly Timer, DMS-Blur global aus, Ripple klickgetrieben, Wetter mit Backoff unter nice/ionice: alles adversarial entlastet. Einzig offen: thermald — erst `systemctl status thermald` + stress-ng-Messung, dann die 1-Zeile.
- **D6** `resume_offset` in die Bibliothek hardcoden — maschinenabhängig (filefrag-Wert), gehört host-seitig in den Consumer; in die Library nur der Warn-Kommentar (`power.nix:29`).
- **D7** Tote Alternativ-Aspekte „lebendig machen" (Tier-Varianten für boot-limine/tui-greeter bauen) — spekulative Flexibilität; entscheidet: löschen oder als wählbare Exporte listen.

### Bewusst lassen

Granularität und Datei-für-Datei-Struktur (L1) · Host-Registry + Factory (L2; ISO-`buildOutput`-Default = Doku-Pflicht oder Streichung, kein Umbau) · Inline-Impermanence samt Audit-Einzeiler (L3) · Options-Collector mit Duplikat-Validierung + `helix-lsp/`-Verzeichnis als hausinterne Bestform (L4) · Gruppen als Themenregale, Tiers als Kompositionslayer (L5) · Unstable als Basis + volle nixpkgs-Follows (L6) · gefrorene Transitiv-Pins von agenix-rekey/stylix/NUR (L7) · Nix-Runtime-Tuning und Timer-Politik (L8; einzige nachziehenswerte Einzelheit: narinfo-TTL) · btrfs-Rollback-Impermanence statt tmpfs (L9) · niri-unstable über eigenen Cachix inkl. Mesa-Cache-Persistenz (L10; der niri-**Fork** ist dagegen eine 1-Zeilen-Entscheidung: begründen oder zurückrollen) · konsumenten-seitiges Collector-Vorbild (`.dotnix` devops: 4 Dateien, 1 Modulname) (L11) · defensive Idiome und Geschmacksfragen (`LC_*`-Spiegelung über die offizielle Option, redundante nixpkgs-Defaults, `uutils-coreutils-noprefix` mit Kommentar, zellij/dust/dua-Dopplungen, doppelte ZFS-Zeile) — nur opportunistisch in Vorbeiflug-Commits (L12) · uncommittete `sesh.nix` (L13).

### Erwartungs-Management

**E1** Ohne Laptop-Konsumenten-Klärung kann kein Bibliotheks-Umbau am gefahrenen System wirken. **E2** Struktur-Refractorings heben das Trägheitsgefühl nicht — sind trotzdem Pflicht, weil sie den Verrottungs-Root-Cause (ungetesteter Export-Vertrag) schließen. **E3** Lock-Hygiene hat null Perf-Wirkung. **E4** Dateizahl/Import-tree ist kein Faktor. **E5** dms-settings-Kürzung killt Churn, keine Trägheit. **E6** Die wahren Runtime-Hebel bringen Sekundenbruchteile pro Interaktion plus besseres Akku-Verhalten — sie beheben das Symptom, verwandeln aber keine Maschine. **E7** `resume_offset` ist eine Funktionslücke (stiller Session-Verlust), kein Trägheits-Hebel.

## 9. Widerlegtes & Korrigiertes

Researcher-Thesen, die von Orakeln/Querschnitten/Judge widerlegt oder korrigiert wurden (Quelle → Korrektur → Instanz):

| These (Quelle) | Widerlegung/Korrektur (Instanz) | Konsequenz |
|---|---|---|
| disko +7 s pro Host-Eval, größter Eval-Hebel (eval-perf HIGH; übernommen in cross-eval Hebel 2, cross-wartbarkeit Nr. 10) | **Messartefakt:** perfW-Baseline ist ein fehlgeschlagener Eval (fileSystems-Assertion, 3,55 s Abbruch) vs. perfDX-Erfolg (10,84 s); saubere Paarung interleaved 3×: ±0,0 s, auch nacktes Upstream-disko ±0 (oracle-eval-perf) | Kein Perf-Hebel; disko-Umsiedlung bleibt Wartbarkeits-Entscheidung; Judge führt die disko-Entscheidung bewusst als Besitzer-Entscheidung mit `dry-activate`-Gegenprobe |
| „bare nixosSystem 3,07–3,87 s" (eval-perf) | ebenfalls Abbruch-Evals (grub-Assertion); real 6,0–6,7 s (oracle-eval-perf) | Absolutzahlen korrigiert |
| „System-Andere (boot/pipewire) ≈ +0 s" (eval-perf, perfW-Schluss) | falsch: System-Stack +4,1 s, davon **pipewire +3,9 s** (nixpkgs-Upstream), network+wifi +0,85 s (oracle-eval-perf) | Der echte Eval-Block ist Upstream, nicht die Library |
| niri-flake ≈ +1,5 s Eval (eval-perf MEDIUM) | nicht reproduzierbar: +0,0–0,9 s im Rauschen (oracle-eval-perf) | kein Ansatzpunkt |
| `programs.dsearch` = stiller Eval-Bruch, totes Relikt (desktop H2; auch Strategien A/B mit „Zeile löschen") | nixpkgs-Modul existiert (26.11-Zweig, `nixos/modules/programs/dsearch.nix`, module-list.nix:211); dsearch ist ein realer danksearch-Indexer-Daemon mit File-Watcher (oracle-runtime-perf; cross-desktop; Judge Widerspruch 1) | Richtige Behandlung: Runtime-Entscheidung (Pfade begrenzen / gaten / deaktivieren), nicht „toten Code löschen" |
| dms-settings: configVersion-Ziel 16, „~92 % Upstream-Default-Klon" (desktop H1) | DMS-intern **v33**; Snapshot eines v5-Schemas: 172 exakte Upstream-Defaults, **180 tote Keys**, ~24 echte Abweichungen (oracle-desktop, automatisierter SPEC-Abgleich aller 376 Keys) | Reduktion auf ~40 LOC lohnt erst recht |
| DMS spawnt alle 3 s den externen dgop-Prozess (desktop M1) | Daten via DankSocket-IPC vom DMS-Daemon, kein Process-Spawn; Intervall (3 s / 6 s Power-Saver) stimmt (oracle-desktop) | Last moderater, bleibt permanent |
| Polling-Belegzeilen `showCpuUsage`/`showMemUsage`/`showWeather` (dms-settings:50-55, desktop) | tote Keys (REMOVED_KEYS_V21); Widgets laufen über `barConfigs` (oracle-desktop) | Belegstellen ersetzt |
| polkit-Agent deaktiviert, Ersatz fehlt → GUI-Auth ins Leere (runtime-perf F3) | DMS bringt eigenen Polkit-Agenten und lädt ihn per Default (`PolkitService.qml:12-14,71-75`); nur `niri.nix:15-16`-Kommentar veraltet (oracle-runtime-perf HQ1) | nur Kommentar korrigieren |
| Wetter-Widget ohne Standort → Retry-Loop (runtime-perf F5) | IP-Location-Fallback, 3 Retries à 30 s, exponentieller Backoff gedeckelt 5 min, alles unter `nice -n 19 ionice -c3` (oracle-runtime-perf) | entkräftet |
| Impermanence→tmpfs→RAM-Druck (Hypothese der Ausschreibung) | btrfs-Blank-Snapshot-Rollback im initrd, @persist-Subvol; RAM-Quellen sind Anwendungen (runtime-perf F9, oracle-core-system) | entkräftet |
| core ohne system bricht (/persist-Zwang) (core-system M1) | alle /persist-Fragmente liegen im Modulnamen `impermanence`, greifen nur bei dessen Import; agenix-Default greift; Live-Beweis `dmi` (oracle-core-system M1-Widerlegung) | Komposition nur dokumentieren, kein Fix nötig |
| Firewall blockt mDNS/.local → Timeouts (core-system M4) | aktive Queries laufen über conntrack als ESTABLISHED durch; blockiert nur unsolicited Announcements; `publish=false` bewusst (oracle-core-system M4-Widerlegung) | keine Port-Freigabe ohne Laufzeit-Beweis |
| „gepflegter Toter": desktop-Ast ohne Konsument = toter Code (dead-dupes HIGH-3) | frische Live-Commits (Performance-Pass `7d37ccc` 2026-09-11, Greeter-Persistenz `66d473a`) + Dell-5570-Template belegen unsichtbaren Laptop-Konsumenten (oracle-dead-dupes) | „lebend, Konsument nicht im Zugriff" — Phase-0-Klärung zwingend |
| ~10 Name≠Datei-Verstöße (dendritic HIGH-2) | 3 von 9 sind sanktionierte Feature-Splits (`nix-substituters`, `niri-bindings`, `dms-settings`); ~6 echte auf 146 Dateien (~96 % intakt) (oracle-dendritic) | Sweep bleibt, Umfang korrigiert |
| sesh-Standalone-Import crasht (term M4) | alle tmux-Schreiber mergen als EIN Modul unter Key `tmux` (attrsOf deferredModule); Crash konstruktiv unmöglich (oracle-term) | kein tmux-Refactor |
| Ctrl-R-Nutzung = „Lotterie" (term H3) | deterministisch: Ctrl-R = atuin, Ctrl-T/Alt-C = fzf-nativ; dafür vierte tote Finder-Schicht entdeckt (`fishPlugins.fzf`, fish.nix:21-24) (oracle-term) | Konsolidierung statt Umbau |
| gpg-Agent-Doppelung = „klassische Debugging-Hölle" (term M1) | getrennte Scopes (/var/lib/gnupg vs. ~/.gnupg), keine Socket-Kollision; Redundanz-/Pinentry-Frage bleibt (oracle-term) | Wartungsklarheit, kein Laufzeitfehler |
| „Desktop-Host akkumuliert 5 Substituter" (development) | kein Desktop-Host in sichtbaren Repos; `dmi` hat 4, alle gerechtfertigt (oracle-development) | These für Zielbox, kein Repo-Befund |
| Helix: „nixpkgs trägt täglich", „voller Rust-Rebuild bei jedem Bump", „16 ungepinnte extraPackages = Mangel" (development) | nixpkgs trägt Releases (Lag Tage–Wochen); Rebuild nur bei Toolchain-Wanderung; ungepinnt = Channel-Semantik (oracle-development) | Kernschluss (Input streichen) bleibt |
| Lock: „Bot könnte gefrorene nachziehen", „58 Nodes = Review-Noise" (lock-hygiene [high]) | gefrorene Nodes sind Upstream-Lock-Pins (PR #26 bewegt dieselbe ungepinnte URL auf zwei verschiedene Revs — bewiesen); gefrorene Nodes erscheinen nie in Wellen-Diffs (oracle-lock-hygiene W1/W2) | nur Dev-Kette kollabieren |
| „wöchentliche Quickshell-C++-Engine-Rebuilds" (lock-hygiene W3 These) | Engine aus nixpkgs, cache.nixos.org-gedeckt; lokal gebaut werden dms-Paket, greeter-Go-Binary, 6 Plugins (oracle-lock-hygiene W3) | Kosten real, aber mittelgroß |
| mbsync + continuum: synchroner Load-Peak „gleiche Minute" (term M2) | continuum zählt ab tmux-Server-Start, driftet gegen den OnCalendar-Timer (oracle-term) | kleiner Posten |
| dms-settings „wird vom Aggregator nicht importiert" (Vorbehalt im oracle-runtime-perf) | `dms-settings.nix:2` und `dms.nix:20` registrieren beide `homeManager.dms`; `desktop.nix` importiert `dms` → Datei ist AKTIV (cross-anti D2, cross-desktop Verifikationsnotiz; Judge Widerspruch 3) | Kürzung ist Eingriff in aktive Konfiguration — mit GUI-Gegenprobe |
| „mkForce-niri-Block beim nächsten Bump mittesten" (desktop M4-Empfehlung) | Upstream generiert beim gepinnten Rev die identische `config.kdl` inkl. Border-Fix → Block ist redundant, **löschen** (oracle-desktop M4-Umdrehung) | 1 h statt Dauerverpflichtung |
| quickshell.drv „belegt lokalen Build-Pfad" (eval-perf) | drv-Präsenz beweist Instantiierung, nicht Build (Outputs fehlen, keine Build-Logs); These bleibt Hypothese für die Zielbox (oracle-eval-perf) | Verifikation: `nix build --dry-run` am Ziel nach nächster Welle |
| Zahlen-Kleinigkeiten | 24→22 Auto-Merge-Commits; 145→146 Dateien; desktop 19 nicht 24; helix-lsp 9 nicht 10 Sprachdateien; `.dotnix`-Pin in BOTH Lesarten pre-cleanup (committet `2496fd2`, Working-Tree `0c33875`, Lock uncommittet) (oracle-lock-hygiene W5, oracle-dead-dupes) | folgenlos |

## 10. Anhang: Quellenverzeichnis

Alle Dateien in `/tmp/dotnix-research/` (Researcher = Ausgangsbefundlage, Orakel = adversarielle Prüfung je Dimension, Querschnitt = über-Dimensionen-Synthese, Strategie = drei Richtungen, Judge = abschließendes Duell-Urteil):

| Datei | Inhalt (1 Zeile) |
|---|---|
| wiring.md | Researcher 1/10 — Flake-Wiring: expose-Leak (Dev-Tooling + `debug=true`), README-Phantome, 3 flake-parts-Revisionen, ISO-Pfad, CI-Kommentar-Lüge |
| dendritic.md | Researcher 2/10 — Dendritic-Konventionen: Template kaputt, ~10 Name≠Datei, Collector-Streuung, Tier/Group-Divergenz, Compliance-Bestand |
| core-system.md | Researcher 3/10 — core+system: `resume_offset` fehlt, /persist-Kopplung, Sudo-Posture, Taxonomie-Brüche, Options ohne descriptions |
| term.md | Researcher 4/10 — Shell-Ökosystem: fastfetch pro Pane, mbsync-Doppelsync, fzf/skim/atuin-Bindings, doppelter gpg-Agent, Popup-Gates |
| desktop.md | Researcher 5/10 — Compositor/Shell/Apps: dms-settings 457-LOC-Snapshot, dsearch-Eval-Bruch-Verdacht, Qt-Theming dreifach, Ghostty-GPU-Last |
| development.md | Researcher 6/10 — Editoren/VCS/KI: Helix-Eigen-Input 2 Monate stale + cache-blind, doppelte LSP-Server, Struktur-Lüge git/AI-Module |
| dead-dupes.md | Researcher 7/10 — Duplikate/Import-Graph: 3 tote Module, Template-Drift, desktop-Ast ohne sichtbaren Konsumenten, pre-Cleanup-Pin |
| eval-perf.md | Researcher 8/10 — Eval/Rebuild-Messungen: disko +7 s (später als Messartefakt widerlegt), DMS ohne Binary-Cache, Scaffolding 0,15–0,5 s |
| runtime-perf.md | Researcher 9/10 — Runtime-Config-Sicht: DMS-Dauerlast-Verdacht, kein thermald, polkit-Verdacht, Wetter-Retry-Verdacht, Laufzeit-Inventar |
| lock-hygiene.md | Researcher 10/10 — Lock/Inputs: 58 Nodes, gefrorene Upstream-Pins, niri-Fork, ungenutzte stable-Schiene, wöchentlicher Auto-Merge |
| oracle-dendritic.md | Orakel — bestätigt Template-Bruch; widerlegt 3 von 9 Namens-Fällen (Feature-Splits); verteidigt Inline-Impermanence; Tier-Schnitt = Normalzustand; Granularität „genau richtig" |
| oracle-wiring.md | Orakel — verschärft README-Drift zum bewiesenen Template-Eval-Bruch (core-Injektion bewusst entfernt, `880c2b1`); age-rekey-Personalia = Security-Blocker; Export-Split-Rezept mit Pflicht-Parts; debug-Reichweite präzisiert |
| oracle-core-system.md | Orakel — widerlegt /persist-Zwang (core IST standalone, Live-Beweis dmi) und mDNS-Blockade; korrigiert Hibernation-Folge (Schrieb gelingt, Resume bricht); sudo-Posture auf WSL-Realität rekalibriert |
| oracle-term.md | Orakel — widerlegt sesh-Standalone-Crash (Key-Merge unter `tmux`) und Ctrl-R-„Lotterie"; fand 4. Finder-Schicht (fishPlugins.fzf); Popup-Gates und Mail-Takt als Besitzer-Entscheidung |
| oracle-desktop.md | Orakel — dms-settings = v5-Snapshot (180 tote Keys, DMS v33, ~24 echte Deltas); dgop-IPC statt Process-Spawn; mkForce-niri-Block redundant (löschen); qt-theme „wirkungslos" auf plausibel herabgestuft; Ghostty + Akku = P1 |
| oracle-development.md | Orakel — Helix-Input = Kosten ohne Nutzen (seit 9 Wellen nicht gebumpt, cachix blind) → streichen; nixd/markdown-oxide behalten; difftastic-Relikt; „5 Substituter am Desktop-Host" im Audit-Scope unbelegbar |
| oracle-dead-dupes.md | Orakel — widerlegt „gepflegter Toter" (Live-Commits belegen unsicharen Laptop-Konsumenten); verschärft Pin-Lage (committeter Lock noch älter); parts-Split-Rezept: Pflicht- vs. Dev-Parts; P1 = Konsumenten-Klärung |
| oracle-eval-perf.md | Orakel — widerlegt disko +7 s (Baseline war fehlgeschlagener Eval; saubere Paarung ±0 s), bare-Zahlen, „System-Andere ≈ 0" (pipewire +3,9 s), niri +1,5 s; Template crasht reproduzierbar (8,8 s); DMS-Cache-Losigkeit bewiesen |
| oracle-runtime-perf.md | Orakel — entkräftet DMS-Dauerlast-Paket, polkit- und Wetter-Thesen; findet übersehene Dauerläufer (dsearch, handy, docker-linger, mbsync-Timer); Root-Causes: Energie-/Thermik, Dauerläufer-Bündel, fastfetch; Messplan |
| oracle-lock-hygiene.md | Orakel — helix-Freeze durch Bot als neues High (9 Wellen); gefrorene Nodes = Upstream-Lock-Semantik; kein AvengeMedia-Cache existiert/konfigurierbar; Fork unbegründet; Empfehlung: Kadenz 2 Wochen + Build-Gate, keine Diät |
| cross-desktop-langsam.md | Querschnitt 1 — Trägheits-Top-5 (Ghostty-Shader, Akku/thermald, DMS-Bündel, dsearch, fastfetch) mit Belegt/Plausibel- und Repo/Konsument/Maschine-Einordnung; 60-Minuten-Messplan; entkräftete Verdächtige |
| cross-struktur-verdikt.md | Querschnitt 2 — Struktur-Verdikt „Pattern unschuldig, Ausführung schuldig"; 4 Ausführungslücken A1–A7; Architektur-Optionen A–D (A empfohlen); Compliance-Bestand; Fix-Liste ≈ 6–8 h |
| cross-umbau-plan.md | Querschnitt 3 — Migrations-Roadmap Phase 0–5 (29–54 h), 12 Quick-Wins, verbotene Gleichzeitigkeiten (9), Aufwands- und PR-Granularität |
| cross-wartbarkeit-top10.md | Querschnitt 4 — Top-10-Wartbarkeits-Interventionen (~25–28 h) mit Begründungen, Abhängigkeiten, PR-Reihenfolge und bestätigten Pflicht-Befunden |
| cross-eval-strategie.md | Querschnitt 5 — Eval-/Rebuild-Konsolidierung: 11 Befunde, 7 Hebel (Build-Gate, disko, Kadenz, Helix, debug, Lock-Hygiene, ISO), bewusst nicht; klare Trennung Eval ≠ Runtime |
| cross-anti.md | Querschnitt 6 — Anti-Empfehlungen A1–D7 (Nicht tun) + Bewusst lassen L1–L13 + Erwartungs-Management E1–E7 (Laptop-Konsument als Mutter aller Schein-Verdiener) |
| strategy-konservativ.md | Strategie A — kleinste Diffs/Löschungen, ~4–5 PT; einzige Strategie mit direkter Trägheits-Wirkung; Export-Split bewusst vertagt; Template-Fix unvollständig (Case-Bug fehlt) |
| strategy-umbau.md | Strategie B — dendritische Disziplin-Reparatur in Phasen 0–5, Kern 2,5–3 PT; vollständiger Template-Fix, Export-Split, Namens-/Ortshygiene, dms-Kuration; Runtime nur als Rider |
| strategy-konsolidierung.md | Strategie C — Substrat/Pipeline 9–12 h; helix-Diagnose, Actions pinnen, Build-Gate, follows selektiv, Kadenz; ehrlich: null Laufzeit-Wirkung |
| judge.md | Jury-Urteil — Score A 37 / B 33 / C 27; Gewinner B als Rückgrat + A-Runtime an Position 1 + C-Substrat; Mischplan ~6–8 PT in 6 Phasen; 7 Widersprüche geklärt (u. a. dsearch, Template-Vollständigkeit, dms-settings-Aktivität, Export-Split-Timing); Übergangskriterien |
