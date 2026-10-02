# Orakel-Gutachten: Runtime-Performance Desktop (Config-Sicht)

Datum: 2026-10-02 · Repo: `/home/denis/repositories/private/.dotnix-aspects` (read-only geprüft) · DMS-Upstream: AvengeMedia/DankMaterialShell @ `a609b5f999a9` (aus flake.lock, Quellcode verifiziert)

## Urteil

Die Config ist an den klassischen Verdachtsstellen sauber (kein Blur, zram 25 %/zstd/prio 100, Nix-Daemon auf `idle`, GC/Timer-Hygiene, Impermanence via btrfs-Rollback statt tmpfs) — die Trägheit kommt hier nicht her. Die zwei echten config-seitigen Ursachenfelder sind: **(1) Energie-/Thermik-Profil** (kein thermald, und DMS fährt auf Batterie power-profiles-daemon auf `power-saver` — `dms-settings.nix:209`), und **(2) ein Bündel vom Researcher übersehener Dauerläufer/Timer** — allen voran der `dsearch`-Datei-Indexer (dauerhafter User-Service mit File-Watcher + Parallel-Indexierung), dazu docker-rootless mit `linger = true`, `handy` mit Restart-on-failure und ein mbsync-Timer alle 15 Minuten. DMS selbst ist als Dauerlast deutlich entschärft: Monitoring pollt nur bei sichtbarem Widget (3 s/30 s), Cava-Visualizer läuft nur während Musikwiedergabe, Wetter hat IP-Fallback und exponentiellen Backoff unter `nice`/`ionice`. Dritter Faktor: fastfetch bei jedem fish-Start. Erst messen (Plan unten, ~55 min), dann `batteryProfileName`, thermald und dsearch anfassen.

## Widerlegtes (adversarial: jede High/Medium-Finding selbst geprüft)

