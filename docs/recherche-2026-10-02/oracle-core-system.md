# Orakel-Gutachten: Aspekte core + system (Qualität)

Repo: `/home/denis/repositories/private/.dotnix-aspects` (Branch `refactor/public-release`).
Adversarial geprüft gegen: `modules/aspects/core/*` (20 Dateien), `modules/aspects/system/*` (11 Dateien), Aggregatoren `modules/aspects/*.nix`, `modules/parts/*`, sowie den **realen Consumer** `/home/denis/repositories/private/.dotnix` (entscheidende Zusatz-Evidenz, u. a. Host `dmi` = WSL2).

## Urteil

Die Aspekte core+system sind qualitativ **hochwertig** — besser als der Forscherbericht nahelegt. Von 1 High- und 5 Medium-Findings halten: **H1** (Hibernation, mit korrigierter Folge-Analyse), **M3** (Options-Hygiene) und **M5** (Taxonomie) stand; **M1** und **M4** sind in ihrer Kernaussage **widerlegt**; **M2** hält als Faktenlage, ist aber in der Sicherheits-Bewertung zu rekalibrieren (echtes Rest-Risiko liegt auf dem WSL-Host, nicht in der Komposition). Die Desktop-Trägheit hat ihre Ursache nachweislich **nicht** in core/system: der einzige reale Host (`dmi`) importiert `system` gar nicht; alle performance-relevanten Regler (nix-daemon `idle`, resolved-Cache, zram, `noatime`+`compress=zstd`, WiFi-Powersave aus) sind gesetzt und begründet. Die wichtigste reale Lücke ist die Hibernation-Resume-Kette — ein stiller Datenverlust-/Session-Verlust-Szenario am Ziel-Laptop.

**Zentrale Zusatz-Evidenz, die der Forscher nicht hatte:** Der einzige produktive Host ist `dmi` mit `modules = [ core wsl development ]` (`/home/denis/repositories/private/.dotnix/modules/hosts/dmi/configuration.nix:3`) — ein WSL2-System **ohne** `system`-Aspekt, ohne btrfs, ohne impermanence. Der `system`-Aspekt ist damit aktuell **nur im Template** (`templates/dotnix/.../configuration.nix:6`, Ziel `dell-precision-5570`) deployt. Alle Hardware-/Impermanence-Findings sind reale Bibliotheks-Bugs für das angedachte Zielgerät, aber heute dormant.

## Widerlegtes

### M1 — „core ist nicht standalone-fähig, bricht ohne /persist": WIDERLEGT (Mechanismus falsch gelesen)

Forscher-Behauptung: Host, der `core` ohne `system` importiert, bekommt `age.identityPaths = ["/persist/..."]` und Boot-/Eval-Failure.

Widerlegung:
- **Alle /persist-Zuweisungen stehen unter dem Modul-Namen `impermanence`, nicht unter `age`/`ssh`/`nix`.** `core/age.nix:24-26` schreibt `flake.modules.nixos.impermanence = { age.identityPaths = ...; }` — ebenso `core/ssh.nix:37-44` (nixos) und `:46-48` (homeManager), `core/nix.nix:52-57`. Wer das Modul `impermanence` nicht importiert, bekommt **keines** dieser Fragmente — weder Eval-Fehler noch Boot-Failure. Ohne impermanence-Modul greift der agenix-Default (`/etc/ssh/ssh_host_ed25519_key`).
- **Live-Beweis:** Host `dmi` (WSL2) importiert `core` ohne impermanence/system und läuft produktiv. Das Consumer-eigene `hardware.nix:28` pinnt `age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]` — das ist exakt der agenix-Default, also redundant, aber harmlos (defensives Pinning; `hardware.nix:27` schaltet sshd ab, da Windows Port 22 hält).
- Design-Fazit: Die Kopplung ist **absichtsgemäß dendritisch entkoppelt** — /persist-Wissen konzentriert sich vollständig im `impermanence`-Modulnamen (inkl. `age.identityPaths`, konsistent zu den persistierten Host-Keys aus `ssh.nix:37-44`). Genau das, was M1 als Fix fordert, ist architektonisch schon vorhanden.

