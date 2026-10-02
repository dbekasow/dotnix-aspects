# Runtime-Performance Desktop (Config-Sicht) — Researcher 9/10

Repo: `/home/denis/repositories/private/.dotnix-aspects` (Branch `main`, HEAD `ac7724c`, Arbeitskopie: nur `M modules/aspects/term/shell-ux/sesh.nix` — unberührt). Nur Konfigurationsanalyse, kein Live-Zugriff, keine nix-Kommandos, keine Änderungen.

## Summary

Das Desktop-Setup (niri-unstable + DankMaterialShell als Quickshell-Bar + dank-greeter + home-manager) ist konfigurativ schlank: kein Blur, kein locate-Timer, kein autoUpgrade, keine privaten systemd-Timer außer den guten Hausmeistern (fstrim, nix-optimise, nh-clean — alle weekly). Zram (25 %, zstd, prio 100) ist konfiguriert, Swapfile 64G nur für Hibernate (swappiness 10), Nix-Daemon läuft auf IO/CPU-„idle“ — Hintergrund-Rebuilds sollen den Desktop nicht blockieren. **Impermanence läuft hier als btrfs-Rollback, NICHT als tmpfs** (`disko.nix` subvol @persist/@log; `impermanence.nix` initrd-Rollback) — RAM-Druck durch tmpfs-Home ist als Erklärung für die Trägheit ausgeschlossen.

Der einzige fette, permanent laufende Desktop-Client ist **DMS selbst**: Systemmonitoring-Polling, CPU/RAM/Temperatur-Widgets, Audio-Visualizer + Waveform (PulseAudio-Tap), Wetter-Widget, Kalender-Events, Clipboard-History, Ripple-Effekte — alles per Default an. Dazu ein ungeklärter Dauerdienst `dsearch`. Auf der Systemseite fehlen thermald und jedes thermische/Governor-Tuning (nur power-profiles-daemon); der polkit-Agent wurde deaktiviert, ohne dass der laut Kommentar vorgesehene Ersatz (polkit-gnome) irgendwo aktiviert wird.

**Inventar: was permanent bzw. periodisch läuft** (Beleg jeweils in Findings/Dateien):

| Komponente | Typ | Quelle (Datei) |
| --- | --- | --- |
| niri-unstable | Wayland-Compositor (greetd-Session) | `desktop/compositor/niri.nix:10-11` |
| xwayland-satellite | lazy (nur bei X11-Client, via niri) | `desktop/compositor/niri.nix:19` |
| DankMaterialShell (Bar) | systemd-user-Service, restartIfChanged | `desktop/shell/dms.nix:8-11` |
| dsearch | NixOS-Service (Rolle ungeklärt) | `desktop/shell/dms.nix:12` |
| dank-greeter (quickshell) | nur Greeter-Phase, nach Login beendet | `desktop/greeter/dms-greeter.nix:7-9` |
| DMS-Plugins (Wetter, Batterie-Alerts, WebSearch, PowerOptions, displayManager) | in DMS-Prozess | `desktop/shell/dms-plugins.nix:7-13` |
| pipewire + wireplumber (+ JACK-Sockel) | Sound-Daemon | `system/pipewire.nix:4-21` |
| power-profiles-daemon, upower | Energie-Daemonen | `system/power.nix:14-18` |
| NetworkManager + iwd (powersave aus), avahi (publish aus), systemd-resolved (Cache an) | Netzwerk | `system/network.nix`, `system/network-wifi.nix` |
| bluetoothd (powerOnBoot, FastConnectable, experimental) | Daemon ab Boot | `system/bluetooth.nix:4-12` |
| geoclue2 (inkl. gammastep-AppConfig für ein nicht vorhandenes gammastep) | Standort-Daemon ohne erkennbaren Abnehmer | `system/geolocation.nix:3-16`, `dms-settings.nix:170,29` |
| gnome-keyring, gvfs, tumbler (Thumbnails on demand), xdg-portale (gnome+gtk), dbus-broker | Desktop-Basisdienste | `desktop/compositor/gnome-services.nix:4-14`, `desktop/shell/thunar.nix:12-13`, `desktop/compositor/xdg-portals.nix` |
| fprintd | nur dbus-aktiviert (keine PAM-Anbindung, enableFprint=false) | `desktop/shell/dms.nix:16`, `dms-settings.nix` (enableFprint=false) |
| agenix/agenix-rekey | Boot-Aktivierung der Secrets (age.nix, age-rekey.nix), kein Dauerläufer |
| Timer weekly: fstrim, nix.optimise.automatic, nh clean (`--keep 3 --keep-since 7d`) | Timer | `core/performance.nix:34`, `core/nix.nix:42`, `core/nh.nix:5-8` |
| tealdeer auto_update | bei Shell-Invoaktion, 720 h | `term/monitoring/tealdeer.nix:8-9` |
| fastfetch | bei **jeder** interaktiven fish-Shell (Greeting) | `term/monitoring/fastfetch.nix:23-25` |
| Monitoring-Aspekt (10 Dateien) | **rein CLI-Tools** (bandwhich, btm, hyperfine, …) — kein Daemon, kein Timer | `term/monitoring/*` (insgesamt geprüft) |
| locate-Timer | nicht vorhanden (locate nicht installiert) | grep über modules/ + templates: 0 Treffer |
| journald-Limits | nicht konfiguriert (Defaults), /var/log persistent via @log-Subvol | `system/disko.nix:44-46`, kein `services.journald` im Repo |

