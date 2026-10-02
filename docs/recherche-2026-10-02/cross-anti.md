# Querschnitts-Orakel 6/6 — Anti-Empfehlungen (.dotnix-aspects)

Datum: 2026-10-02 · Material: 10 Forschungsberichte + 9 Orakelgutachten aus `/tmp/dotnix-research/`, eigens stichprobenartig am Repo verifiziert (alle `path:line`-Angaben unten selbst gelesen; keine nix-Kommandos, nichts am Repo geändert).

Kernbotschaft: **Die Architektur ist nicht das Problem — sie ist das Asset.** Der Dendritic-Kern (Import-Konvention, Klassen-Disziplin, Collector, Granularität) ist adversarial verifiziert intakt; die echten Defekte sind Ausführungslücken (Template eval-brochen, Export-Leak, debug-Default, dms-settings-Snapshot, Helix-Eingefroren) und inhaltliche Desktop-Einstellungen (Ghostty-Shader, Akku-Profil, dsearch, fastfetch). Fast jede naheliegende "Struktur-Modernisierung" wäre Geld für nichts. Wichtigster Erwartungs-Dämpfer vorweg: Der träge Desktop fährt nach heutigem Erkenntnisstand **aus keinem der sichtbaren Repos** (`.dotnix` hat historisch nur den WSL-Host `dmi` mit `modules = [ core wsl development ]`; Laptop-Konsument ungeklärt, Live-Pin 8 Commits hinter HEAD) — jeder Bibliotheks-Umbau ist für das gefahrene System spekulativ, bis die Flake-Quelle des Laptops geklärt ist (dead-dupes-Orakel P1).

---

## Nicht tun

Format je Eintrag: **Verbot** | Begründung | Bezug auf Befund.

### A. Architektur & Struktur

**A1. Hosts in dieses Repo ziehen / Bibliothek zu einem Dotfiles-Flake machen.**
Bibliothek ohne Hosts ist die einzige Form, in der 132 wiederverwendbare Aspekte für einen Public Release Sinn ergeben; `config.dotnix` ist im Bibliotheks-Repo bewusst leer (wiring.md Summary; `modules/parts/configuration.nix:37-49` ist reine Factory). Ein Dogfood-Host hier würde die Trennung kippen (persönliche Hardware-Module zurück in die Library — genau das leben die Templates nicht vor). Der Weg über das angedachte Zielgerät ist das Template-Hardware-Modul `dell-precision-5570`, nicht eine Host-Deklaration.
Bezug: wiring.md (HIGH/Medium-Lage), oracle-wiring HQ4 ("Ja" zur Architektur), dendritic.md Summary, dead-dupes.md (Konsumenten-Schema).

**A2. Aspect-Granularität radikal ändern (Dateien wholesale mergen "wegen 141 Dateien" oder noch feiner splitten).**
Eval-Kosten von Import-tree + flake-parts über 141 Dateien: **0,15–0,5 s gemessen** — Dateizahl ist kein Perf-Faktor. Ein-Tool-eine-Datei-ein-Aspekt ist der Kernwert des Patterns; die Granularität ist adversarial als "genau richtig" bewertet (shell-ux 14, monitoring 10, files 10, helix-lsp 9 Dateien). Einzige echte Granularitäts-Störung läuft in die Gegenrichtung: `television` + `television-nix` verschmelzen zwei Programme auf einem Aspektnamen — das ist ein Rename, kein Umbau.
Bezug: eval-perf.md LOW (Messung), oracle-dendritic (Granularitäts-Antwort, High 2), term.md H3.

**A3. Alles auf eigene `enable`-Flags umstellen.**
Repo lebt konsequent "enabling is importing": verifiziert genau 2 Dateien mit `mkEnableOption` im ganzen Baum (`term/shell-ux/tmux-bindings.nix:40`, `tmux-popups.nix:31`), core+system haben **null** eigene enable-Flags (alle 23 `enable`-Setzer sind nixpkgs-native Optionen). Eigene Flags pro Aspekt wären Boilerplate plus doppelte Verdrahtung (Import UND Flag) plus Widerspruch zum Hausmuster. Wo Gating nötig ist, ist das richtige Werkzeug bereits im Gebrauch: `mkIf config.programs.<upstream>.enable` (verifiziert `fastfetch.nix:23`) und `inherit (X) enable` in tmux-popups. Nachzuziehen sind nur die **ungegaten** Popup-Einträge (bluetui/wifitui, term.md M3) — kein Flag-Framework.
Bezug: core-system.md Positiv-Bestand, oracle-core-system M3/L-Bestand, term.md M3.