Was bleibt (legitim, aber LOW): Der Kompositions-Vertrag „`impermanence` ⇒ disko-Layout" ist nirgends dokumentiert; `age-rekey.nix:9` liest `modules/hosts/<hostname>/secrets/ssh_host_ed25519_key.pub` unguarded via `lib.readFile`, während `certificates.nix:6` einen `pathExists`-Guard hat (inkonsistent).

### M4 — „Firewall blockt mDNS, .local-Timeouts fühlen sich träge an": WIDERLEGT (Wirkungsbehauptung), Code-Fakten korrekt

Code-Fakten bestätigt: `system/network.nix:23,28` (nftables + firewall an), `network.nix:67-73` (avahi + `nssmdns4`, `publish.enable = false` mit Begründung `:70-72`), repo-weit **kein** `allowedUDPPorts`/`5353`/`openFirewall` (verifiziert per grep über beide Repos; einzige Port-Freigabe ist `core/ssh.nix:12`).

Die Wirkungsbehauptung hält nicht:
- **Aktive** mDNS-Auflösung (avahi-resolve, `getent hosts foo.local`, Printer-Dialoge mit On-demand-Queries) läuft durch eine Stateful Firewall: Die ausgehende Query erzeugt einen conntrack-Eintrag, Antworten werden als `ESTABLISHED` klassifiziert — derselbe Mechanismus, auf dem DHCP durch die NixOS-Default-Firewall beruht (Hypothese + allgemeines Wissen; im Sandbox-Jail nicht live verifizierbar).
- Blockiert sind nur **unsolicited** Announcements (passives Browsing in Network-Nachbarschafts-UIs) und das **Entdeckt-Werden** — letzteres ist hier bewusst aus (`publish.enable = false`).
- Runtime-Nachweis war im Jail unmöglich (kein systemd/Netz-Zugriff). Gemäß Auftrag (Default bei Unsicherheit: widerlegt) → widerlegt. **Keine Firewall-Änderung ohne Laufzeit-Beweis** (siehe Empfehlungen).

### M2 — „Faktor-loses sudo für Unregistrierte": FAKTEN HALTEN, BEWERTUNG REKALIBRIERT (nicht widerlegt, aber schärfer neu gefasst)

Fakten verifiziert: `core/security.nix:3-8` (`sudo.enable = mkForce false`, sudo-rs, `execWheelOnly = true`, `wheelNeedsPassword = false`), `core/yubikey.nix:21` (`nouserok = true`), `yubikey.nix:25` (sudo-U2F), `yubikey.nix:9-11` (Authfile-Generator druckt nur den pamu2fcfg-Kommentar — bis zur manuellen Registrierung ist U2F ein No-op).

