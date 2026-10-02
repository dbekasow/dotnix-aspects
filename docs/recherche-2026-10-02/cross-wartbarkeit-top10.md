# Querschnitt-Gutachten 4/6 — Top-10-Wartbarkeits-Interventionen (.dotnix-aspects)

Datum: 2026-10-02 · Dimension: WARTBARKEIT (Hebelkraft = Impact auf die tägliche Arbeit ÷ Aufwand)
Material: 10 Forschungsberichte + 9 Orakel-Gutachten (/tmp/dotnix-research/) · Schlüsselbelege stichprobenartig selbst am Repo verifiziert (HEAD ac7724c; Working tree M modules/aspects/term/shell-ux/sesh.nix unberührt; keine nix-Kommandos, keine Repo-Änderungen).

## Urteil in einem Satz

Das Repo braucht keinen Architektur-Umbau — das Dendritic-Muster hält in allen tragenden Invarianten (drei Orakel unabhängig) — sondern Vertrags- und Hygiene-Arbeit an fünf Fronten: (1) der öffentliche Verbraucher-Vertrag wird von keinem Test evaluiert (Template nachweislich eval-kaputt, README beschreibt Phantom-Dateien), (2) der DMS-Stack führt einen 457-Zeilen-Schema-Snapshot mit 180 toten Keys als AKTIVE Konfiguration mit, (3) die wöchentliche Update-Pipeline hat zwei Defekte (Helix-Input seit 9 Wellen still eingefroren, Auto-Merge mit reinem Eval-Gate), (4) die Alltagswerkzeuge Shell/Editor tragen nachweisliche Doppel-/Tot-Bestücke (fastfetch in jedem tmux-Pane, 4 Finder-Schichten, 2-3 LSP-Server pro Buffer), (5) die physische Struktur lügt in ~15 Fällen über die Aktivierungs-Realität (git in development/, aktiviert in core.nix; fonts in core/, aktiviert in desktop.nix; 3 tote Module; 6 Dateinamen ohne Aspektbezug).

## Top-10 (sortiert nach Hebelkraft)

| Nr | Intervention | Warum (täglicher Hebel) | Impact | Aufwand | hängt ab von |
|---|---|---|---|---|---|
| 1 | Verbraucher-Vertrag absichern: Template reparieren + CI-Verbraucher-Fixture + README korrigieren | Export ist das Produkt, wird aber nie in der Konsumenten-Rolle getestet; 4 bestätigte Brüche (Template-Case, fehlendes core, README-Phantome, dsearch-Verdacht) wären von der Fixture im PR gefangen worden | hoch | 4-5 h | keine; ermöglicht Build-Gate (Nr. 4), sichert Nr. 5/6 ab |
| 2 | Alltagsreibung eliminieren: fastfetch-TMUX-Guard + Finder-/LSP-Konsolidierung | Jedes tmux-Pane zahlt 100-300 ms fastfetch, jeder .nix/.md-Buffer startet 2-3 LSP-Server, jede fish-Start-Serie sourced 4 Finder-Integrationen (2 davon tot) — höchster Impact pro Arbeitsstunde im Gutachten | hoch | 2 h | keine (Mail-Takt/difftastic = 30-Sekunden-Eigentümerentscheid) |
| 3 | DMS-Stack entkernen: dms-settings.nix auf ~24 echte Deltas kürzen, dsearch + mkForce-Block entsorgen | 457-LOC-Snapshot (180 tote Keys, configVersion 5 vs. DMS-intern 33) kämpft wöchentlich gegen DMS-Bumps und jeden HM-Switch (Doppel-Writer) | hoch | 3-4 h | Laptop-Konsument/Pin klären (0,5 h); Eigentümerentscheid über ~24 Abweichungen |
| 4 | Update-Pipeline reparieren: Helix-Input streichen, Actions pinnen, Build-Gate vor Auto-Merge | Kern-Editor seit 9 Wellen still eingefroren (2026-07-23); wöchentlicher Auto-Merge mit eval-only Gate lässt Build-Brüche erst am Desktop erscheinen | hoch | 3-4 h | Build-Gate braucht Fixture-Host aus Nr. 1 |
| 5 | Export-Split: Dev-Tooling aus flakeModule-Export; debug=false | Jeder nix-Befehl des Konsumenten evaluiert Bibliotheks-Devshell/treefmt/prek + debug-Introspektions-Spiegel mit; Konsumenten führen Outputs, die sie nie deklariert haben | mittel-hoch | 3-4 h (+1 Zeile Konsument) | koordinierter Breaking Change mit .dotnix |
| 6 | Struktur- & Namens-Sweep: 3 tote Module löschen, Datei-Lage an Aktivierung angleichen, Renames, Options-Hygiene | Kernklage "wo muss ich suchen?": Ordner und Aggregator laufen auseinander, 6 Dateinamen verraten den Aspekt nicht, 3 Alternativ-Module verwirren ohne Funktion | mittel (hoch auf Navigationsfristion) | 4 h | ideal nach Nr. 1 (Fixture fängt Renames ab); reine git mv |
| 7 | Lock-Pflege selektiv: agenix-rekey-Dev-Kette kollabieren, nixpkgs-stable-Follows, dank-qml-common vereinheitlichen, Fork begründen | Wöchentliche Update-PRs werden reviewbar; QML-Basis von Shell und Greeter läuft nicht mehr auseinander; 2. nixpkgs-Instanz + Churn weg | mittel | 1,5 h | keine; bewusst NICHT stylix/NUR-Pins anfassen |
| 8 | Hibernation-Kette vervollständigen: resume_offset host-seitig + Warn-Kommentar | suspend-then-hibernate an jedem Deckel; ohne resume_offset bootet der Laptop nach Hibernate mit FRISCHER Session (stiller Datenverlust, keine canhibernate-Warnung) | hoch (Schwere), mittel (Frequenz) | 1-2 h | Laptop-Host (Consumer-Repo); Offset maschinenabhängig |
| 9 | Personal-Config aus öffentlichen Aspekten lösen: masterIdentities als Option, Pfad-Konventionen dokumentieren | age-rekey.nix hardcodiert private Pubkeys + Konsumenten-Layout in jeden fremden Merge; Public-Release-Sicherheits- und Funktionsblocker | mittel-hoch | 3 h | koordiniert mit Konsumenten-Repo (Werte dorthin) |
| 10 | disko aus dem system-Collector nehmen | Gemessen +7 s auf JEDER Host-Eval (3,4 → 10,6-11,5 s) für ein Layout-Modul, das nach Installation nie wieder gebraucht wird — jeder nh os switch zahlt | mittel | 1-2 h | Hosts/Templates listen disko dann explizit; Nr. 1 sichert ab |