**A4. Host-Registry auf Host-Features (Import-Graph) migrieren.**
`parts/configuration.nix` **ist** die Factory, die das README als "factories.nix" beschreibt; die members-getriebene Secrets-/User-Generierung (`users.nix`, `age.nix`, `nh.nix`, `docker.nix`, `dms-greeter.nix` lesen `config.dotnix.host.members`) hängt an der Registry. Der Motivationsfall (String-`members` → Case-Bug `myUser`/`myuser` im Template, verifizert) ist ein Ein-Zeichen-Fix plus CI-Template-Fixture; die Migration wäre ein mehrtägiger Breaking Change ohne aktuellen Bedarf.
Bezug: oracle-dendritic HQ3, dendritic.md Medium 4, dead-dupes.md HIGH-2.

**A5. Kompositions-Assertions / Constraint-Layer bauen (core⇒impermanence, system⇒disko).**
core IST standalone-fähig: Alle `/persist`-Fragmente liegen sauber gebündelt im Modulnamen `impermanence` (verifiziert `core/age.nix:24-26`, `ssh.nix`, `nix.nix` schreiben `flake.modules.nixos.impermanence`), greifen nur bei dessen Import — Live-Beweis ist der WSL-Host `dmi`, der `core` ohne `system` produktiv fährt. Der echte Vertrag (`impermanence` ⇒ disko-Layout, `system` ⇒ Hardware-Host) gehört als Kompositionsmatrix ins README; Fehler beim ersten Boot sind selbst-erklärend. Eine Assertion-Schicht ist Over-Engineering.
Bezug: oracle-core-system M1-Widerlegung + HQ3, core-system.md M1 (korrigiert).

**A6. Gruppen↔Tier-Baum per Massenverschiebung angleichen ("Struktur-Big-Bang").**
Dass Tiers quer zu Themen-Gruppen schneiden, ist dendritisch Normalzustand, kein Defekt (Gruppen sind "for humans only" Themenregale; Tier-Dateien sind Kompositionslayer). Vollständige Angleichung ist unerreichbar — `fish` bleibt thematisch eine Login-Shell unter `term/shell`, egal welches Tier es importiert (verifiziert: `core.nix` importiert fish/git/llm-agents, `system.nix` performance, `desktop.nix` fonts, `development.nix` nix-ld). Der einzige echte Defekt ist die **Namensgleichheit** Gruppe `core/` ↔ Tier `core` — ein README-Absatz, kein Datei-Umzug. Punktuelle Moves (fonts→desktop/, performance→system/, git-Familie→core/) sind als Einzelmaßnahmen vertretbar und billig (`git mv`, import-tree-stabil), aber: null Verhaltensänderung, null Performance — nicht als Modernisierung verkaufen und nicht als Riesen-Diff fahren.
Bezug: oracle-dendritic Medium-2-Korrektur + HQ1, core-system.md M5, oracle-development #5, development.md M3.

**A7. Impermanence-Collector in 22+ nach Collector benannte Beitragsdateien rekonstruieren.**
Inline-Fragmente (je 1–3 Zeilen) gehören inhaltlich zur App ("fish persistiert `.local/share/fish`") — "data next to its consumer". Entfernbarkeits-Kriterium (App löschen = Persistenzspuren weg) ist mit Inline **besser** erfüllt als mit Zusatzdateien; die Audit-Richtungssuche ist ein grep-Einzeiler. Für kollisionsgefährdete Contributions existiert bereits die Bestform: `dotnix.tmux.bindings`/`popups` mit Duplikat-Key-Validierung (`tmux-bindings.nix:87-95`) und das `helix-lsp/`-Verzeichnis-Muster.
Bezug: oracle-dendritic Medium-1 + HQ2, dendritic.md Medium 1.