Fehlt komplett im Repo: thermald, Governor/EPP-Tuning, journald-Limits, ein lokatierter Standort für das Wetter-Widget.

## Findings

### High

#### 1. DMS als Dauerlast-Paket: Monitoring-Polling, Audio-Visualizer, Ripple, Wetter — alles an
Dateien: `modules/aspects/desktop/shell/dms.nix`, `modules/aspects/desktop/shell/dms-settings.nix`
Beleg:
- `dms.nix:29-33`: `enableAudioWavelength = true;` … `enableClipboardPaste = true; enableDynamicTheming = true; enableSystemMonitoring = true;`
- `dms-settings.nix:359-360`: `centerWidgets = [ "music" "clock" "weather" ];` / `rightWidgets = [ "systemTray" "clipboard" "cpuUsage" "memUsage" … ];`
- `dms-settings.nix:53-55`: `showCpuUsage = true; showMemUsage = true; showCpuTemp = true;`
- `dms-settings.nix:115-117`: `waveProgressEnabled = true; scrollTitleEnabled = true; audioVisualizerEnabled = true;`
- `dms-settings.nix:37`: `enableRippleEffects = true;`
Warum wichtig: DMS ist der einzige stets laufende Desktop-Client (Quickshell/QtQuick, systemd-user-Service). CPU/RAM/Temp-Widgets pollen zyklisch, der Audio-Visualizer hält eine permanente PulseAudio-Aufnahme-Pipe offen, Ripple-Effekte erzeugen Event-Renderlast. Konstante Idle-CPU eines Bars ist der klassische „Desktop fühlt sich träge an“-Verdächtige. Entlastend: `blurEnabled = false` (dms-settings.nix:38), Popout/Modal-Animationen moderat (150 ms), Dock aus. → Mit Messschritt 1–3 direkt quantifizierbar.

#### 2. Kein thermald, kein Governor-/EPP-Tuning — nur power-profiles-daemon
Dateien: `modules/aspects/system/power.nix`; negatives Ergebnis von `grep -rn "thermald|governor"` über modules/ + templates/
Beleg: `power.nix:18`: `power-profiles-daemon.enable = true;` — das ist die **einzige** Scheduler-/Energie-Stellschraube; dazu `power.nix:30-31` nur `mem_sleep_default=deep` und das cpupower-**Werkzeug** (keine Einstellung). `core/performance.nix` enthält ausschließlich vm.*-sysctls, zramSwap, fstrim.
Warum wichtig: Host-Template ist ein Dell Precision 5570 (`templates/dotnix/modules/hosts/myHost/hardware.nix:3-5`, nixos-hardware-Import), also Intel-HX-Laptop. PPD regelt EPP/Governor, aber **nicht** das thermische Budget — thermald ist auf Intel-Laptops der Standard-Baustein gegen unvorhergesehenes Throttling. „Unter Last träge, im kalten Zustand okay“ wäre das klassische Symptom. Auch kein `hardware.cpu.intel.updateMicrocode` im Repo (evtl. via nixos-hardware-Modul abgedeckt — Messschritt 7 klärt, ob der Dienst/Paket überhaupt da ist).

