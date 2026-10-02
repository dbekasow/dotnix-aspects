# JUDGE-Urteil — Strategie-Duell .dotnix-aspects (2026-10-02)

Richtlinie: Bewertung der drei Strategiepapiere gegen die drei Besitzer-Sorgen (Struktur, Wartbarkeit, Desktop-Trägheit) auf Basis der 10 Forschungsberichte + 9 Orakel-Gutachten + eigener stichprobenartiger Repo-Lektüre (HEAD `ac7724c`, Branch `main`; Working Tree `M modules/aspects/term/shell-ux/sesh.nix` unberührt; Consumer `.dotnix` mitgelesen: Pin `0c33875`, 8 Commits hinter HEAD, `M flake.lock` uncommittet). Alle `path:line`-Angaben im Folgenden selbst gelesen, sofern nicht ausdrücklich einem Papier/Orakel zugeschrieben.

---

## Score-Tabelle

| Kriterium | A Konservativ | B Umbau | C Konsolidierung |
|---|---|---|---|
| Wirkung gegen Struktur-Sorge | **5** | **8** | **2** |
| Wirkung gegen Wartbarkeits-Sorge | **7** | **9** | **6** |
| Wirkung gegen Desktop-Trägheit | **8** | **3** | **3** |
| Bruchrisiko (10 = risikoarm) | **9** | **6** | **8** |
| Aufwandseffizienz (10 = gering) | **8** | **7** | **8** |
| **Summe** | **37** | **33** | **27** |

Summe ist nicht die Entscheidung — Gewichtung nach der Sorgen-Liste des Besitzers (Struktur und Wartbarkeit zuerst) und Substanz-Tiefe schon. Begründungen je Feld unten.

## Begründungen

### A — Konservativ (kleinste Diffs)

- **Struktur 5:** A repariert die konkreten Struktur-Lügen (Template fehlt `core` — von mir verifiziert: `templates/dotnix/modules/hosts/myHost/configuration.nix:4-8` listet nur `dell-precision-5570 system development`; README-Phantome — verifiziert `README.md:21` referenziert `modules/options.nix`/`factories.nix`, beide existieren nicht; 3 tote Module — verifiziert 0 externe Referenzen für `yubikey-lock`/`tuigreet`/`boot-limine`), aber Namens-Lügen (`k9s.nix`→`kubernetes`, `television`-Fusion) und der Export-Leak bleiben bewusst stehen. Eigenes Ermessen: „mittel". Abzug: A's Template-Fix ist **unvollständig** — der Case-Bug `members = [ "myUser" ]` (Template `:9`) vs. `user = "myuser"` (`users/myUser/default.nix:3`) crasht `lib.attrVals host.members modules.nixos` (`modules/parts/configuration.nix:39`) — A hätte das Template nach eigenem Fix weiterhin eval-broken; B und oracle-dendritic High 1 haben ihn, A nicht.
- **Wartbarkeit 7:** Größter Einzelgewinn dms-settings 457→~40 LOC ist echt (verifiziert: 457 LOC, `configVersion = 5` bei `:454`) und die CI-Consumer-Fixture ist die richtige Root-Cause-Abschaltung. Warum nicht höher: Namens-Hygiene und Export-Split (devshell/treefmt/pre-commit/templates wandern via `expose.nix` `addPath parts/` in jeden Konsumenten — verifiziert `modules/expose.nix:16-23` + `modules/parts/`-Listing) fehlen; genau das sind die „wo gehört das hin?"-Reibungen der Struktur-Klage.
- **Trägheit 8:** Einzige Strategie, die die config-seitigen Ursachen direkt anpackt, in der Prio-Ordnung beider Perf-Orakel: Ghostty `background-blur = 20`/`custom-shader-animation = true` (verifiziert `ghostty.nix:16,22`), `batteryProfileName = "power-saver"` (verifiziert `dms-settings.nix:209`), fastfetch ohne TMUX-Guard (verifiziert `fastfetch.nix:23-26`), doppelte LSP-Server (verifiziert `helix-lsp/nix.nix:3,21`, `markdown.nix:5,16`), Doppel-Sync mbsync (verifiziert `maildir.nix:9,17`), dsearch-Dauerindexer (verifiziert `dms.nix:12`). Abzug für die Reihenfolge-Schwäche: Akku-Fix (Phase 1.2) läuft vor der Messsession (1.8), obwohl die Orakle verify-first verlangen (bewusste Entscheidung, `powerprofilesctl` im trägen Moment klären). Und: ohne Phase-0-Pin-Update am Laptop wirkt nichts davon (A sagt das selbst).
- **Bruchrisiko 9:** Fast alles Ein-Zeilen-Diffs und Löschungen, je Commit revertierbar, Messung als Gate für die unsicheren Punkte. Restrisiko: dms-settings-Delta-Verlust (dokumentiert + Diff-Review) und die Follows-Rider.
- **Aufwandseffizienz 8:** ~4-5 Tage für die breiteste Direktwirkung auf die gefühlte Trägheit — das beste Verhältnis auf dieser Achse; schwächer quotenmäßig auf Struktur, wo der Effekt bewusst „mittel" bleibt.