| # | Finding | Urteil | Beleg |
|---|---|---|---|
| 1 | DMS als Dauerlast-Paket (Visualizer „permanente PulseAudio-Pipe", Monitoring-Polling, Ripple) | **Weitgehend widerlegt** (Kern faktenwidrig, Rest stark entschärft) | Cava läuft nur bei `visible && enabled && isPlaying` (DMS `AudioVisualization.qml:10-13`, `CavaService.qml:33-35`, refCount-gesteuert). Dgop-Poll nur bei sichtbarem Widget, 3 s aktiv / 30 s Hintergrund, 6 s/60 s im Power-Saver (DMS `DgopService.qml:19,23`, `MonitorPill.qml:38-40`). Ripple ist klickgetrieben (`MonitorPill.qml:131`). `enableAudioWavelength` etc. in `dms.nix:29-33` sind laut DMS-`options.nix` nur **Dependency-Schalter** („Add needed dependencies"), keine Verhaltensschalter. `systemMonitorEnabled = false` (dms-settings.nix:408) — der schwere Desktop-Monitor ist aus. Was bleibt: `dms.service` ist der größte permanente Desktop-Client, aber mit kleiner, messbarer Last. |
| 2 | Kein thermald / kein Governor-EPP-Tuning, nur PPD | **Bestätigt** (als Config-Faktum; nixos-hardware-Effekt nicht von hier prüfbar) | `power.nix:18` ist die einzige Energie-Stellschraube; `grep thermald|governor` über modules/ + templates/: 0 Treffer. Wichtig ergänzend: DMS fährt auf Batterie PPD auf `power-saver` (`dms-settings.nix:209`), auf AC `performance` (`:204`). |
| 3 | polkit-Agent deaktiviert, Ersatz nirgends konfiguriert → GUI-Auth ins Leere | **Widerlegt** | DMS bringt einen eigenen Polkit-Agenten mit und lädt ihn per Default: `PolkitService.qml:12-14` (`disablePolkitIntegration` nur via `DMS_DISABLE_POLKIT=1`), `:71-75` lädt `PolkitAgentInstance.qml`; DMS-README: „It replaces waybar, swaylock, swayidle, mako, fuzzel, **polkit**...". Der Kommentar in `niri.nix:15-16` („use polkit-gnome instead") ist veralteter Wortlaut, funktional läuft der Agent über DMS. |
| 4 | fastfetch in `fish_greeting` — Kosten bei jedem Terminal-Open | **Bestätigt** | `fastfetch.nix:23-25`: `fish_greeting` ruft `fastfetch` auf; Module inkl. `packages` (Store-Scan) und `disk` (`fastfetch.nix:8-21`); fish ist Default-Shell (`core/users.nix`-Umfeld, terminal-Aspekt importiert fish). 50–200 ms pro interaktivem Shell-Start — direkte wahrgenommene Latenz. |
| 5 | Wetter-Widget ohne Standort → Retry-Verdacht | **Widerlegt** | DMS hat einen **IP-Location-Fallback** (`WeatherService.qml:816-856`, ip-api.com); Fetch-Intervall 15 min (`:44`), max 3 Retries à 30 s (`:45-47`), bei persistentem Scheitern exponentieller Backoff gedeckelt auf 5 min (`:695-698`); alle Fetches laufen als `dms dl` mit `nice -n 19 ionice -c3` und Timeouts 8/20 s (`:55-56`). Kein enger Loop, keine nennenswerte CPU. Randnotiz: ohne konfigurierten Standort fragt DMS regelmäßig einen externen IP-Geolocation-Dienst an (Privacy, nicht Perf). |
| 6 | Firefox DoH umgeht resolved-Cache; toter Autoplay-Pref | **Bestätigt, aber downgestuft auf LOW** | `firefox.nix`: `"network.trr.mode" = 2` (bewusst, „preferred, falls back"); `media.autoplay.enabled` ist tatsächlich ein seit langem entfernter, wirkungsloser Pref. Beides reale, aber kleine Effekte — keine Trägheitsursache ersten Ranges. |
| 7 | geoclue2 ohne Abnehmer (totes gammastep-AppConfig) | **Abgeschwächt, steht als Aufräumen** | `geolocation.nix:3-16` mit toter gammastep-appConfig; aber das DMS-NixOS-Modul setzt `services.geoclue2.enable = mkDefault true` sowieso (DMS `nixos.nix`) — der Aspekt ist redundant, nicht schädlich. |
| 8 | Keine journald-Limits | **Bestätigt** (Hygiene, nicht Trägheit) | `services.journald` = 0 Treffer; `disko.nix` @log-Subvol persistent. |
| 9 | Impermanence→tmpfs→RAM-Druck | **Bestätigt entkräftet** | `impermanence.nix:6-23` initrd-btrfs-Rollback, `disko.nix` @persist-Subvol; zram bewusst dimensioniert (`performance.nix`). |
| 10 | Nix-GC/Timer gesund | **Bestätigt** | `nix.nix:14,36-42`, `nh.nix:5-8`, fstrim weekly. Kein Optimise-Sturm. |

### Übersehene Dauerläufer/Timer (die adversarial geforderte Lücke — Researcher-Inventar war unvollständig)

| Dienst/Timer | Beleg (Repo) | Einordnung |
|---|---|---|
| **dsearch.service** (danksearch-Datei-Indexer) | `dms.nix:12` (`programs.dsearch.enable = true`); nixpkgs-Modul `programs/dsearch` (im gelockten nixpkgs 3181085 enthalten, module-list.nix:211) setzt `systemd.user.services.dsearch.wantedBy = [ "default.target" ]` | Dauerläufer ab Session-Start. danksearch: „Indexes all files in specified paths", Multi-Worker-Parallel-Indexierung, **File-Watcher für inkrementelle Updates**, optional Content-/EXIF-Extraktion. Default-Config wird zur Laufzeit generiert — was default indexiert wird, ist vom Repo aus nicht entscheidbar. Auf einem Dev-Home (git-Repos, Build-Churn) ein echter Dauerlast-/Mikrostall-Verdächtiger. |
| **handy** (Speech-to-Text) | `desktop/apps/handy.nix:10-27`: systemd.user.service, `--start-hidden`, `Restart = "on-failure"`, `RestartSec = 5` | Dauerläufer in der Session; Crash-Loop würde alle 5 s CPU spendieren. Nicht im Researcher-Inventar. |
| **mbsync-Timer (15 min)** | `term/mailing/maildir.nix:8-9`: `services.mbsync.frequency = "*:0/15"`, plus `notmuch hooks.preNew = "mbsync --all"` (`:17`) | home-manager erzeugt systemd-User-**Timer** — die Behauptung „keine privaten systemd-Timer außer fstrim/optimise/nh-clean" ist falsch, sofern der terminal-Aspekt + E-Mail-Konten aktiv sind (maildir hängt im terminal-Aggregator, `terminal.nix` „Mail: aerc, maildir"). Periodische IMAP-Sync-Bursts. |
| **docker rootless + linger** | `development/devops/docker.nix`: `virtualisation.docker.enable/rootless.enable = true`, `autoPrune.enable = true`, `linger = true` für alle Host-Member (`:16`); development-Aspekt wird vom Template-Host importiert (`templates/dotnix/modules/hosts/myHost/configuration.nix`) | Per-User dockerd läuft dank linger ab Boot im User-Manager (nicht erst bei Nutzung), plus autoPrune-Timer. Falls auf dem Desktop-Host aktiv: mehrere 100 MB RSS + Grund-CPU ohne Nutzen. |
| accounts-daemon, pcscd, timesyncd | DMS `nixos.nix` (`services.accounts-daemon.enable = mkDefault true`), `core/yubikey.nix:4`, `core/locale.nix:24` | kleine Dauerläufer; accounts-daemon fehlte im Researcher-Inventar. |