### Medium

#### 3. polkit-Agent deaktiviert, angekündigter Ersatz (polkit-gnome) nirgends konfiguriert
Dateien: `modules/aspects/desktop/compositor/niri.nix`; negatives grep-Ergebnis für einen Agenten im ganzen Repo
Beleg: `niri.nix:15-16`:
```nix
# Disable broken polkit-kde-agent, use polkit-gnome instead
systemd.user.services.niri-flake-polkit.enable = false;
```
Grep `polkit` über modules/ + templates/: nur `security.polkit.enable = true` (`core/security.nix:11`) — **keine einzige Zeile startet polkit-gnome oder einen anderen Agenten**.
Warum wichtig: Ohne polkit-Agent laufen GUI-Authentifizierungen (mounten, NetworkManager, Drucker, GParted …) ins Leere oder in Timeouts — hängende Dialoge bei Systemaktionen fühlen sich wie „System hängt/träge“ an. Möglicherweise bringt DMS selbst einen Agenten mit (von hier nicht belegbar) → Messschritt 6.

#### 4. fastfetch in fish_greeting — Kosten bei jedem Terminal-Open
Datei: `modules/aspects/term/monitoring/fastfetch.nix`
Beleg: `fastfetch.nix:23-25`:
```nix
programs.fish.functions.fish_greeting = lib.mkIf config.programs.fish.enable {
  description = "Greeting with fastfetch";
  body = "fastfetch";
};
```
Warum wichtig: fastfetch liest Dutzende /sys-, /proc- und Paketdatenquellen (hier: os, kernel, packages, disk …, `fastfetch.nix:8-21`) — pro interaktivem Shell-Start spürbare 50–200 ms. Terminal-Öffnen ist die häufigste Interaktion eines Terminal-Zentrierten Setups (fish ist Default-Shell, `core/users.nix:3`); hier entsteht direkt wahrgenommene „Trägheit“.

#### 5. Wetter-Widget aktiv, aber kein Standort konfiguriert — Verdacht auf Wiederholungsversuche
Datei: `modules/aspects/desktop/shell/dms-settings.nix`
Beleg: `dms-settings.nix:170-171`: `useAutoLocation = false; weatherEnabled = true;` + `:359` centerWidgets enthält `"weather"`; im gesamten Settings-Satz existiert **kein** Standort-Feld (nur `weatherEnabled`, `useAutoLocation`, `networkPreference`). Geoclue2 läuft zwar (`system/geolocation.nix:5`), DMS fragt es aber laut `useAutoLocation = false` gerade nicht.
Warum wichtig: Ohne Standort kann der Wetter-Provider-Aufruf nur scheitern; ob DMS dann mit Backoff wiederholt oder in eine enge Retry-Schleife fällt, ist von der Config nicht entscheidbar — periodische CPU/Netzwerk-Spitzen wären die Folge. Messschritt 4 (Zeitstempel in DMS-Log) verifiziert.

#### 6. Firefox DoH (trr.mode=2) umgeht den konfigurierten resolved-Cache; obsoleter Autoplay-Pref
Dateien: `modules/aspects/desktop/apps/firefox.nix`, `modules/aspects/system/network.nix`
Beleg: `firefox.nix:44`: `"network.trr.mode" = 2;` — Firefox macht eigene DoH-Requests und geht damit an systemd-resolved vorbei, das mit `Cache = "yes"` explizit als lokaler Cache aufgebaut ist (`network.nix:31-36`, mit Begründung „spart Roundtrips“). `firefox.nix:70`: `"media.autoplay.enabled" = false;` — dieser Pref existiert in aktuellen Firefox-Versionen nicht mehr (seit langem durch `media.autoplay.default` ersetzt), ist also wirkungslos.
Warum wichtig: Browsing-Latenz ist Teil des Desktop-Gefühls: erste DNS-Lookups pro Domain laufen über DoH-RTT statt den lokalen Cache (WLAN ~30 ms), statt wie gedacht über resolved. Kein Drama, aber ein reales, von der Config verursachtes Browsen-Delta — messbar über `about:networking#dns` (Schritt 8).