**A8. tmux-Modularchitektur umbauen / `dotnix`-Namespace umbenennen.**
Die 6 Dateien, die `homeManager.tmux` schreiben, mergen als EIN Modul (attrsOf deferredModule) — ein Standalone-Crash von `sesh` ist konstruktiv unmöglich, weil `sesh.nix:65` unter dem Key `tmux`, nicht `sesh` schreibt (adversarial bewiesen). Der dreifach belegte `dotnix`-Namespace kollidiert nie im selben Auswertungskontext — ein README-Satz klärt das, ein Umbau bricht alle Consumer.
Bezug: oracle-term M4-Widerlegung, dendritic.md Low 1.

### B. Bibliotheksschnittstelle & Wiring

**B1. `parts/` pauschal aus dem `flake.flakeModule`-Export entfernen.**
`parts/` ist nicht rein Dev-Tooling: `parts/flake-parts.nix` ist die **einzige** Quelle der `flake.modules`-Option (ohne sie tot: alle 132 Aspek-Registrierungen), `parts/configuration.nix` ist die Factory, `parts/age.nix` trägt die rekey-App, auf der das Template-Justfile baut. Der richtige Split verläuft entlang **Produkt/Dev**: drin bleiben aspects + `{flake-parts (ohne debug-Zeile), configuration, age}`; raus als Opt-in: devshell, treefmt, pre-commit, templates + `debug = mkDefault true` (verifiziert `expose.nix:16-23` exportiert beide Pfade; `parts/flake-parts.nix:5`).
Bezug: oracle-wiring Verschärfung 2, wiring.md HIGH-1, oracle-dead-dupes HQ3, oracle-dendritic #2.

**B2. `core` in die Factory re-injizieren (weil das README es behauptet).**
Commit `880c2b1` (2026-04-20, "feat: remove nixos.core from default") hat die Injektion **bewusst** entfernt — konsistent mit "Aspekt-Wahl liegt beim Host" und dem Live-Betrieb (`.dotnix` listet `core` explizit). Re-Injektion wäre der eigentliche Breaking Change: Hosts, die bewusst kein core wollen, könnten es nicht mehr loswerden. Falsch sind Doku und Template — nicht der Code. Verifiziert: Factory injiziert nur stateVersion/hostname/zfs-Default/dotnix-Metadaten.
Bezug: oracle-wiring Verschärfung 1 + HQ2, dead-dupes.md HIGH-2.

**B3. Export-Split und `debug=false` als Trägheits-Heiler buchen.**
Beides ist richtig, aber es macht `flake show`/`flake check`/repl/direnv im Konsumenten schneller — die Desktop-Runtime bleibt exakt gleich (siehe Abschnitt 3). Wer den Umbau mit "danach ist der Desktop flink" begründet, enttäuscht sich selbst.

### C. Lock & Inputs

**C1. `nix flake update` als Lock-Diät / "Stale-Repos aufräumen".**
Die 9 "alten" Nodes (devshell 2024-10, treefmt-nix 2024-12, flake-parts 2024-12, pre-commit-hooks 2025-01, systems 2023, …) sind **eingefrorene Upstream-Lock-Pins** von agenix-rekey/stylix/NUR — byte-identisch mit deren flake.locks verifiziert; 24 wöchentliche Update-Wellen haben sie nie bewegt, und `nix flake update` kann sie prinzipiell nicht bewegen (nur follows-Overrides). Der Stale-Eindruck ist falsch interpretierte Lock-Semantik. Achtung Detail: Der Helix-Node ist ein **anderer** Fall — dort ist der Freeze ein Pipeline-Defekt (siehe C4).
Bezug: lock-hygiene.md LOW + W2, oracle-lock-hygiene W2.