Gesamtaufwand Top-10: ca. 25-28 h; die Top-5 allein ca. 16-18 h.

---

## Details je Intervention

### Nr. 1 — Verbraucher-Vertrag absichern: Template + README + CI-Fixture

**Was genau:**
- templates/dotnix/modules/hosts/myHost/configuration.nix: members = [ "myuser" ] (Case-Fix, ein Zeichen — User-Datei deklariert "myuser") UND core in die modules-Liste. Ohne core existiert die Option home-manager.users nicht (einzige Import-Stelle des HM-NixOS-Moduls: modules/aspects/core/home-manager.nix:4); mit members = [ "myUser" ] wirft attrVals zusätzlich 'attribute myUser missing'.
- .github/workflows/flake-check.yml: neuer Job, der das Template instanziiert (nix flake new -t .#dotnix) und nixosConfigurations.myHost.config.system.build.toplevel.drvPath evaluiert; falschen Kommentar Zeile 27 ("covers: treefmt, deadnix, ...") ersetzen — die Hooks laufen ausschließlich lokal via prek, nicht in CI.
- README.md: Referenzen modules/options.nix und factories.nix (existieren nicht) auf modules/parts/configuration.nix umbiegen; Aussage "injecting core modules automatically" streichen (bewusst entfernt in Commit 880c2b1, 2026-04-20 — Doku nie nachgezogen); Pfad-Konventionen dokumentieren: modules/hosts/<host>/secrets/*.pub, modules/users/<user>/secrets/home-key.pub, Wallpaper, Consumer-Wurzel yubikey.pub/masterkey.age.

**Warum die tägliche Arbeit besser wird:** Der Export (132 Aspekte + Factory + expose.nix-Wrapping) ist das Produkt dieser Bibliothek — und wird von keinem einzigen Test in der Konsumenten-Rolle evaluiert. Vier bestätigte Schäden sind genau durch diese Lücke entstanden, unentdeckt über Monate. Mit der Fixture bedeutet ein Bruch künftig einen roten CI-Lauf statt eine Debugging-Session im eigenen System; auch der wöchentliche Auto-Merge bekommt erstmals einen realen Test-Rücken (siehe Nr. 4). Drei Orakel haben diese Fixture unabhängig voneinander zur Prio 1 gemacht.

**Impact:** hoch · **Aufwand:** 4-5 h · **Abhängigkeiten:** keine; ist Ermöglicher für Nr. 4 (Build-Gate) und Absicherung für Nr. 5/6.

### Nr. 2 — Alltagsreibung eliminieren: fastfetch-Guard + Finder-/LSP-Konsolidierung

**Was genau:**
- modules/aspects/term/monitoring/fastfetch.nix:25: body = "if not set -q TMUX; fastfetch; end" — Guard exakt wie im eigenen sesh-Autostart (sesh.nix:51-55), der beweist, dass der Fall gedacht war, nur nicht hier.
- Finder-Konsolidierung: programs.skim.enableFishIntegration = false (sk-Binary bleibt als sesh-Picker-Backend); fishPlugins.fzf aus fish.nix entfernen (vierte Finder-Schicht, deren Bindings vollständig tot sind). Faktischer Hausstandard ist bereits entschieden: fzf-nativ für Ctrl-T/Alt-C, atuin für Ctrl-R (deterministisch, verifiziert an gebauten HM-Generationen).
- LSP-Halbierung: nil aus helix-lsp/nix.nix streichen (language-servers = ["nixd" "nil"] → ["nixd"]; nixd ist der konfigurierte Server mit Flake-Live-Eval); marksman aus markdown.nix (markdown-oxide bleibt; .md-Buffer von 3 auf 2 Server); statix/deadnix aus extraPackages (nicht an Helix-Diagnostik gebunden, reiner PATH-Ballast).
- Optional (Eigentümerentscheid, je 15-30 min): difftastic-Modul streichen (git läuft über delta, kein difftool-Wiring, lazygit-Eintrag garantiert tot neben Delta-Catch-all); mbsync auf EINEN Sync-Pfad festlegen (Timer *:0/15 ODER preNew-Hook — aktuell doppelt); NixOS-gpg-Agent-Zeilen in term/secrets/gpg.nix:3-5 entfernen oder begründen (HM-Agent überspielt zur Laufzeit).

**Warum die tägliche Arbeit besser wird:** Terminal und Editor sind die Werkzeuge, die stündlich angefasst werden. Heute zahlt jedes tmux-Pane/Popup 100-300 ms fastfetch (fish_greeting ohne TMUX-Guard, verifiziert fastfetch.nix:23-26), jede fish-Serie sourced fzf-nativ + fzf.fish-Plugin + skim + atuin (drei Schichten mit überlappenden Bindings, zwei vollständig tot), jeder .nix-Buffer startet zwei Server (nixd evaluiert die Flake live — auf diesem Repo mit 21 Inputs spürbar), jeder .md-Buffer drei. Danach: schnelleres Pane-Öffnen, eindeutige Bindings, halbierte Serverzahl — weniger Zustand zu warten UND weniger zu warten (im doppelten Sinne).

**Impact:** hoch · **Aufwand:** 2 h (Kernmenge; Einzelposten 0,25-1 h) · **Abhängigkeiten:** keine.

### Nr. 3 — DMS-Stack entkernen: dms-settings.nix kürzen, dsearch + mkForce-Block entsorgen

**Was genau:**
- modules/aspects/desktop/shell/dms-settings.nix (457 LOC; live: registriert homeManager.dms in Zeile 2, desktop.nix importiert dms — eigene Verifikation) auf die ~24 echten Abweichungen (~40 LOC) kürzen. Orakel-Abgleich gegen SettingsSpec.js des gepinnten DMS (a609b5f): 172 Keys exakte Upstream-Defaults, 180 Keys im aktuellen Schema nicht mehr existent (tote Keys, u. a. showCpuUsage, spotlightCloseNiriOverview, brightnessDevicePins), configVersion = 5 (Zeile 454) vs. DMS-intern 33. configVersion-Zeile streichen (DMS verwaltet sie selbst). Komplexe Werte (barConfigs, appIdSubstitutions, controlCenterWidgets, cursorSettings, powerMenuActions) vorher gegen Upstream-Defaults diffen.
- dms.nix:12: programs.dsearch.enable = true — Option existiert in keinem gepinnten Input (Orakel-Verifikation am DMS-Tarball: 0 nix-Treffer). 5-Minuten-Check (nix flake check), dann Relikt löschen.
- dms.nix:41-64: kompletten lib.mkForce-niri-Block löschen — Upstream generiert beim gepinnten Rev die identische config.kdl inkl. Border-Fix und optional-Includes (einziger Diff: lokales hartes hm-Include). Vorher gerenderte config.kdl diffen.
- batteryProfileName = "power-saver" (dms-settings.nix:209): bewusste Abweichung (CPU-Throttle auf Akku) — dokumentieren oder auf DMS-Default "" zurücksetzen.

**Warum die tägliche Arbeit besser wird:** DMS wird wöchentlich gebumpt (Lock-Revs 2026-09-27/28) — mit dem Snapshot wird jede Welle ein 457-Zeilen-Diff-Kandidat voller toter Keys. Doppel-Writer: HM generiert settings.json, DMS SettingsStore migriert/schreibt sie zur Laufzeit selbst — jeder HM-Switch rollt den Alt-Stand über Live-Änderungen zurück, jede DMS-Session läuft die komplette 5→33-Migrationskette, restartIfChanged = true startet die Shell über. Nach der Kürzung: DMS-Bump = 40-Zeilen-Diff statt Schema-Archäologie, DMS-GUI-Änderungen überleben Switches, Migrations-Churn weg. Wichtig: Datei ist nachweislich AKTIV (Collector-Merge mit dms.nix:20), Kürzung also mit DMS-GUI-Gegenprobe fahren.

**Impact:** hoch · **Aufwand:** 3-4 h · **Abhängigkeiten:** Laptop-Konsumenten klären (welcher Aspects-Pin fährt der Desktop — dead-dupes-Orakel Prio 1, 0,5 h); Eigentümerentscheid über die ~24 Abweichungen.

### Nr. 4 — Update-Pipeline reparieren: Helix streichen, Actions pinnen, Build-Gate

**Was genau:**
- Helix-Eigen-Input streichen (Empfehlung development-Orakel, hohe Konfidenz): flake.nix:36-37, Overlay+Substituter-Block editors/helix.nix:1-8, helix aus development.nix nixos-Imports. Beweislage: Lock hängt seit PR #17 bei 079a789e (2026-07-23; selbst verifiziert am Lock: helix 2026-07-23 vs. nixpkgs 2026-09-27), obwohl 9 folgende Wellen (#18-#26) je 20+ Inputs bewegten; helix.cachix.org ist durch follows = "nixpkgs" praktisch blind (CI baut gegen Helix-Eigenlock); "master"-Nutzen = null bei 2 Monate altem Pin. Alternative bei konkretem master-Feature-Bedarf: follows streichen + Bump-Rhythmus — aber genau diese Disziplin fehlt nachweislich seit 9 Wochen.
- .github/workflows: update-flake-lock@main und flake-checker-action@main auf feste Versionen pinnen (Freeze-Beginn des Helix-Inputs passt zeitlich zum @main-Floaten; Wurzel ohne nix-Lauf nicht final beweisbar — Empfehlung gilt unabhängig davon).
- Build-Gate vor Auto-Merge: nix build des Fixture-Host-Toplevels (aus Nr. 1) in flake-check.yml. Aktuell mergt gh pr merge --auto --squash wöchentlich 9-20 Inputs mit reinem Eval-Gate — nix flake check baut keine Closures, Build-Brüche erscheinen erst beim nixos-rebuild am Arbeitsgerät.
- Optional: Kadenz 2 Wochen (cron 0 4 1,15 * *) — halbiert die lokalen Source-Builds des AvengeMedia-Stacks (für dms/dank-greeter/dms-plugins existiert kein Binary-Cache, verifiziert).

**Warum die tägliche Arbeit besser wird:** Die Pipeline ist der Taktgeber des Repos (22 Update-Merges in 186 Commits). Zwei bestätigte Defekte: Der Kern-Editor aktualisiert sich still seit 2 Monaten (Besitzer glaubt wöchentlich aktuell zu sein), und der Auto-Merge testet nie einen Build. Reparatur = das Wochenereignis "Lock-Update" wird wieder vertrauenswürdig; jede der anderen Interventionen wird erst durch dieses Gate nachhaltig abgesichert.

**Impact:** hoch · **Aufwand:** 3-4 h (Helix-Streichung allein 1 h) · **Abhängigkeiten:** Build-Gate braucht Fixture-Host aus Nr. 1; Helix-Streichung: Smoke-Test (hx startet, Version = nixpkgs-Release).

### Nr. 5 — Export-Split: Dev-Tooling aus dem flakeModule-Export

**Was genau:**
- modules/expose.nix: statt (i: i.addPath parts/) (ganzes Verzeichnis) nur die pflichtigen Parts wrappen: parts/flake-parts.nix (OHNE debug-Zeile — liefert die flake.modules-Option, ohne die alle 132 Aspekte tot sind), parts/configuration.nix (Factory), parts/age.nix (rekey-App, hängt am Template-Justfile), parts/home-manager.nix (konservativ mitnehmen). Dev-Tooling — devshell.nix, treefmt.nix, pre-commit.nix, templates.nix — nur noch in der eigenen Repo-Eval (flake.nix fährt import-tree ./modules unverändert weiter) bzw. als Opt-in-Zweitexport (flake.flakeModuleDevTools oder flake-parts-Konvention flakeModules.default).
- Quick-Win vorab (15 min, isoliert vorausziehbar): debug = lib.mkDefault true (parts/flake-parts.nix:5) streichen. Upstream-Default false; debug zwingt flake-parts, die gesamte Options-/Config-Struktur als Introspektions-Spiegel zu evaluieren — auf jedem flake show/repl/outputs-Walk des Konsumenten.
- Konsumenten (.dotnix + Template) um eine Import-Zeile erweitern.

**Warum die tägliche Arbeit besser wird:** Jeder nix-Befehl im Konsumenten-Repo evaluiert heute stillschweigend die Bibliotheks-Devshell, treefmt-Defaults inkl. formatter-Output, prek-Hooks, einen templates.default-Output (kollidiert mit einem eigenen) und den debug-Spiegel der gesamten Consumer-Config. Konsumenten-Flakes führen Outputs, die sie nie deklariert haben — das sind Merge-Überraschungen und Eval-Ballast bei jedem rebuild/direnv/switch, und zwar dauerhaft, weil der Default-Zustand Injektion statt Opt-in ist.

**Impact:** mittel-hoch · **Aufwand:** 3-4 h (+1 Zeile Konsument) · **Abhängigkeiten:** koordinierter Breaking Change mit dem Konsumenten-Repo; grep-Verifikation, dass kein Aspekt entfernte Parts-Registrierungen braucht.

### Nr. 6 — Struktur- & Namens-Sweep

**Was genau:**
- 3 tote Module löschen (selbst verifiziert — null externe Referenzen): modules/aspects/core/yubikey-lock.nix, modules/aspects/desktop/greeter/tuigreet.nix, modules/aspects/system/boot-limine.nix.
- Datei-Moves an die Aktivierungs-Realität (reine git mv; import-tree ist pfadstabil, Aspektnamen und Tier-Listen bleiben unverändert): git/git-alias/git-credentials/git-repos + llm-agents → core/ (aktiviert in core.nix); skills/tuicr/workmux → term/ (aktiviert in terminal.nix); fonts.nix → desktop/ (aktiviert in desktop.nix); nix-ld.nix → development/; performance.nix → system/ (aktiviert in system.nix).
- Namens-Hygiene (~6 echte Fälle, Renames gratis dank import-tree): skills.nix → ai-tools.nix; k9s.nix → kubernetes.nix; television-nix.nix → nix-search-tv.nix mit EIGENEM Aspektnamen homeManager.nix-search-tv (löst die Fusion zweier verschiedener Programme auf einem Namen); gpg.nix splitten (gnupg + gpg-agent), yubikey.nix splitten (yubikey-pam eigene Datei).
- Options-Hygiene: hostname-Option (parts/configuration.nix:33 — type = str; default = null ist eine latente Typverletzung) → nullOr str oder Default streichen; descriptions für die dotnix-Options nachziehen (Hausstandard: term/shell-ux/tmux-popups.nix); No-op-Aspekt bash.nix löschen; leere Settings (eza.nix, bacon.nix, nushell.nix, ripgrep-all.nix, bottom.nix, json.nix) kürzen; ZFS-Doppelsetzung (boot.nix:22 vs. configuration.nix:46) vereinheitlichen.
- Doku statt Umbau: README-Absatz "Tier-Dateien an modules/aspects/*.nix = Kompositionslayer, Gruppen = Themenregale" + Impermanence-Audit-Einzeiler (grep -rn home.persistence modules/). NICHT die 22 Inline-Impermanence-Fragmente rekonstruieren (Bestform: App-Datei löschen = Persistenz-Spuren weg).

**Warum die tägliche Arbeit besser wird:** Die Ordner sind die Navigationsebene des Musters. Heute: git-Config suchen → development/vcs/, aktiviert aber in core.nix:8 ("development abschalten" lässt git + die gesamte KI-Schiene an); fonts liegt in core/, gehört zu desktop; llm-agents (ein nixpkgs-Overlay) steckt im "minimalen" core; 6 Dateinamen verraten den Aspekt nicht. Jede dieser Suchen zahlt grep-Steuer; der Sweep macht den Dateinamen wieder zur Dokumentation und räumt 3 verwirrende Alternativ-Module ab, die dokumentieren müssten.

**Impact:** mittel (direkt auf die Kernklage "Struktur") · **Aufwand:** 4 h · **Abhängigkeiten:** ideal nach Nr. 1 (Fixture evaluiert den Konsumenten-Merge nach jedem Move).

### Nr. 7 — Lock-Pflege selektiv

**Was genau:**
- agenix-rekey-Dev-Kette per follows kollabieren: agenix-rekey.inputs.devshell/treefmt-nix/pre-commit-hooks auf die Root-Inputs. Die 2024/25er-Stände (devshell 2024-10-07, treefmt-nix 2024-12-25, pre-commit-hooks 2025-01-03) sind agenix-rekeys eigene gefrorene Upstream-Lock-Pins — nix flake update kann sie prinzipiell nicht bewegen; follows ist hier risikoarm (DevShell-only, nie im Modulpfad), ca. -6 Lock-Nodes.
- niri.inputs.nixpkgs-stable.follows = "nixpkgs" + Kommentar (niri-stable/xwayland-satellite-stable sind ungenutzt, grep-verifiziert) — killt die zweite nixpkgs-Instanz und ihren wöchentlichen Churn.
- dank-qml-common per follows vereinheitlichen (dms.inputs + dank-greeter.inputs) — aktuell rollen zwei verschiedene Revs desselben QML-Fundaments wöchentlich getrennt (660b044 vs. a88b16e): Shell- und Greeter-Basis können auseinanderlaufen.
- niri-Fork begründen oder zurückrollen: epireyn/niri-flake (Wechsel in 417528f ohne Grund-Kommentar; aktuell synced mit sodiboo) — Kommentar in flake.nix oder URL-Rollback.
- Bewusst NICHT (lock-hygiene-Orakel-Anti-Empfehlung): stylix/NUR-Transitive per follows kollabieren, Lock-Diät auf ~30 Nodes, agenix-rekey.inputs.flake-parts auf Root folgen — Upstream-Pins, eval-grün über 24 Wellen; reine Ästhetik mit realem Pairing-Risiko.

**Warum die tägliche Arbeit besser wird:** Die wöchentlichen Update-PRs schrumpfen und werden reviewbar; Divergenz-Kandidaten (2 QML-Basen, 2 nixpkgs, 6 flake-parts-Nodes) verschwinden bzw. werden begründet. Kein Runtime-Gewinn — reine Wartlast-Reduktion an genau der Stelle, die jede Woche bewegt wird.

**Impact:** mittel · **Aufwand:** 1,5 h · **Abhängigkeiten:** keine.

### Nr. 8 — Hibernation-Kette vervollständigen (resume_offset)

**Was genau:** Consumer-seitig pro Hardware-Host boot.kernelParams = [ "resume_offset=<filefrag -v /swap/swapfile>" ]; in modules/aspects/system/power.nix Warn-Kommentar an boot.resumeDevice (Zeile 29): Btrfs-Swapfile (disko.nix:50-54, Subvol @swap) braucht zwingend resume_offset — resume= allein genügt nur für Partitionen. Test: Hibernate → Kaltstart → Session intakt. Swapfile-Erzeugung durch disko setzt NOCOW korrekt; es fehlt nur der Offset, systemweit (grep über beide Repos: null Treffer).

**Warum die tägliche Arbeit besser wird:** suspend-then-hibernate steht an jedem Deckel-/Power-Event (HibernateDelaySec 30 min, criticalPowerAction Hibernate). Ohne resume_offset gelingt der Hibernate-Schrieb (Kernel überspringt zram), aber der Resume bricht: nächster Boot = frische Session, stiller Datenverlust, ohne canhibernate-Warnung. Das Template deployt system auf das Ziel-Laptop (dell-precision-5570) — der erste Deckel-zu-Hibernate nach 30 Minuten kostet sonst die Session.

**Impact:** hoch (Schwere des Versagens), mittel (tägliche Frequenz) · **Aufwand:** 1-2 h · **Abhängigkeiten:** Laptop-Host im Consumer-Repo; Offset maschinenabhängig; ein Laufzeit-Test ersetzt die statische Beweisführung.

### Nr. 9 — Personal-Config aus öffentlichen Aspekten lösen

**Was genau:** modules/aspects/core/age-rekey.nix:10-19 — masterIdentities (Pfade yubikey.pub/masterkey.age + Inline-Pubkeys des Autors, selbst verifiziert) in eine dotnix-Option überführen, persönliche Werte ins Konsumenten-Repo; secretsDir-Layout (Zeile 6: modules/hosts/<hostname>/secrets), certDir (certificates.nix:5), Wallpaper-Pfad (stylix.nix:51) als dokumentierte Optionen mit heutigen Defaults; age-rekey.nix:9 unguarded lib.readFile mit pathExists-Guard versehen (Muster existiert in certificates.nix:6).

**Warum die tägliche Arbeit besser wird:** Der Aspekt wandert via core.nix in JEDES Konsumenten-System. Für Fremde: Rekey bricht (Identitätsdateien fehlen im eigenen Repo) — schlimmer: deren Secrets würden an die Pubkeys des Autors rekeyt. Für den Eigentümer: die Grenze Bibliothek/Konsumenten bleibt unscharf, jede Layout-Änderung greift in die Bibliothek. Der Branch heißt refactor/public-release, README sagt "reusable library", Lizenz ist MIT — das ist ein Blocker für genau das anvisierte Ziel.

**Impact:** mittel-hoch · **Aufwand:** 3 h · **Abhängigkeiten:** koordiniert mit dem Konsumenten-Repo (Werte dorthin); Option-Registrierung in parts/configuration.nix; baut auf README-Doku aus Nr. 1 auf.

### Nr. 10 — disko aus dem system-Collector nehmen

**Was genau:** modules/aspects/system.nix:7 — disko aus nixos.system.imports herauslösen; Hosts mit dem Layout-Modul listen ihn explizit (so wie der Live-Host core explizit listet). Messung (eval-perf-Bericht, gleicher nixpkgs-Pin, je 3 Läufe): toplevel.drvPath core+system ohne disko 3,4-3,5 s; mit disko 10,6-11,5 s — Delta +7 s, während alles andere System-Andere (boot, network, pipewire) zusammen ≈ +0 s kostet. impermanence bleibt im Tier (Eval ~0, aber Kompositions-Vertrag impermanence ⇒ disko in derselben Bewegung dokumentieren).

**Warum die tägliche Arbeit besser wird:** Jeder nh os switch / nixos-rebuild dry-activate des Hosts zahlt +7 s Evaluierung für ein Disk-Layout-Modul, das nach der Installation i. d. R. nie wieder gebraucht wird — und das bei jedem Host, der den system-Collector zieht (das Template tut es). Eval-Latenz ist die am häufigsten gespürte Wartezeit im Nix-Alltag.

**Impact:** mittel · **Aufwand:** 1-2 h · **Abhängigkeiten:** Template/myHost muss disko anschließend explizit listen; Fixture aus Nr. 1 fängt die Verschiebung ab.

---

## Bestätigte Pflicht-Befunde (explizite Berücksichtigung)

- **dms-settings.nix (Schema-Snapshot):** selbst verifiziert — 457 LOC, Registrierung unter homeManager.dms (Zeile 2; Collector-Merge mit dms.nix:20, Import via desktop.nix), configVersion = 5 (Zeile 454), durchweg Plain-Assignments. Orakel-Abgleich gegen den gepinnten DMS-Rev: 172 exakte Upstream-Defaults, 180 tote Keys, DMS-intern configVersion 33, Doppel-Writer auf settings.json (HM generiert, DMS SettingsStore migriert/schreibt selbst). → Intervention Nr. 3.
- **Tote Module:** selbst verifiziert — yubikey-lock.nix, tuigreet.nix, boot-limine.nix haben null externe Referenzen (eigener Referenz-Scan; deckt sich mit dem unabhängigen Python-Graphen des dead-dupes-Orakels, das keine weiteren Toten findet). → Intervention Nr. 6.
- **Template-/README-Brüche:** selbst verifiziert — Template-Host members = [ "myUser" ] vs. Template-User let user = "myuser" (Case-Mismatch → attribute missing); Host-Module ohne core → home-manager.users-Option undefiniert (einzige HM-NixOS-Import-Stelle: core/home-manager.nix:4); README referenziert modules/options.nix und factories.nix (existieren nicht) und behauptet Core-Injektion, die seit 880c2b1 (2026-04-20) bewusst entfernt wurde. → Intervention Nr. 1.
- **Pipeline-Defekte (Helix-Input eingefroren):** selbst verifiziert — flake.nix:36-37 helix unpinned, Lock-Rev 079a789e8cb0 vom 2026-07-23 (nixpkgs: 2026-09-27), 9 Wellen ohne Bewegung; update-flake-lock@main und flake-checker-action@main floating; Auto-Merge (--auto --squash) mit eval-only Gate; falscher "# covers:"-Kommentar in flake-check.yml:27. → Intervention Nr. 4.

## Empfohlene Reihenfolge

1. Sofort, ohne Abstimmung (je 1 Zeile): fastfetch-Guard (Nr. 2) und debug=false (Quick-Win aus Nr. 5).
2. PR 1: Nr. 1 komplett (Template + README + Fixture) — die Keuzelle; hätte alle vier Pflicht-Befunde im PR gefangen.
3. PR 2: Rest Nr. 2 (Finder/LSP) + Helix-Streichung aus Nr. 4.
4. Klärung Laptop-Konsument (0,5 h, dead-dupes Prio 1) → PR 3: Nr. 3 (DMS) mit DMS-GUI-Gegenprobe.
5. PR 4: Nr. 4 Rest (Action-Pins, Build-Gate auf der Fixture, optional Kadenz).
6. PR 5: Nr. 5 (Export-Split, koordiniert mit .dotnix).
7. Verteilt: Nr. 6 (Struktur-Sweep), Nr. 7 (Lock), Nr. 9 (Personal-Config), Nr. 10 (disko); Nr. 8 host-seitig beim nächsten Laptop-Termin.

## Risiken und offene Punkte

- **Laptop-Konsument unsichtbar:** Weder .dotnix (historisch nur WSL-Host dmi) noch ein anderes sichtbares Repo erreicht den desktop-Ast; frische Desktop-Commits (Performance-Tuning 2026-09-11) belegen aber einen Live-Konsumenten außerhalb des Horizonts (Azure-Remote ohne Credentials). Alle Desktop-Aussagen gelten auf Bibliotheksebene; die 0,5-h-Klärung (welcher Pin fährt der Desktop) ist Voraussetzung für die Bewertung von Nr. 3/8 am gefahrenen System.
- **Live-Pin hinkt:** .dotnix pinnt dotnix auf 0c33875 — 8 Commits hinter HEAD, der Aufräum-Commit 8b408a9 ist dort NICHT enthalten. Bibliotheksbefunde ≠ gefahrener Stand bis zum nächsten Lock-Bump.
- **dsearch-Finalbeweis:** Die Option existiert in keinem gepinnten Input (Orakel-Verifikation am DMS-Tarball a609b5f); der letzte Beweis braucht einen nix flake check (in dieser Recherche per Auftrag verboten).
- **dms-settings ist AKTIV:** Entgegen einer Einzelbehauptung im runtime-perf-Orakel ist die Datei erreichbar — eigene Verifikation: dms-settings.nix:2 und dms.nix:20 registrieren beide homeManager.dms; desktop.nix importiert dms. Die Kürzung (Nr. 3) ist also kein Ballast-Recycling, sondern ein Eingriff in aktive Konfiguration — mit Gegenprobe in der DMS-GUI fahren.
- **SPEC-Abgleich-Zahlen** (180 tote Keys, v33) stammen aus dem automatisierten Abgleich des desktop-Orakels; strukturell selbst verifiziert (457 LOC, configVersion = 5, Plain-Assignments), die Zahlen selbst nicht erneut durchgelaufen.
- **Eval-Zahlen** (disko +7 s) mit ±1,5 s Varianz unter Parallel-Load gemessen; Richtung und Größenordnung durch 3 Läufe je Konfiguration robust.
- **resume_offset-Folge-Analyse** (Schrieb gelingt, Resume bricht) beruht auf Kernel-Allgemeinwissen; ein einziger Laufzeit-Test am Ziel-Laptop klärt final — Aufwand gerechtfertigt unabhängig davon (gering, Schaden hoch).
- **Wurzel des Helix-Freezes** (Action@main-Änderung vs. Runner-Cache) offline nicht beweisbar; die Empfehlung (Input streichen) gilt unabhängig von der Wurzel.