### Low

#### 7. Geoclue2-Daemon läuft ohne erkennbaren Abnehmer (totes gammastep-AppConfig)
Dateien: `modules/aspects/system/geolocation.nix`, `modules/aspects/desktop/shell/dms-settings.nix`
Beleg: `geolocation.nix:13-15`: `appConfig.gammastep = { isAllowed = true; … }` — gammastep ist nirgends im Repo als Paket/Modul konfiguriert (0 Treffer für ein gammastep-Programm). DMS fragt laut `useAutoLocation = false` (`dms-settings.nix:170`) keinen Standort ab, night mode intern aus (`dms-settings.nix:29: nightModeEnabled = false`).
Warum wichtig: Daemon + Agents laufen ohne Nutzen; minimaler Dauer-Footprint. Aufräumen senkt die Daemanzahl (Wartbarkeit), nicht spürbar die Last.

#### 8. Keine journald-Limits konfiguriert — Defaults auf persistentem @log-Subvol
Dateien: negatives grep über `modules/` (`services.journald` = 0 Treffer); `modules/aspects/system/disko.nix:44-46`
Beleg: `disko.nix`: `"@log" = mkSubvol "/var/log";` + `fileSystems."/var/log".neededForBoot = true;` — Logs sind persistent auf btrfs; journald läuft mit Upstream-Defaults (bis 10 % FS / 4 GB).
Warum wichtig: Kein RAM-Druck, aber unbegrenzte Log-Ausbreitung auf LUKS+btrfs; eine Zeile `services.journald.extraConfig` (bzw. `settings`) mit `SystemMaxUse=` wäre Standard-Hygiene.

#### 9. Entkräftet: „Impermanence → tmpfs → RAM-Druck“
Dateien: `modules/aspects/system/impermanence.nix`, `modules/aspects/system/disko.nix`, `modules/aspects/system/boot.nix`, `modules/aspects/core/performance.nix`
Beleg: Impermanence arbeitet über btrfs-Subvol-Rollback im initrd (`impermanence.nix:6-23`: `btrfs subvolume delete` + `snapshot @root-blank → @root`), persistente Daten liegen auf eigenem @persist-Subvol (`disko.nix:40-42`), nicht im RAM; zram ist bewusst dimensioniert (`performance.nix:25-30`: 25 %, zstd, prio 100, Swapfile nur Hibernate). Einziger tmpfs-Bewohner ist /tmp (NixOS-Default) mit `tmp.cleanOnBoot = true` (`boot.nix:19`).
Warum wichtig: Diese Hypothese der Aufgabenstellung ist config-seitig widerlegt — RAM-Druck-Quellen sind die Anwendungen (DMS, Browser), nicht die Persistenz-Strategie. Für RAM bleibt `free -m` gegen zramSwap = 25 % RAM (Schritt 5).

#### 10. Nix-GC/Timers: gesund, aber close-Politik pragmatisch
Dateien: `modules/aspects/core/nh.nix`, `modules/aspects/core/nix.nix`
Beleg: `nh.nix:5-8`: weekly clean `--keep 3 --keep-since 7d`; `nix.nix:14`: `auto-optimise-store = false;` (Kommentar: Dedup-Pass wurde bewusst dem weekly `optimise.automatic` überlassen, `nix.nix:42`); `nix.nix:36-37`: Nix-Daemon auf `idle`-IO/CPU.
Warum wichtig: Kein Befund, sondern Absicherung des Inventars: kein GC-Sturm, kein Store-Dedup unter Lock pro Build. /nix auf eigenem Subvol (`disko.nix:41`) — `nix store du` (Schritt 9) zeigt das echte Belegungswachstum zwischen den weekly Cleans.

## Messplan (≈ 60 Minuten, Reihenfolge = Verdachtsränge)