**C2. Alle Transitiv-Pins blind per follows kollabieren (58 → ~30 Nodes "Schönheitskur").**
Gleiche narHash → gleicher Store-Pfad; Lock-Nodezahl ist Metadaten, Eval-Kosten 0, der wöchentliche Review-Diff enthält gefrorene Nodes nie. Dagegen steht ein reales Risiko: stylix/NUR/agenix-rekey evaluieren gegen ihre gefrorenen flake-parts-Versionen — 24 Wochen grüne CI sind die Beweislast für den Status quo. Die Orakel sind sich hier uneinig (wiring-Orakel: alle drei follows setzen; lock-Orakel: Bibliotheks-Pins respektieren, nur die agenix-rekey-**Dev-Kette** — devshell/treefmt-nix/pre-commit-hooks, nie im Modul-Pfad — ist risikoarm). Querschnitts-Urteil: Dev-Kette konsolidieren ja; `agenix-rekey.inputs.flake-parts` nur mit anschließendem rekey-Dry-Run + `nix flake check`, nie im Selbstlauf; stylix/NUR gar nicht anfassen. Keine Änderung ohne Funktionstest, keine aus Ästhetik.
Bezug: lock-hygiene.md [high]/[medium], oracle-lock-hygiene HQ1 + Empfehlung 8, oracle-wiring HQ3/Empfehlung 6.

**C3. Unstable auf stable wechseln — ganz oder selektiv für den DMS-Stack.**
Unstable + volle nixpkgs-Follows (eine nixpkgs-Instanz im Eval — verifiziert alle 17 Kanten auf Root) ist das Architekturgut; `home-manager@unstable + nixpkgs@unstable` ist das empfohlene Pairing. Selektives Pinning des AvengeMedia-Stacks auf nixos-release bricht die Follow-Kopplung und erzeugt **zwei nixpkgs-Welten auf einem Desktop** — genau das, was die Architektur vermeidet. Der reale Schmerz (wöchentliche lokale Source-Builds von dms/greeter/plugins, da kein AvengeMedia-Cache existiert) wird über Kadenz (2 Wochen, Cron `0 4 1,15 * *`) und Pipeline-Reparatur gelöst, nicht über einen Kanalwechsel.
Bezug: lock-hygiene.md [medium], oracle-lock-hygiene HQ3, eval-perf.md HIGH (DMS-Rebuild-Pfad).

**C4. Eigenen Cachix für den AvengeMedia-Stack bauen / "Substituter für DMS konfigurieren" — und: Helix-Input behalten + Bump-Disziplin schwören.**
Ersteres ist nicht umsetzbar bzw. unwirtschaftlich: Es existiert schlicht kein öffentlicher AvengeMedia-Cache (DMS-flake ohne nixConfig — verifiziert); ein eigener Cachix für 1 Workstation + 1 Desktop-Stack kostet mehr Betriebsaufwand als die halbierte Kadenz bringt. Letzteres ist widerlegt als Strategie: Der wöchentliche Bot hat den helix-Node seit 9 Wellen nachweislich nicht mehr bewegt (Lock steht auf 2026-07-23, obwohl Upstream täglich aktiv) — "Bump-Rhythmus etablieren" ohne Bot-Diagnose ist ein Schwur auf eine Automatik, die nicht lieffert. Ebenso Anti: die 16 ungepinnten helix-`extraPackages` version-pinnen wollen — das ist Channel-Semantik, kein Befund.
Bezug: oracle-lock-hygiene W4/N1 + HQ3, oracle-development HQ1/#1, development.md HIGH.

### D. Desktop, Runtime, Konvention

**D1. Stylix komplett wegwerfen (oder ein drittes Theming-System einführen).**
Stylix ist eval-seitig entlastet (≤0,3 s gemessen; `enableReleaseChecks = false` gesetzt; Theme-Derivations build-seitig gecached) und themed GTK/Firefox-Targets, die DMS-matugen nicht abdeckt. Der echte Befund ist eine **SSOT-Entscheidung** zwischen DMS-matugen (Wallpaper-Palette, Shell + ~20 Template-Ziele) und Stylix (fixe catppuccin-mocha, GTK/Qt/Firefox) plus Löschung des nachweislich wirkungslosen `qt-theme.nix` (mkDefault 1000 verliert gegen Stylix-Plain 100). Stylix ohne Ersatz zu streichen, macht den Look schlimmer, nicht die Maschine schneller.
Bezug: eval-perf.md MEDIUM (Messung), desktop.md H3, oracle-desktop HQ2/Widerlegtes 8.