### B — Umbau (dendritische Disziplin-Reparatur)

- **Struktur 8:** Einzige Strategie, die Name=Datei=Aspekt wieder wahr macht (6 verifizierte Verstöße + television-Fusion — oracle-dendritic High 2, „hält" je Fall), den Export nach Produkt/Dev trennt, den Template-Fix **vollständig** macht (Case-Bug + `core`) und die Tier/Gruppe-Semantik dokumentiert statt umbaut. Nicht höher, weil die Gruppen≠Tiers-Divergenz bewusst bleibt — das ist aber orakelgestützte richtige Zurückhaltung (oracle-dendritic HQ1: Angleichen zerstört die Themen-Ordnung).
- **Wartbarkeit 9:** Superset von A's Wartbarkeitsliste plus die beiden Anti-Verrottungs-Strukturhebel: Export-Split (Bibliothek liefert keine Devshell mehr an Konsumenten) und Namens-Findbarkeit. Das Papier hat als einziges „Verbotene Gleichzeitigkeiten" (dms-settings-Reduktion nie im selben PR wie ein DMS-Bump; Renames nie parallel zum Export-Split) — das ist Wartbarkeits-Engineering, nicht nur Reparaturliste.
- **Trägheit 3:** Ehrlich selbst bewertet („Eval mittel / Runtime gering"): Scaffolding ist gemessen vernachlässigbar (0,15-0,5 s, eval-perf LOW), `debug`-Kosten ungemessen aber mechanismisch belegt (verifiziert `modules/parts/flake-parts.nix:5`), DMS-Migrations-Churn killt Millisekunden beim Start. Die dominierenden Runtime-Hebel trägt B nur als Rider (Phase 5) — für die akuteste Sorge des Besitzers ist B allein zu spät dran.
- **Bruchrisiko 6:** Export-Split ist der einzige echte Breaking Change des Duells (unsichtbarer Laptop-Konsument könnte geerbte Devshell/Formatter nutzen); Renames brechen Konsumenten, die alte Aspekt-Keys direkt importieren. Beide durch Phase-0-Gate, Opt-in-`devTools`-Alias und Konsumenten-Grep abgefedert, plus Fixture als Regressionsschutz — Risiko bleibt aber real und steckt nur in B.
- **Aufwandseffizienz 7:** 2,5-3 Tage Kernumbau, jede Phase einzeln grün und revertierbar, gut sequenziert. Abzug: Runtime-Inhalt muss aus A importiert werden (Rider duplizieren A's Phase 1); null Eigenwirkung auf die spürbarste Sorge.

### C — Konsolidierung (Inputs/Pinning/Pipeline)

- **Struktur 2:** Selbstattestiert und korrekt: kein Aspekt/Taxonomie-Eingriff; Substrat-Strukturgewinne (eine nixpkgs-Instanz, dokumentierte Fork-/Kanal-Entscheidungen) sind real, aber beantworten die Struktur-Klage nicht.
- **Wartbarkeit 6:** Auf der Substrat-Achse stark und vollständiger als A/B dort: Actions pinnen (verifiziert `update-flake-lock@main` in `flake-update.yml:23`, `flake-checker-action@main` in `flake-check.yml:23`), echtes Build-Gate vor Auto-Merge (verifiziert: heutiges Gate ist `nix flake check` eval-only, `flake-check.yml:26`), helix-Anomalie mit Wurzel-These (Freeze seit PR #18, rev `079a789` = 2026-07-23 — verifiziert am Lock; 22/186 Update-Commits — von mir nachgezählt), Lock 58→~46 (verifiziert 58 Nodes, `nixpkgs`+`nixpkgs-stable`, `dank-qml-common` ×2 divergent `a88b16e`/`660b044`, agenix-Lock-Node hat nur `nixpkgs`-Input → `flake.nix:5` ist ein toter Override). Warum nicht höher: die beiden größten Einzel-Posten der Wartbarkeits-Klage (dms-settings-Churn, ungetesteter Konsumenten-Vertrag) fehlen komplett.
- **Trägheit 3:** Ehrlich: „NICHT verbessert: die Laufzeit-Trägheit des Desktops selbst". Reale Effekte liegen auf dem Update-/Rebuild-Pfad: halbierte DMS-Source-Build-Wellen (verifiziert: Cron `0 4 * * 1` in `flake-update.yml:6`, kein AvengeMedia-Substituter), helix-Rust-Rebuild-Risiko eliminiert, Miss-Requery 30 s→1 h (verifiziert `nix.nix:32`). Für das runtime-gefühlte Symptom: irrelevant.
- **Bruchrisiko 8:** Die riskante Klasse (follows-Overrides) wird bewusst auf die eval-pfadneutrale Dev-Kette und die grep-verifiziert ungenutzte Stable-Schiene begrenzt (von mir verifiziert: 0 Referenzen auf `nixpkgs-stable`/`niri-stable` in modules/+templates/); dank-qml-common mit Greeter-Probe. Pinning + Build-Gate senken Risiko aktiv. Abzug: biweekly-Kadenz vergrößert den Sprung pro Welle.
- **Aufwandseffizienz 8:** 9-12 h für eine vollständige, orakelkonforme Substrat-Reparatur mit der besten Einzel-Diagnose des Duells (helix-Freeze-Wurzel). Bestes Verhältnis auf der eigenen Achse — aber null Wirkung auf zwei der drei Sorgen.

## Widersprüche

1. **dsearch: Eval-Bruch-Verdacht (A Phase 1.6, B Phase 4.3 „Zeile löschen, Eval-Bruch präventiv") vs. nixpkgs-Modul existiert (oracle-runtime-perf: `programs.dsearch` in gelocktem nixpkgs, module-list.nix:211; cross-umbau-plan Phase 3.5).** Die besseren Belege gehören C-neutral/oracle-Seite: dsearch ist ein realer danksearch-Indexer-Daemon mit File-Watcher, kein totes Relikt. A/B kommen zufällig zur ähnlichen Handlung (weg/begrenzen), aber mit falscher Begründung — die richtige Behandlung ist die Runtime-Entscheidung (Pfade begrenzen / auf `graphical-session.target` begrenzen / deaktivieren), nicht „toter Code löschen". Urteil: oracle-runtime-perf + cross-umbau-plan setzen sich durch.
2. **Template-Fix-Vollständigkeit: A (nur `core` nachziehen) vs. B (`core` UND Case-Fix `myUser`→`myuser`).** B hat Recht, von mir am Code verifiziert (`configuration.nix:39` `attrVals` wirft vor jedem Build). A's Fix allein lässt das Template kaputt — der CI-Fixture-Job, den auch A bauen will, hätte es A dann gezeigt. Belege: B + oracle-dendritic High 1.
3. **dms-settings-Erreichbarkeit: oracle-desktop-Einschränkung („wird vom desktop-Aggregator nicht importiert") vs. cross-anti D2 (Collector-Name `homeManager.dms` → immer live).** cross-anti hat Recht — von mir verifiziert: `dms-settings.nix:2` registriert `flake.modules.homeManager.dms` (Feature-Split wie `nix`/`nix-substituters`), `desktop.nix` importiert `dms`, beide Dateien mergen in denselben Aspekt. Konsequenz: Akku-Profil-Fix und Spiegel-Reduktion sind live-relevant, die P1-Empfehlungen von oracle-desktop gelten ohne die Einschränkung.
4. **Export-Split-Timing: A schiebt bewusst („primär Eigenverbrauch, Vertragbruch wiegt schwerer") vs. B führt ihn als Kernphase (Public-Release-Vertrag).** B gehören die besseren Belege: Das Repo IST auf Public Release unterwegs (Branch `refactor/public-release`, README bewirbt `github:dbekasow/dotnix-aspects`-Konsum, das Template existiert nur dafür), und drei Orakel (dendritic HQ3, wiring, dead-dupes HQ3) empfehlen den Produkt/Dev-Split übereinstimmend. A's Eigenverbrauchs-Prämisse ist auf diesem Branch falsch; A's eigene Risiko-Liste trägt den Split nur als „optional".
5. **Akku-Profil: A ändert sofort (`power-saver`→`balanced`, Phase 1.2) vs. Orakel verify-first (`powerprofilesctl` im trägen Moment; bewusste Entscheidung dokumentieren oder ändern).** Die Orakel haben die bessere Prozedur — `acProfileName = "performance"` (`:204`) zeigt, dass das Profil bewusst gesetzt wurde, nicht verfallen ist. A's eigene Messsession (1.8) müsste eigentlich VOR 1.2 stehen; der Fix selbst ist risikoarm und eine Zeile, daher kein großer Score-Abzug.
6. **disko +7 s Eval (größter messbarer Einzel-Eval-Block, eval-perf HIGH, cross-eval-strategie Hebel 2) vs. alle drei Strategien:** A akzeptiert ihn explizit („kein konservativer Hebel"), B macht ihn zur Besitzer-Entscheidung in Phase 4, C schweigt. Kein Papier bringt ihn aktiv in den Plan — das ist eine gemeinsame Lücke des Duells. Er gehört als Besitzer-Entscheidung mit Gegenprobe (`time nixos-rebuild dry-activate` vor/nach) in die Mischung, nicht in den Papierkorb.
7. **Kein Widerspruch, sondern Konvergenz (stärkste Evidenz des Duells):** Alle drei Papiere verlangen als Phase 0 dieselben zwei Dinge — Laptop-Konsument identifizieren und Consumer-Pin-Gap schließen (von mir verifiziert: `.dotnix` kennt nur Host `dmi` mit `modules = [ core wsl development ]`, Pin `0c33875` = 8 Commits hinter HEAD, `M flake.lock` uncommittet). cross-anti E1 nennt es zurecht die „Mutter aller Schein-Verdiener": ohne sie wirkt kein Desktop-Fix am gefahrenen System. Ebenso Konsens über: CI-Fixture, `debug`-Zeile streichen, helix-Eigen-Input streichen, Kadenz halbieren, narinfo-TTL, dsearch angehen. Das Duell unterscheidet sich im Was kaum, im Wie und in der Reihenfolge sehr.

## Empfehlung

### Gewinner: B — als Rückgrat, mit A's Runtime-Paket als Pflicht-Import an Position 1 und C's Substrat als drittem Viertel.

Kante gegen A (obwohl A die höchste Score-Summe hat): Die Sorgen-Liste des Besitzers nennt Struktur und Wartbarkeit zuerst — und die Orakel sagen unisono, die Struktur-Klage sei Ausführungs-Disziplin, nicht Muster. Genau diese Disziplin-Ebene (Namens-Lügen, Export-Leak, unvollständiger Template-Fix) ist Bs Alleinstellung; A verweigert sie bewusst und hätte das Template nach eigenem Fix weiterhin kaputt. A's Runtime-Hebel sind dagegen fast alles Ein-Zeiler, die sich an jeden Plan ankleben lassen (B trägt sie selbst als Rider) — umgekehrt lässt sich Bs Strukturarbeit nicht in A hineinretuschieren, ohne A's eigene Anti-These aufzugeben. C ist kein Ganzes, aber das beste und orakelkonformeste Substrat-Papier (allein die helix-Freeze-Diagnose) und deckt die Pipeline-Achse, die A nur nachlaufend und B nur als Rider behandelt.

### Mischplan (Reihenfolge mit Begründung)

**Phase 0 — Rahmen (alle drei Papiere, ~0,5 Tag).** Laptop-Konsument identifizieren; `.dotnix`-Lock committen; Auto-Merge für die Umbau-Dauer stilllegen (`workflow_dispatch` only); Baseline-Messung am Ziel-Desktop (systemd-cgtop, powerprofilesctl AC/Akku, `time nixos-rebuild dry-activate`).

**Phase 1 — Trägheits-Quick-Wins (Inhalt: A Phase 1, ~1 Tag).** Der gefühlte Schmerz ist der akute; die Hebel sind Minuten-Arbeit: Ghostty `custom-shader-animation = false` + Blur-Entscheidung, Akku-Profil nach `powerprofilesctl`-Befund (ändern oder als bewusst dokumentieren), fastfetch-TMUX-Guard, LSP-Doppelung auflösen, mbsync-Doppel-Sync, docker-linger/StartLimits nach Messbefund, Bar-Widgets probefahren. dsearch als Runtime-Entscheidung (Indexer begrenzen/gaten/deaktivieren — NICHT als toten Code löschen, s. Widerspruch 1). Consumer-Lock-Update danach, sonst wirkt nichts.

**Phase 2 — Vertragsreparatur (Inhalt: B Phase 1, ~1 Tag).** Template: Case-Fix UND `core` (vollständig, s. Widerspruch 2); README auf Realität inkl. Pfad-/Layout-Kontrakt und Tier≠Group-Absatz; CI-Consumer-Fixture (erst eval-only, `drvPath`); `hostname`-Typfehler (`parts/configuration.nix:33` `type = str; default = null`); tote Module + `bash.nix` (No-Op, verifiziert) löschen; falschen CI-Kommentar streichen.

**Phase 3 — Substrat/Pipeline (Inhalt: C Phasen 1-4, ~1,5-2 Tage).** Actions pinnen; Build-Gate vor Auto-Merge (die Fixture aus Phase 2 zu echtem `nix build`/nix-fast-build aufwerten — sonst kommen Build-Brüche weiter erst am Desktop an); helix-Eigen-Input streichen (inkl. Overlay/Substituter-Block, verifiziert `editors/helix.nix:3-7`); toten agenix-Override weg; `nixpkgs-stable`-follows + Guard-Kommentar; agenix-rekey-Dev-Kette kollabieren; dank-qml-common vereinheitlichen; niri-Fork dokumentieren oder zurückrollen; Kadenz `0 4 1,15 * *`; Kanal-Strategie dokumentieren; push-before-rebuild-Regel. Bewusst NICHT: Lock-30-Nodes-Diät, Stylix/NUR-Transitive kollabieren, eigener Cachix (C selbst lehnt das orakelkonform ab).

**Phase 4 — Export + Desktop-Stack (Inhalt: B Phase 2+4, ~1,5 Tage).** Export-Split (Aspekte + `parts/{flake-parts,configuration,age,home-manager}.nix` — `flake-parts.nix` MUSS bleiben, sonst sind alle 132 Aspekte tot; Dev-Tooling als Opt-in-`devTools`-Alias); dms-settings 457→~40 echte Deltas gegen den GEPINNTEN Rev diffen, `configVersion`/`mkDefault`-Wraps streichen (nie im selben PR wie ein DMS-Bump); niri-mkForce-Block nach gerenderter `config.kdl`-Gegenprobe löschen; qt-theme nach Stylix-Prioritätsprüfung; Theming-SSOT-Dokumentation.

**Phase 5 — Namens-/Taxonomie-Hygiene (Inhalt: B Phase 3, ~1 Tag).** Renames/Splits (`skills`→`ai-tools`, `k9s`→`kubernetes`, `gpg`→`gnupg`+`gpg-agent`, `yubikey`-Split, `television-nix`→`nix-search-tv` mit eigenem Aspekt); 3 Fehlplatzierungen (`fonts`→desktop, `nix-ld`→development, `performance`→system) im selben Commit wie die Tier-Listen; Options-API-Doku; disko-Entscheidung (aus `system`-Tier heraus oder bewusst akzeptiert, mit `dry-activate`-Gegenprobe, s. Widerspruch 6); ISO-Default dokumentieren oder streichen.

Gesamtaufwand Mischung: ~6-8 Personentage. `resume_offset` (Hibernate, Konsumenten-seitig) und thermald (nur nach Messung) laufen als Owner-Aktionen parallel.

### Übergangskriterien (wann wechselt man zu Phase X)

- **0→1:** Laptop-Flake-Quelle identifiziert (oder nach 2 Wochen erfolgloser Suche als „blind" deklariert); Baseline-Notizen existieren. Ohne das Kriterium laufen Phase-1-Fixes ins Leere.
- **1→2:** Quick-Wins über den aktualisierten Consumer-Pin am Laptop angekommen und Trägheit re-bewertet (subjektiv + eine cgtop/pidstat-Kontrollmessung). Bleibt Rest-Trägheit, zuerst Messlücken schließen (thermald, dsearch-Pfade), nicht neue Hebel raten.
- **2→3:** Fixture-Job grün (er beweist zugleich den Case-Fix), README/Template wahr, Auto-Merge reaktivierbar.
- **3→4:** Zwei Bot-Wellen sauber durchs neue Build-Gate gelaufen; helix-Anomalie geklärt/beseitigt; Laptop-Repo auf devshell/formatter-Nutzung gegriffen (leer → Split sicher; Treffer → Opt-in-Import dokumentieren, dann Split).
- **4→5:** Konsumenten auf aktuellem Pin; dms-settings-Diff am Live-Desktop vom Besitzer abgesegnet; Export-Split gelandet. Renames erst, wenn der Split-PR eine Woche stabil ist (zwei Key-Oberflächen-Änderungen nie gleichzeitig, B's „Verbotene Gleichzeitigkeiten").

## Risiken und Unbekannte

- **Laptop-Konsument bleibt die Mutter-Risiko:** Alle Desktop-Runtime- und Export-Aussagen sind Bibliotheks-Aussagen, bis dessen Flake-Quelle und Pin bekannt sind (alle drei Papiere + cross-anti E1).
- **Ungemessene Magnituden:** `debug`-Eval-Kosten, fastfetch-Latenz (50-200 ms geschätzt), dsearch-Last und -Indexpfade, Stylix-Qt-Priorität (vor qt-theme-Löschung prüfen) — je durch eine Messung/`nix eval` klärbar.
- **helix-Freeze-Wurzel:** Ohne einen Owner-nix-Lauf (`nix flake lock --update-input helix`) nicht final beweisbar; Action-Pinning ist nur die zeitlich passende Hypothese.
- **dms-settings-Reduktion:** Verlust bewusst gesetzter LIVE-Keys möglich — abgesichert durch maschinellen SPEC-/settings.json-Diff und Besitzer-Review, Rollback = ein Revert.