Rekalibrierung:
- Der Kompositions-Risiko-Rahmen („core ohne yubikey-pam ergäbe faktor-loses sudo") ist **praktisch gegenstandslos**: `core.nix:15` und `:22` importieren `security` und `yubikey-pam` **immer gepaart**.
- Die **echte** Lücke (neu, schärfer): Auf dem realen Host `dmi` (WSL2) gibt es **keinen USB-Passthrough** (kein usbipd in `hardware.nix`) — pam_u2f kann den Yubikey dort nicht sehen, `nouserok = true` lässt die Prüfung durch → **de facto faktor-loses, passwort-loses sudo auf der Produktiv-Maschine**. Für Ein-Personen-WSL vertretbar, aber es ist aktuell eine *unbewusste* Konsequenz, keine dokumentierte Entscheidung.
- sudo-rs + pam_u2f: aus Quellcode nicht verifizierbar; sudo-rs nutzt den Standard-PAM-Konversationsablauf (allgemeines Wissen) — plausibel funktionierend, einmalig manuell testen statt blind vertrauen.

## Bestätigt (geprüft und gehalten)

### H1 — Hibernation-Kette unvollständig (`resume_offset` fehlt): HÄLT, Folge-Analyse korrigiert

Beleg verifiziert: `system/power.nix:29` setzt `boot.resumeDevice = "/dev/mapper/cryptroot"` — das ist `resume=`; `resume_offset` existiert in **keinem** der beiden Repos (grep über `.dotnix-aspects` + `.dotnix`: nur `power.nix:29` und der Kommentar `performance.nix:23-24`). Swap ist ein **Btrfs-Swapfile** (`system/disko.nix:50-54`, Subvol `@swap`, `/swap`, 64G). Alle Power-Trigger stehen auf `suspend-then-hibernate` (`power.nix:4-6`), `HibernateDelaySec = "30min"` (`:26`), `criticalPowerAction = "Hibernate"` (`:15`).

**Korrigierte Folge-Analyse** (weicht vom Forscher ab): Der Hibernate-**Schrieb** funktioniert — der Kernel überspringt zram-Devices bei der Image-Device-Auswahl (allgemeines Wissen; die Kombination zram prio 100 (`performance.nix:25-30`) + Swapfile prio −2 ist exakt die dokumentierte funktionierende Konstellation), das Image landet im Swapfile. Was bricht, ist der **Resume**: Ohne `resume_offset` sucht der Kernel die swsusp-Signatur auf Block 0 des resume-Devices — dort liegt der Btrfs-Superblock. Resultat: Rechner fährt nach dem Hibernate sauber aus (Akku geschont), beim nächsten Boot **kein Resume, frische Session** — der stillste Datenverlust-Kettenbruch, den man konstruieren kann. `canhibernate` warnt nicht (resume-Device ist ja gesetzt). Der Forscher-Primärfall („bleibt suspendiert, Akku läuft leer") ist die **unwahrscheinlichere** Variante.

Einordnung: heute dormant (realer Host = WSL), aber `templates/dotnix/.../configuration.nix:6` deployt `system` auf ein echtes Laptop-Ziel → der **erste** Deckel-zu-Hibernate nach 30 min kostet die Session. Prio 1.

### M3 — Options-Hygiene: HÄLT

- `core/users-profile.nix:3-8`: vier Optionen mit expliziten Typen, **null** descriptions (verifiziert). Die Asymmetrie zu term ist real: `term/shell-ux/tmux-bindings.nix:43-56` und `tmux-popups.nix:28-38` haben descriptions. Für eine als „reusable library" beworbene Sammlung (README.md:3) ist die Options-Doku die API-Doku.
- `modules/parts/configuration.nix:33`: `hostname = mkOption { type = str; default = null; }` — Typverletzung im Default, **latent** (configuration.nix:44 setzt `hostname` immer explizit; der Default wird nie evaluiert). Trotzdem fixen: `types.nullOr str` oder Default streichen.
- `theme`-Option tot: `users-profile.nix:7` deklariert/consumiert nichts; stattdessen hardcodiert `core/stylix.nix:8` (`base16Scheme = .../catppuccin-mocha.yaml`) und `development/ai/tuicr.nix:13` (`theme = "catppuccin-mocha"`) — der Theme-Name lebt an **drei** Stellen, davon zwei unkoordiniert. Konsumieren oder streichen.
- `parts/configuration.nix:7,16-19` (iso/host-Submodule): ebenfalls ohne descriptions.

### M5 — Kategorien-Taxonomie brüchig: HÄLT, und war noch unvollständig

Verifiziert:
- `core/fonts.nix` → konsumiert von `desktop.nix:6`; `core/nix-ld.nix` → `development.nix:11`.
- `core.nix:7-10` importiert `fish` (`term/shell/fish.nix:6`), `git` (`development/vcs/git.nix:37`), `llm-agents` (`development/ai/llm-agents.nix:2` — ein nixpkgs-Overlay + Cache-Setting) in den „core"-Aggregator.
- **Neu (vom Forscher übersehen):** `core/performance.nix` liegt in `core/`, wird aber von `system.nix:12` aggregiert — ein weiteres Verzeichnis≠Consumer-Auseinanderfallen.
- `bootstrap.nix:3-13` (fish, git, gnupg, locale, network, network-wifi, nh, nix, yubikey) ist eine Teilmenge quer durch core+system+term/development — drei überlappende Aggregator mit Drift-Risiko bestätigt.

Bewertung: Das ist genau die Wartbarkeits-Schmerzstelle des Besitzers. Die Kategorie-Ordner sind die Navigationsebene des Dendritic-Musters; wenn Ordner und Aggregator auseinanderfallen, ist „Trennung core vs. system" nur noch nominell. Kein Funktionsrisiko, aber direkter Treffer auf das Ziel „Struktur + Wartbarkeit".

### Low-Findings (Stichproben verifiziert, alle zutreffend, keine Handlungspflicht außer Punktuell)

- **L1** `core/locale.nix:23-24`: timesyncd im locale-Aspekt — zwei Concerns, bestätigt.
- **L2** `system/boot.nix:19` `tmp.cleanOnBoot = true` redundant zum `@root`-Blank-Snapshot-Rollback (`system/impermanence.nix:6-26`) — bestätigt, toter Hebel, harmlos.
- **L3** ZFS-Flags doppelt: `boot.nix:21-22` + `parts/configuration.nix:46` — bestätigt, Duplikat.
- **L4** = siehe M3 (theme).
- **L5** README-Drift bestätigt: README.md:21 + :46 referenzieren `modules/options.nix` und `factories.nix` — beide existieren nicht; real ist `modules/parts/configuration.nix`. Für die Public-Release-Ambition (Branch `refactor/public-release`) ein echtes Onboarding-Defizit.
- **L6** `security.nix:3` und `boot-limine.nix:10`: `mkForce` ohne Warum-Kommentar (im Kontrast zu `network.nix:18-20`) — bestätigt; bei `security.sudo` besonders erwähnenswert, weil hier die Sicherheits-Posture entschieden wird.
- **L7** `core/ssh.nix:4` sshd default-an für jeden core-Host — bestätigt; der WSL-Host musste selbst kontern (`hardware.nix:27` + Kommentar). Ein Bibliotheks-Kommentar wäre billig. `ssh.nix:14` openssh-Client-Doppelpaket: kosmetisch.
- **L8** `core/system-packages.nix:5` `uutils-coreutils-noprefix` — bestätigt; bewusste Wahl, GNU-Kompatibilität als bekanntes Rest-Risiko (Kommentar `:4` zeigt Bewusstsein).

### Positive Verifikation (Forscher-Zitate stichprobenartig nachgeprüft)

- Impermanence-Input = `7b1d382faf603b6d264f58627330f9faa5cba149` (flake.lock) — deckt sich mit dem Forscher-Zitat zur HM-Injektion.
- `homeManager.system.imports = [ impermanence ]` (`system.nix:17-19`) ist **nicht** kaputt: `flake.modules.homeManager.impermanence` existiert (`core/ssh.nix:46` u. a. 20+ Dateien).
- `boot.initrd.systemd.enable = true` (`system/boot.nix:4`) — die rollback-root-Unit (`impermanence.nix:6-26`) läuft also tatsächlich; ein von mir vermutetes „Rollback läuft nie"-Szenario ist widerlegt.
- `kernelParams`-Doppel-Zuweisungen über `boot.nix:11-16`, `power.nix:30`, `network-wifi.nix:15-19` sind kein Konflikt: NixOS merged `listOf str` per Konkatenation — resume_offset wäre also eine Ein-Zeilen-Erweiterung in `power.nix`.

## Antworten auf HardQuestions

### HQ1: Wurde je ein Resume aus Disk-Hibernate getestet?

**Nein — und er kann nicht getestet worden sein.** Es existiert kein Hardware-Host im Consumer-Repo (nur `dmi`/WSL; Template `dell-precision-5570` noch ohne Realisierung). Die Kette ist nachweislich unvollständig (`resume_offset` fehlt systemweit, Beleg s. o. H1). Prognostizierter Ablauf beim ersten echten Test: Suspend OK → nach 30 min Hibernate OK (Image im Swapfile, zram wird übersprungen) → Poweroff → nächster Boot ohne Resume, **frische Session**. Das ist der wahrscheinlichste Ausgang, nicht „bleibt suspendiert". Der Fix gehört **host-seitig** (Consumer-Repo), weil der filefrag-Offset maschinenabhängig ist: pro Host `boot.kernelParams = [ "resume_offset=<filefrag -v /swap/swapfile>" ]`; in `power.nix` gehört ein Warn-Kommentar, dass `resumeDevice` ohne Offset bei Btrfs-Swapfile kein Resume liefert. Test-Abfolge: (1) `cat /sys/power/resume_offset` (sollte 0 sein → defekt), (2) nach Fix hibernate + Kaltstart, (3) Session-Prüfung. Aufwand gesamt 1-2 h inkl. Test.

### HQ2: Ist der Sudo-Posture bewusst — und läuft pam_u2f unter sudo-rs?

**Als Design annähernd bewusst, als Dokumentation nein.** Die Komposition ist im Aggregator gepinnt (`core.nix:15,22`: security + yubikey-pam immer zusammen) — der Forscher-Szenario-Bruch „core ohne yubikey-pam" ist konstruiert. Aber: (a) `security.nix:3-8` trägt null Begründung für `wheelNeedsPassword = false` + `mkForce` (L6), (b) bis der Besitzer `pamu2fcfg` manuell laufen lässt, ist die Authfile leer und U2F ein No-op (`yubikey.nix:9-11`), (c) **auf dem realen Host (WSL) ist der Zweitfaktor ohnehin wirkungslos** — kein USB-Passthrough konfiguriert, `nouserok` lässt alles durch. Effektiv gilt heute: passwort- und faktor-loses sudo auf `dmi`. Für einen Ein-Personen-Arbeitslaptop eine vertretbare, aber **unbewusst dokumentierte** Entscheidung. Empfehlung: 3-Zeilen-Kommentar in `security.nix`, der die Posture benennt („ein einzelner vertrauenswürdiger User; Faktor optional, bewusst nicht erzwungen via nouserok"), plus einmaliger manueller sudo-rs+pam_u2f-Test auf dem Ziel-Laptop. Wer die Posture verschärfen will: `wheelNeedsPassword = true` für Nicht-WSL-Hosts (der Faktor bleibt trotzdem Touch-only, `disko.nix:9` zeigt dieselbe Philosophie bei LUKS-FIDO2).

### HQ3: Soll `core` standalone-fähig sein — Dokumentierte Regel oder Constraint?

**`core` IST bereits standalone-fähig — der Forscher hat das Muster falsch gelesen** (s. M1-Widerlegung; Live-Beweis `dmi`). Die /persist-Fragmente liegen sauber im `impermanence`-Modulnamen und greifen nur bei dessen Import; agenix fällt auf seinen Default zurück. Der echte, undokumentierte Vertrag lautet: **`impermanence` ⇒ `disko`-Layout** (braucht `@persist`-Subvol, sonst bricht `rollback-root`/Bind-Mounts beim Boot mit klarem Fehler) und **`system` ⇒ Hardware-Host**. Empfehlung: keine Assertion bauen (Fehler beim ersten Boot ist selbst-erklärend; eine Assertion wäre Over-Engineering), stattdessen den Vertrag als kurze Kompositions-Matrix in README festhalten (core = überall; system = Hardware; impermanence ⇒ disko; bootstrap =Installer-Minimalmenge) — plus Header-Kommentar in `system/impermanence.nix`. Nebenbefund: `age-rekey.nix:9` unguarded `lib.readFile` vs. `certificates.nix:6` pathExists-Guard —Guard vereinheitlichen, dann ist das Bibliotheks-Verhalten auch ohne Doku robust.

## Empfehlungen (Aktion | Impact | Aufwand | Prio)

| # | Aktion | Impact | Aufwand | Prio |
|---|---|---|---|---|
| 1 | **Hibernation-Resume fixen**: Consumer-seitig pro Hardware-Host `boot.kernelParams = [ "resume_offset=<filefrag -v /swap/swapfile>" ]`; in `modules/aspects/system/power.nix` Warn-Kommentar an `resumeDevice` (Btrfs-Swapfile braucht den Offset); Test: Hibernate→Kaltstart→Session intakt | **hoch** (stiller Session-Verlust am Ziel-Laptop; einziges echtes Funktionsrisiko dieser Dimension) | 1-2 h | **1** |
| 2 | **Taxonomie bereinigen**: `core/fonts.nix`→`desktop/`, `core/nix-ld.nix`→`development/`, `core/performance.nix`→`system/` verschieben (Aggregator-Imports mechanisch mitziehen); in `core.nix` die Fremd-Imports (`fish`, `git`, `llm-agents`) entweder herauslösen (echtes Minimal-Core) oder im Kommentar als bewusste „Arbeitsplatz-Basis" deklarieren; `bootstrap.nix`-Überlappung dokumentieren | mittel (direkt das Besitzer-Ziel „Struktur + Wartbarkeit"; keine Funktionsrisiken) | 2-3 h | **2** |
| 3 | **Options-API dokumentieren**: `description` in `core/users-profile.nix:3-8` + `parts/configuration.nix` (iso/host-Submodule, hostname); `hostname`-Default-Typfehler beheben (`:33`); `theme`-Option entweder in `stylix.nix:8`/`tuicr.nix:13` konsumieren (single source of truth) oder streichen | mittel (API-Doku einer als wiederverwendbar veröffentlichten Bibliothek; verhindert zukünftige Latenz-Fehler) | 2 h | **3** |
| 4 | **Sudo-/Faktor-Posture festschreiben**: Warum-Kommentar in `core/security.nix` (wheelNeedsPassword=false + sudo-rs + Zusammenspiel nouserok/yubikey-pam, inkl. WSL-Realität); einmal `pamu2fcfg` ausführen und sudo-rs+U2F manuell testen; optional `wheelNeedsPassword = true` für Hardware-Hosts | mittel (security-Klarheit; kein akuter Bruch) | 1 h | **4** |
| 5 | **README-Drift + Kompositions-Vertrag**: README.md:21/:46 korrigieren (`modules/parts/configuration.nix` statt options.nix/factories.nix); Kompositions-Matrix (core standalone, system⇒Hardware, impermanence⇒disko) ergänzen; `age-rekey.nix:9` pathExists-Guard analog `certificates.nix:6` | gering-mittel (Onboarding bei Public Release; verhindert Fehlkomposition) | 0.5-1 h | **5** |
| 6 | *(optional)* mDNS-Laufzeit-Check statt Firewall-Änderung: auf dem Ziel-Laptop `avahi-resolve -n foo.local` + nft-Counter prüfen; nur bei nachweislich defekter Auflösung `services.avahi.openFirewall` setzen (nicht blind 5353 öffnen — widerspräche der bewusst deaktivierten publish-Posture) | gering | 0.25 h | 6 |