1. **Boot-Pathologie ausschließen (5 min):** `systemd-analyze` und `systemd-analyze critical-chain` — erwartet: keine Unit > 5 s außer cryptsetup/greetd; initrd-Rollback-Zeit ist anteilig in `systemd-analyze` (Zeit vor userspace) sichtbar. Danach `systemd-analyze blame | head -20`.
2. **DMS-Idle-Last quantifizieren (10 min):** `systemd-cgtop -m -p --depth=3` 60 s im Leerlauf beobachten — Zeile der DMS-User-Unit notieren (CPU %, Mem). Vergleichsmessung: DMS kurz killen (`systemctl --user stop dank-material-shell`) und Interaktionsgefühl (Fenster-Fokus, Launcher) subjektiv gegenüberstellen.
3. **Idle-CPU prozessgenau (10 min):** `top -b -n 10 -d 2 | grep -E "dms|niri|quickshell|xwayland|pipewire"` bzw. `pidstat 2 30 -u` — wer steht im Leerlauf wiederholt > 1–2 % CPU? Erwartungsbild laut Findings: DMS (Monitoring-Poll + Visualizer) vor Firefox.
4. **Wetter-Retry-Schleife prüfen (5 min):** `journalctl --user -b -u dank-material-shell -f` 3–4 min im Leerlauf laufen lassen; parallel `journalctl -b -t dsearch*` auf periodische Muster prüfen. Wiederkehrende Wetter-/Fehlerlinien mit Intervall < 5 min = Bestätigung Finding 5.
5. **RAM vs. zram (5 min):** `free -m; zramctl; swapon --show` — zram-Belegung gegen 25 % RAM-Deckel, Swapfile sollte ~0 zeigen; `cat /proc/pressure/memory` (PSI) für latenten Druck.
6. **Polkit-Agent prüfen (2 min):** `pgrep -af "polkit.*agent"` — leer = Finding 3 bestätigt; dann eine GUI-Aktion auslösen (z. B. `nm-connection-editor`), die Auth verlangt, und Timeouts stoppen.
7. **Thermik/Governor (10 min):** `systemctl status thermald` (erwartet: not-found), `powerprofilesctl` (erwartet: performance an AC laut `acProfileName`, dms-settings.nix:206), `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor` + `energy_performance_preference` vor/nach 10 min `stress-ng --cpu 8 --timeout 600s` mit `sensors` alle 30 s — Takt-Einbruch bei steigender Temperatur = thermisches Throttling (Finding 2).
8. **Browser-Latenz-DNS (5 min):** Firefox `about:networking#dns` nach Kaltstart von 10 neuen Domains — TRR-Verwendung vs. `resolvectl statistics` (Cache-Treffer sollten bei Nicht-Firefox-Anwendungen steigen).
9. **Store/Persistenz (5 min):** `nix store du -s /run/current-system` + `du -sh /nix/var/nix/gcroots` (nur lesen, kein GC!), `df -h /nix /persist /var/log` — Füllgrad der Subvols gegen die weekly-clean-Politik.
10. **Fehlerlog-Lage (3 min):** `journalctl -b -p 3` und `journalctl -b --user -p warning | tail -50` — wiederkehrende Fehler (Session-Restarts, DMS-Crash-Loops, Derivat-Warnungen) sind die schnellsten Trägheits-Ursachen; `journalctl --disk-usage` gegen Finding 8.

Auswertung: Findings bestätigt/verworfen je Schritt notieren; die Schritte 1–7 decken > 90 % der config-seitigen Verdachtsmomente ab.

## HardQuestions

1. **Bringt DMS (AvengeMedia, rev. laut flake.lock) selbst einen polkit-Agenten mit — oder läuft der Desktop tatsächlich ohne Agenten (Finding 3)?** Der Kommentar in `niri.nix:15` behauptet polkit-gnome, das Repo konfiguriert aber nichts — ist das ein verlorener Refactor-Schritt oder verlässt sich der Autor unbelegt auf DMS?
2. **Was ist `dsearch` (`dms.nix:12`, programs.dsearch) konkret — App-Suchindexer mit permanentem Index-Lauf oder schlanker Launcher-Dienst?** Ohne Klärung bleibt ein ungeklärter Dauerdienst im kritischen Desktop-Pfad; Schritt 4/6 des Messplans liefert die Antwort live.
3. **War kein thermald bewusst oder übersehen?** Angesichts Dell Precision 5570 (Hardware-Template) + „unter Last träge“-Symptomatik: Wenn Schritt 7 Throttling zeigt, ist das die höchstwertige Einzelursache — und die Antwort entscheidet, ob Performance-Arbeit am Kernel-Pfad oder an DMS ansetzt.