**D2. `dms-settings.nix` "managen" statt kürzen (configVersion hochziehen, mkDefault-Flut, Voll-Pinning dokumentieren).**
Die Datei ist ein v5-Schema-Snapshot: 376 Keys, davon ~180 im aktuellen DMS-Schema (configVersion 33) **nicht mehr existent**, DMS migriert bei jedem Start die komplette Kette und HM schreibt bei jedem Switch den Alt-Stand zurück (Doppel-Writer, verifiziert `dms-settings.nix:454` = `configVersion = 5`). "Managen" dieses Zustands ist Pflege eines toten Spiegels. Richtig: auf die ~24 echten Abweichungen reduzieren (~40 LOC), `configVersion` **nicht** pinnen (DMS verwaltet ihn selbst). Konservativ falsch ist auch der lokale `lib.mkForce`-niri-Block (`dms.nix:41-64`): Upstream generiert beim gepinnten Rev denselben Output inkl. Border-Fix nativ — Block löschen, nicht "beim nächsten Bump mittesten". Klarstellung eines Orakel-Widerspruchs: `dms-settings` ist über den Collector-Namen `homeManager.dms` (`dms-settings.nix:2` = `dms.nix:20`) **immer live**, sobald Aspekt `dms` importiert wird — die Datei ist kein optionaler Ballast.
Bezug: desktop.md H1, oracle-desktop H1/HQ3 + Widerlegtes 2/6, dead-dupes.md M4, runtime-perf.md (Einschränkung korrigiert).

**D3. polkit-gnome nachrüsten.**
DMS bringt einen eigenen Polkit-Agenten mit und lädt ihn per Default (PolkitService.qml, abschaltbar nur via `DMS_DISABLE_POLKIT=1`); der Kommentar in `niri.nix:15-16` (verifiziert: "use polkit-gnome instead") ist veralteter Wortlaut eines verlorenen Refaktor-Satzes. Zu tun ist der Kommentar, nicht ein Modul.
Bezug: runtime-perf.md Widerlegung 3/HQ1, desktop.md, runtime-perf.md Finding 3.

**D4. Firewall-Ports (5353/mDNS) ohne Laufzeit-Beweis öffnen.**
Aktive mDNS-Queries laufen über conntrack als ESTABLISHED durch die Stateful-Firewall; blockiert sind nur unsolicited Announcements — und `publish.enable = false` ist ohnehin bewusste Posture (`network.nix:70-72` mit Begründung). Erst am Ziel-Laptop `avahi-resolve` + nft-Counter messen; nur bei nachweislich defekter Auflösung `services.avahi.openFirewall` setzen.
Bezug: core-system.md M4, oracle-core-system M4-Widerlegung + Empfehlung 6.

**D5. An der gutgestellten Fläche weitergraben: Sysctl/zram/GC/Timer/Blur/Wetter.**
Zram 25 %/zstd/prio 100, Swapfile nur für Hibernate, swappiness 10, Nix-Daemon auf idle, auto-optimise-store aus (begründet), weekly fstrim/nh-clean, kein locate-/autoUpgrade-Timer, DMS-Blur global aus, Ripple klickgetrieben, Wetter mit IP-Fallback + exponentiellem Backoff unter nice/ionice — die klassischen Verdachtsstellen sind adversarial entlastet. Dort Umbauarbeit zu investieren ist verlorene Zeit; einzig offen ist thermald (nixos-hardware-Modul könnte es bringen — erst `systemctl status thermald` + stress-ng-Messung, dann die 1-Zeile).
Bezug: runtime-perf.md Urteil + Finding 9/10, core-system.md Positiv-Bestand, oracle-runtime-perf Urteil/"Nicht tun".

**D6. `resume_offset` in die Bibliothek hardcoden oder disko-Maschinerie dafür bauen.**
Der Offset ist maschinenabhängig (filefrag-Wert der Swapfile) — er gehört **host-seitig** als `boot.kernelParams` in den Consumer, nicht in die Library (verifiziert: 0 `resume_offset`-Funde repo-weit; `power.nix:29` setzt nur `resumeDevice`). In die Bibliothek gehört ein Warn-Kommentar (Btrfs-Swapfile braucht den Offset, sonst kein Resume nach Hibernate — stiller Session-Verlust). Automatisches Offset-Berechnen in disko wäre IFD-Risiko für einen Wert, der pro Maschine konstant ist.
Bezug: core-system.md H1, oracle-core-system H1 + HQ1.