**Was NICHT tun:** Keine Assertions/Constraint-Layer für die Komposition bauen (Over-Engineering; Fehlerfälle sind beim ersten Boot selbst-erklärend), keine Firewall-Ports ohne Laufzeit-Beweis öffnen, keine Options-Fabriken/Ersatz-Doku-Generierung — die Lücken sind Redaktionsarbeit, keine Strukturarbeit.

**Zur Trägheit des Desktops:** core/system sind nicht die Ursache — die einzige productive Instanz läuft ohne `system`, und die performance-relevanten Entscheidungen in dieser Dimension sind durchweg richtig und begründet (`nix.nix:10-14,35-38`, `network.nix:31-65`, `performance.nix`, `network-wifi.nix:15-26`). Die Trägheit ist mit hoher Wahrscheinlichkeit in der Windows/WSLg-Schicht, im Windows-Dateisystem-IO oder in der Desktop-Dimension (niri/dms — separater Report) zu suchen.

## Risiken und unknowns

- **resume_offset-Konsequenz**: Meine Folge-Analyse (Schrieb OK, Resume fail) basiert auf Kernel-Verhalten (zram wird bei der Hibernate-Device-Auswahl übersprungen; Resume ohne Offset findet die Signatur nicht) — allgemeines Wissen, nicht aus dem Quellcode ableitbar. Ein einziger Laufzeit-Test am Ziel-Laptop klärt es definitiv; bis dahin ist Prio 1 trotzdem gerechtfertigt (Aufwand gering, Schaden hoch).
- **M4-Conntrack-Mechanismus**: Im Jail nicht live verifizierbar. Wenn der Laufzeit-Check auf dem Ziel-Laptop aktive `.local`-Queries durch die Firewall bestätigt, ist M4 endgültig tot; falls nicht, bleibt die Empfehlung 6 als bewusste, begrenzte Öffnung.
- **sudo-rs + pam_u2f**: Keine Quellcode-Evidenz in diesem Repo; Zuverlässigkeit nur über manuellen Test am Zielgerät feststellbar.
- **disko-Swapfile-Erzeugung** (`btrfs filesystem mkswapfile`, NOCOW korrekt) übernehme ich aus dem Forscherbericht — gegen disko-Quelle `725ea35e` nicht selbst nachgeprüft; für das H1-Urteil nicht entscheidend (der Offset fehlt unabhängig davon).
- **Es könnte weitere Consumer-Repos geben**, die ich nicht sehen kann (privates Laptop-Setup außerhalb `/home/denis/repositories/private/`). Meine Aussage „system ist dormant" gilt für die hier sichtbaren Repos; sie ändert nichts an den Empfehlungen, wohl aber an der Dringlichkeit von Prio 1, falls das Ziel-Laptop bereits produktiv läuft.