Einschränkung (Ehrlichkeit): `dms-settings.nix` wird vom `homeManager.desktop`-Aggregator **nicht** importiert (`desktop.nix` listet dms, dms-plugins, … aber nicht dms-settings). Ob der Owner es host-seitig zusätzlich zieht, ist außerhalb dieses Repos nicht verifizierbar. Die Settings-Datei spiegelt das DMS-Schema; DMS-Defaults dürften ähnlich liegen (Wetter-Widget an, power-saver auf Batterie) — live mit der DMS-Settings-GUI prüfen. Findings 1/5 ändern ihr Urteil dadurch nicht (widerlegt ist widerlegt), Root-Cause 1 bleibt in beiden Fällen relevant.

## Antworten auf HardQuestions

**1. Bringt DMS selbst einen polkit-Agenten mit?** Ja — belegt, nicht Hypothese: `PolkitService.qml` aktiviert `PolkitAgentInstance.qml` per Default, abschaltbar nur über `DMS_DISABLE_POLKIT=1`. Der Kommentar in `niri.nix:15` („use polkit-gnome instead") ist ein verlorener/veralteter Refaktorierungs-Satz — der Autor verlässt sich (zutreffend) auf DMS. Handeln: nur Kommentar korrigieren; live `pgrep -af polkit` zur Sicherheit. Researcher-Finding 3 damit erledigt.

**2. Was ist `dsearch` konkret?** `dsearch` = **danksearch** (github.com/AvengeMedia/danksearch, siehe DMS-README): ein Go-Dienst auf Bleve-Basis — Dateisystem-Suchindex mit Fuzzy-Matching, Multi-Worker-Parallel-Indexierung, permanentem File-Watcher für inkrementelle Updates, optional Content- und EXIF-Extraktion. `programs.dsearch.enable = true` (`dms.nix:12`) installiert das Paket und startet `dsearch.service` im User-Manager wantedBy `default.target`, d. h. dauerhaft ab Login. Der DMS-Launcher nutzt ihn für Datei-Suchergebnisse (`DSearchService.qml`: CLI-Aufrufe `dsearch search/ping --json`). Kein blosser Launcher-Dienst — ein echter Indexer. Offen (nur live klärbar): welche Pfade die Laufzeit-Default-Config indexiert und wie hoch die Watcher-/Reindex-Last auf dem konkreten Home ist. → Messschritt 2.

**3. thermald: bewusst oder übersehen?** Aus dem Repo nicht ableitbar (kein Kommentar, kein negatives Bekenntnis). Fakt: das Repo selbst stellt kein thermisches Management bereit; power-profiles-daemon (`power.nix:18`) regelt EPP/Governor, aber nicht das thermische Budget. Ob das nixos-hardware-Modul `dell-precision-5570` (Template `hardware.nix`) thermald beibringt, ist hier nicht verifizierbar — Messschritt klärt `systemctl status thermald`. Wenn live absent UND Schritt „Thermik" Throttling zeigt: höchstwertige Einzelursache für „unter Last träge". Unabhängig davon greift bereits heute: auf Batterie fährt DMS PPD auf `power-saver` (`dms-settings.nix:209`) — das allein erklärt ein träges UI im Akkubetrieb.

## Root-Cause-Ranking (Top 3, config-seitig, mit Beleg)

1. **Energie-/Thermik-Profil — „träge auf Batterie, Drossel unter Dauerlast".**
   a) `batteryProfileName = "power-saver"` (`dms-settings.nix:209`): DMS schaltet auf Batterie in den Power-Saver — EPP auf maximaler Energieersparnis, CPU tickt klein und hochlatent → Fokuswechsel/Launcher fühlen sich zäh an. Auf AC `performance` (`:204`).
   b) Kein thermald im Repo (`power.nix` nur PPD; grep 0 Treffer): auf einem Intel-HX-Laptop (Template: Dell Precision 5570) fehlt der Drossel-Schutz; unter Dauerlast throttle der Chip unaufgefordert.
   Beleg s.o.; Konfidenz: mittel-hoch (Symptombild „fühlt sich träge an" passt exakt, Messung 4/5 im Plan entscheidet).

2. **Übersehenes Dauerläufer-Bündel — Grundrauschen + periodische Mikrostalls.**
   `dsearch.service` (Indexer + File-Watcher, session-permanent, `dms.nix:12`), docker-rootless mit `linger = true` (`docker.nix:16`, falls development-Aspekt), `handy` mit Restart-on-failure/RestartSec 5 (`handy.nix:10-27`), mbsync-Timer alle 15 min (`maildir.nix:9`). Keiner davon ist ein Einzeltäter, aber zusammen erzeugen sie Idle-CPU, RAM-Fußabdruck und 15-minütige I/O-Bursts — das klassische „System fühlt sich beschäftigt an, ohne dass einer right-clickbar schuldig ist". Konfidenz: mittel (dsearch-Default-Pfade und docker-Aktivität live klären).

3. **fastfetch in `fish_greeting` — wahrgenommene Latenz bei der häufigsten Interaktion.**
   `fastfetch.nix:23-25`: jeder interaktive fish-Start (auch tmux-Panes je nach Wiring) zahlt 50–200 ms für `/sys`-, Paket- und Disk-Reads. Konfidenz: hoch (deterministisch, direkt messbar). Kein Idle-Problem — reines Interaktions-Latenz-Problem.

Explizit NICHT im Ranking: RAM-Druck durch Impermanence (widerlegt, Finding 9), DMS-Monitoring-Polling (visibility-gegate, 3 s), Wetter (Backoff + nice/ionice), Firefox-DoH (bewusster Trade-off, klein), Nix-Hintergrund (idle-Scheduling, weekly Timer).

## Messplan (verfeinert, ~55 min, Reihenfolge = Verdacht)

1. **(8') Dauerläufer-Inventur live — deckt die Lücke des Researchers:** `systemctl --user list-units --type=service --state=running`, `systemctl --user list-timers --all`, `systemctl list-timers --all`, `systemd-cgtop -m -p --depth=3` 60 s Idle beobachten. Erwartung: Zeilen für dms, **dsearch**, handy, (dockerd), pipewire — jede Zeile, die der Researcher-Inventar-Tabelle fehlt, ist ein Fund.
2. **(7') dsearch quantifizieren:** `systemctl --user status dsearch`; Runtime-Config finden und lesen (welche Pfade? Content-Extraktion an?); `pidstat -u -p $(pidof dsearch) 2 30`; dann `git -C <großes Repo> status/checkout` und beobachten, ob der Watcher re-index-Arbeit anstößt (`journalctl --user -u dsearch -f`). Verdacht bestätigt, wenn dsearch im Idle > 1–2 % CPU oder bei Datei-Churn auf > 25 % springt.
3. **(8') Idle-CPU prozessgenau:** `pidstat 2 30 -u | sort` — wer wiederholt > 1 %? Erwartungsbild: dsearch/dockerd/dms vor niri.
4. **(12') Thermik/Governor (Finding 2 + Root-Cause 1a):** `systemctl status thermald` (not-found = Modul-Lücke bestätigt); `powerprofilesctl` auf **AC und Batterie**; `cat /sys/devices/system/cpu/cpu0/cpufreq/{scaling_governor,energy_performance_preference}` je Profil; dann `stress-ng --cpu 8 --timeout 600s` mit `sensors` alle 30 s — Takt-Einbruch bei steigender Temperatur = Throttling.
5. **(5') Batterie-Subjektivtest:** dieselbe Interaktion (Launcher öffnen, Fensterfokus, Terminal) auf Batterie mit `power-saver` vs. `balanced` (`powerprofilesctl set balanced`) — validiert Root-Cause 1a direkt am Symptom.
6. **(4') handy Crash-Loop:** `journalctl --user -u handy -b | tail -50`; `systemctl --user show handy -p NRestarts`. NRestarts > 5 = Fix nötig (StartLimit).
7. **(4') mbsync-Burst:** 15-min-Tick abwarten: `journalctl --user -u mbsync.service -f`; parallel `pidstat` auf den Spike. Falls keine E-Mail-Konten konfiguriert: maildir-Aspekt identifizieren und aus dem User-Import streichen.
8. **(3') RAM/PSI:** `free -m; zramctl; swapon --show; cat /proc/pressure/memory`.
9. **(4') Boot:** `systemd-analyze`; `systemd-analyze critical-chain`; `systemd-analyze blame | head -20` (initrd-Rollback-Zeit ist in der Firmware-/Initrd-Zahl enthalten).
10. **(3') Widerlegungs-Kontrollen in einem Rutsch:** `pgrep -af polkit` (Finding 3 — erwartet: DMS-eigener Agent), `journalctl --user -u dms -f` 3 min (Finding 5 — erwartet: keine Wetter-Fehlerflut, ggf. ip-api-Zugriff).

Gestrichen gegenüber Researcher: Firefox-DNS-Vergleich (LOW, bewusster Trade-off), `nix store du` (kein Trägheitsbezug), journald-Disk-Usage (optional anhängen). Auswertung: Schritt 4+5 entscheiden Root-Cause 1, Schritt 1–3 Root-Cause 2.

## Empfehlungen (Aktion | Impact | Aufwand | Prio)

| Aktion | Impact | Aufwand | Prio |
|---|---|---|---|
| `batteryProfileName` → `"balanced"` in `dms-settings.nix:209` (bzw. DMS-Settings-GUI), vorerst nicht `"performance"` auf Batterie | Hoch — behebt zähes UI im Akkubetrieb | 1 Zeile | **P1** |
| `services.thermald.enable = true;` in `modules/aspects/system/power.nix` ergänzen (nur wenn Messung 4 Throttling/absence zeigt) | Hoch — Drossel-Schutz unter Dauerlast | 1 Zeile | **P1** |
| dsearch begrenzen: Runtime-Config prüfen und auf Dokumente begrenzen, ODER `programs.dsearch.systemd.target = "graphical-session.target"`, ODER deaktivieren, falls Launcher-Dateisuche ungenutzt | Mittel-hoch — entfernt Dauerindexierung aus dem Idle-Pfad | 30 min | **P1** |
| Docker vom Desktop-Host nehmen (Work-VM/Server) oder rootless-Daemon auf Socket-Aktivierung umstellen statt linger+Boot-Start — falls development-Aspekt auf dem Host aktiv | Mittel — RAM/CPU-Grundlast weg | 1–2 h | **P2** |
| fastfetch entschärfen: `packages`/`disk`-Module streichen und/oder Greeting nur in Login-Shell (`status is-login`) statt jeder interaktiven fish | Mittel — fühlbar schnellere Terminals | 10 min | **P2** |
| handy: `StartLimitIntervalSec`/`StartLimitBurst` setzen und Logs nach Crash-Loop prüfen | Niedrig-mittel — verhindert 5-s-Restart-Sturm | 15 min | **P3** |
| Aufräumen: tote gammastep-appConfig streichen, geolocation-Aspekt entfernen falls ungenutzt (DMS aktiviert geoclue2 eh per Default), Kommentar in `niri.nix:15-16` korrigieren („DMS ships its own polkit agent") | Niedrig — Daemanzahl/Klarheit | 15 min | **P3** |
| `services.journald`-Limit setzen (z. B. `SystemMaxUse=1G`) | Niedrig — Log-Hygiene auf @log-Subvol | 1 Zeile | **P3** |

Nicht tun: keine Sysctl-/zram-Spielereien (gut gewählt), kein Blur/FX-Rollback nötig (Blur ist aus, Ripple klickgetrieben), kein Wetter-Widget-Rückbau nötig (Backoff + nice/ionice verbauen das Kostenpotenzial).