**D7. Tote Alternativ-Aspekte "lebendig machen" (Tier-Varianten für boot-limine/tui-greeter bauen).**
`boot-limine`, `tui-greeter`, `yubikey-lock` sind von keinem Tier erreicht (Referenz-Scan negativ, Existenz verifiziert). In einer Bibliothek sind nicht importierte Aspekte Exporte, kein toter Code — aber für Alternativen, die nie gewählt wurden, Inheritance-Tier-Varianten (`system-core` ohne Boot-Entscheidung) zu bauen, ist spekulative Flexibilität. Entscheide: löschen (3 Dateien, Löschkandidaten laut Referenzgraph) oder als "wählbare Exporte" in einer README-Zeile listen. Kein Gating-/Varianten-Framework.
Bezug: dead-dupes.md HIGH-1, oracle-dead-dupes Empfehlung 3, dendritic.md Medium 5, oracle-dendritic Medium 5.

---

## Bewusst lassen

**L1. Granularität und Datei-für-Datei-Struktur der Aspekte.** Ein Tool = eine Datei = ein Aspekt; einzeln komponierbar, über Tiers en bloc gezogen. Das ist der Kernwert des Patterns und adversarial bestätigt — nicht antasten. (oracle-dendritic Granularitäts-Antwort)

**L2. Host-Registry + Factory (`parts/configuration.nix`).** Bewusste, funktionierende Erweiterung: kein Boilerplate pro Host, hostname-Injektion, iso-Suboption, members-getriebene Secrets. Der ISO-`buildOutput`-Default zeigt auf einen nicht existierenden Pfad (`images.iso-installer`, Repo-weit einzige Erwähnung) — das ist Dokumentationspflicht oder Streichung, kein Umbau der Factory. (oracle-dendritic Medium 4, dead-dupes.md M5)

**L3. Inline-Impermanence-Fragmente** (22 HM-/9 NixOS-Dateien) samt Audit-Einzeiler `grep -rn 'home.persistence' modules/` — Bestform für Entfernbarkeit; nur bei künftigen kollisionsgefährdeten Contributions das tmux-Options-Muster vorschreiben. (oracle-dendritic HQ2)

**L4. Die Options-Collector mit Duplikat-Validierung** (`dotnix.tmux.bindings/popups` mit Assertions gegen Key-Kollisionen) und das `helix-lsp/`-Verzeichnis (Collector-Name = Verzeichnis, Datei = Sprache) — das sind die hausinternen Bestformen; neue Contributions daran orientieren statt neue Muster erfinden. (term.md Konsistenz-Check, dendritic.md Medium 1)

**L5. Gruppen als Themenregale, Tiers als Kompositionslayer.** Der Querschnitt ist Normalzustand; die Namensgleichheit Gruppe/Tier `core` kostet einen README-Absatz. Bracket-Konvention (`[N]`-Marker) nur, wenn der Absatz nicht greift — optional, kein Muss. (oracle-dendritic HQ1)

**L6. Unstable als Basis + volle nixpkgs-Follows.** Eine nixpkgs-Instanz, home-manager-Pairing korrekt; der Preis (wöchentliche Rebuild-Welle, cache-loser AvengeMedia-Stack) ist ein Kadenz-/Pipeline-Thema, kein Architekturfehler. (lock-hygiene.md, oracle-lock-hygiene HQ3)

**L7. Gefrorene Transitiv-Pins von agenix-rekey/stylix/NUR.** Upstream-Lock-Pins, die im Modul-Pfad laufen und seit 24 Wellen grün sind; `systems` 2023 ist eine statische Systemliste. Sie dominieren nur den Stale-Eindruck, nicht Kosten. (lock-hygiene.md LOW, oracle-lock-hygiene W1/W2)

**L8. Nix-Runtime-Tuning (`core/nix.nix`) und Timer-Politik.** auto-optimise aus mit Begründung, weekly optimise, connect-timeout 5 s, fallback, Daemon auf idle, nh clean keep 3/7d, tealdeer-Timer aus + internes 720-h-Update — bewusst und richtig; einzige nachziehenswerte Einzelheit ist `narinfo-cache-negative-ttl` 30 s → Default 3600 (Misses werden sonst alle 30 s re-angefragt). (eval-perf.md LOW-positiv, development.md M, oracle-development #3)

**L9. btrfs-Rollback-Impermanence statt tmpfs.** Kein RAM-Druck aus der Persistenzstrategie — Hypothese config-seitig widerlegt; zram bewusst dimensioniert. (runtime-perf.md Finding 9)

**L10. niri-unstable über eigenen Cachix + xwayland-satellite-Anbindung, Mesa-Shader-Cache persistiert, hotkey-overlay-skip.** Compositor-seitig unauffällig; kein Animations-Override-Rollback nötig. (desktop.md L3, eval-perf.md MEDIUM) — Der niri-**Fork** (`github:epireyn/niri-flake`, flake.nix:52) ist dagegen kein "bewusst lassen", sondern eine 1-Zeilen-Entscheidung: Grund dokumentieren oder auf `sodiboo` zurückrollen (Fork ist synced). (oracle-lock-hygiene Empfehlung 6)

**L11. Konsumenten-seitiges Collector-Vorbild** (`.dotnix` devops: 4 Dateien registrieren `homeManager.devops`, 1 Modulname) — das Muster korrekt gelebt; nicht ins Template "vereinfachen". (dead-dupes.md LOW-4)

**L12. Defensive Idiome und Geschmacksfragen:** `LC_*`-Spiegelung über `i18n.extraLocaleSettings` (offizielle Option, verbreitetes Idiom), redundante nixpkgs-Default-Setzungen (fonts antialias/hinting, bluetooth powerOnBoot, network firewall.enable), `uutils-coreutils-noprefix` (bewusste Wahl mit Kommentar), zellij/dust/dua-Dopplungen, doppelte ZFS-Zeile (boot.nix:22 hart vs. configuration.nix:46 mkDefault — eine kann weg, Kosmetik). Alles null Verhaltensänderung — nur opportunistisch in Vorbeiflug-Commits mitnehmen, keine Aufräum-Kampagne. (oracle-dead-dupes "Nicht tun"-Zeile, core-system.md Low, dead-dupes.md LOW)

**L13. Uncommitted `M modules/aspects/term/shell-ux/sesh.nix`** — User-Arbeit, in allen 10 Berichten unangetastet belassen; auch künftige Refactor-PRs nicht draufreiten.

---

## Kein Effekt auf Trägheit (Erwartungs-Management)

**E1. Der Laptop-Konsument ist ungeklärt — das ist die Mutter aller Schein-Verdiener.** `.dotnix` enthält historisch genau einen Host (`dmi`, WSL2, `modules = [ core wsl development ]`) und keinen je gelöschten; sein Pin steht 8 Commits hinter HEAD (vor dem Aufräum-Commit `8b408a9`). Gleichzeitig belegen frische Desktop-Commits ("Configure for better performance", 2026-09-11) live-Iteration — der Desktop fährt mit hoher Wahrscheinlichkeit einen dritten, hier unsichtbaren Konsumenten mit unbekanntem Pin. **Solange die Flake-Quelle des Laptops nicht identifiziert ist, kann kein einziger Bibliotheks-Umbau — auch kein noch so guter — am gefahrenen System wirken.** Erste Aktion bleibt: Laptop-Konsument + Pin klären (dead-dupes-Orakel P1), dann das Live-Pin-Gap im WSL-Host schließen.

**E2. Struktur-Refractorings heben das Trägheitsgefühl nicht — sind aber trotzdem richtig.** Renames (Dateiname=Aspektname), Template-/README-Reparatur, CI-Consumer-Fixture, Export-Split, `debug=false`, tote Module löschen, Taxonomie-Doku: allemaal Wartbarkeitsgewinn mit Eval-Effekt null bis klein. Wer sie als "dann fühlt sich der Rechner schneller an" verkauft, setzt die Messlatte falsch — sie sind trotzdem Pflicht, weil sie das Verrottungs-Root-Cause (nie getesteter Export-Vertrag) schließen.

**E3. Lock-Hygiene hat null Perf-Wirkung.** 58→30 Nodes, flake-parts-Konsolidierung, follows-Sweeps: Lock ist Metadaten, identische Revs deduzieren im Store, gefrorene Nodes evaluieren nicht in Pfaden, die zählen. Der Rebuild-Schmerz kommt aus wöchentlichem unstable-Bump × cache-losem AvengeMedia-Stack — ein Kadenz- und CI-Problem, keine Lock-Struktur-Frage. (eval-perf.md LOW, oracle-lock-hygiene Urteil)

**E4. Dateizahl/Import-tree ist kein Faktor.** 0,15–0,5 s für 141 Module gemessen; auch stylix (≤0,3 s), DMS (+0,1 s), Desktop-Stack gesamt (+0,5–2 s, niri-flake +1,5 s) sind eval-seitig klein. Der einzige echte Eval-Block ist **disko: +7 s pro Host-Eval** — aber auch der verschwindet gegen die Laufzeit-Ursachen und ist ein Kompositions-Detail (Collector vs. Host), kein Datei-Zahl-Problem. (eval-perf.md HIGH/LOW)

**E5. dms-settings-Kürzung killt Churn, keine Trägheit.** Die 5→33-Migration bei jedem DMS-Start und der Doppel-Writer-Ping-Pong sind echtes Korrektheits-/Wartbarkeitsproblem und Startup-Millisekunden — kein spürbarer Perf-Gewinn. (oracle-desktop Ursache 5)

**E6. Die wahren Hebel (zur Erwartungs-Kalibrierung).** Config-seitig benannt und teils verifiziert: Ghostty `custom-shader-animation = true` + `background-blur = 20` (verifiziert `ghostty.nix:16-22`, permanente GPU-Arbeit pro sichtbarem Terminal), `batteryProfileName = "power-saver"` (verifiziert `dms-settings.nix:209`, CPU-Throttle auf Akku — bewusste Entscheidung, dokumentieren oder auf `"balanced"`), dsearch-Dauerindexer mit File-Watcher (`dms.nix:12`), fastfetch in jedem tmux-Pane (verifiziert `fastfetch.nix:23-26`, kein TMUX-Guard), docker-`linger` auf dem Desktop-Host, mbsync alle 15 Min + preNew-Vollsync, doppelte LSP-Server pro Buffer (nixd+nil, marksman+markdown-oxide+typos). Größenordnung realistisch: Sekundenbruchteile pro Interaktion plus Akku-Verhalten — das behebt das Symptom, verwandelt aber keine Maschine. Ohne E1 bleibt selbst das Theorie.

**E7. Eine echte Funktionslücke, die nichts mit Trägheit zu tun hat, aber teuer ist:** die unvollständige Hibernate-Kette (`resume_offset` fehlt bei Btrfs-Swapfile, `suspend-then-hibernate` überall aktiv) — stiller Session-Verlust beim ersten Deckel-Hibernate am Ziel-Laptop. Host-seitig fixen (D6), nicht als Trägheits-Hebel missverstehen.

---

## Sequenz-Hinweis (nur zur Kante des Gutachtens)

1. Laptop-Konsument + Pin klären (E1) — alles andere rangiert danach.
2. Die P1-Liste der Orakel ist kohärent und klein: CI-Consumer-Fixture, Template/README-Fix, `debug=false`, Ghostty-Shader + Akku-Profil klären, fastfetch-Guard, Helix-Input-Anomalie. Kein Punkt davon erfordert einen der oben verbotenen Umbauten.
3. Erst danach: Export-Split (Produkt/Dev), dms-settings-Kürzung, Taxonomie-Punktmaßnahmen, Lock-Dev-Kette.

*Kein nix-Kommando ausgeführt, keine Datei des Repos geändert; alle zitierten `path:line`-Angaben am Arbeitsbaum `ac7724c` (+ uncommitted sesh.nix unangetastet) selbst verifiziert.*
