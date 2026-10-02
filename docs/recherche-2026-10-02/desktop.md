# Research 5/10: Aspekt `desktop` (Compositor, Shell, Apps)

Repo: `/home/denis/repositories/private/.dotnix-aspects`, Branch `refactor/public-release`.
Scope: `modules/aspects/desktop/**` — 19 Dateien, 1221 LOC (shell 6, apps 5, compositor 4, terminal 2, greeter 2).
Methodik: Volltextlektüre aller 19 Dateien + Upstream-Abgleich gegen die im `flake.lock` gepinnten Revisionen
(DMS `a609b5f999a9` = 2026-09-28, niri-flake `1a3b34bc592a`, dank-greeter `334b2c93d444`, stylix `fb28acd59e2a`,
dms-plugins `90ddfd245f25`) via GitHub-Raw-Fetches. Keine Nix-Kommandos, keine Code-Änderungen.

## Summary

Der Desktop-Aspekt ist konfiguriert als niri-unstable + DankMaterialShell (DMS) über drei fremde Flake-Inputs
(DMS, dms-plugins, dank-greeter), plus Stylix als zweitem, parallelem Theming-System. Die drei größten Probleme:

1. **`dms-settings.nix` (457 LOC) ist ein zu ~92 % wortwörtlicher Klon der DMS-Upstream-Defaults** —
   maschinell verifiziert gegen `SettingsSpec.js`/`SharedSettingsSpec.js` des gepinnten DMS-Revs. Der Mirror
   pinnt zudem `configVersion = 5`, während DMS @locked intern Version 16 migriert — bei jedem Start läuft die
   komplette Migrationskette über die Datei, und Home-Manager schreibt sie bei jedem Switch wieder auf Alt-
   zurück. Doppel-Writer-Konflikt (HM generiert `settings.json`, DMS schreibt sie zur Laufzeit selbst).
2. **`programs.dsearch.enable = true` (`dms.nix:12`) referenziert eine Option, die kein einziger gelockter
   Input definiert** — hoher Verdacht auf stillen Eval-Bruch seit dem letzten Input-Update (`ac7724c`).
3. **Drei konkurrierende Theming-Stacks** (Stylix fixe catppuccin-mocha-Palette, DMS-matugen
   Wallpaper-Palette mit 22+ Template-Zielen, manuelles `qt-theme.nix`), wobei `qt-theme.nix` nachweislich
   **wirkungslos** ist: Stylix' Plain-Assignment (Priorität 100) überstimmt die `mkDefault`-Werte
   (Priorität 1000) — effektiv läuft `qt5ct`+`kvantum`, nicht `gnome`/`adwaita-dark`.

Für das TRÄGE-Gefühl konkreteste Runtime-Verdächtige: Ghostty mit animiertem Custom-Shader + `background-blur = 20`
(dauerhafte GPU-Arbeit pro Frame), DMS-Bar mit CPU/Mem/Temp-Polling (externer `dgop`-Prozess alle 3 s),
Per-Frame-Audio-Visualizer, Ripple-/Scroll-/Wave-Animationen — und auf Akku zusätzlich
`batteryProfileName = "power-saver"` (CPU-Throttle per power-profiles-daemon).

Struktur: gut lesbar, Collector-Pattern (`desktop.nix`-Bundle, zwei Dateien mergen in dasselbe Modul via
import-tree) funktioniert; Auffälligkeiten: eine tote Datei (`tuigreet.nix`), ein `builtins.*`-Verstoß,
`gvfs` doppelt enabled.

## Findings

### HIGH

#### H1: `dms-settings.nix` — 457-LOC-Default-Klon mit eingebauter Versions-Drift und Doppel-Writer-Konflikt
Datei: `modules/aspects/desktop/shell/dms-settings.nix`

Beleg:
- 370 Settings-Keys, davon 192 im automatisierten Abgleich gegen die JS-Defaults
  (`SettingsSpec.js` + `SharedSettingsSpec.js` des gepinnten DMS-Revs `a609b5f999a9`) auffindbar:
  **162 exakt identisch mit dem Upstream-Default**, weitere ~14 semantisch identisch
  (`{ }` vs `{}`, `[ ]` vs `[]`, identische Listen wie `powerMenuActions`).
  → **~92 % der abgleichbaren Keys sind Upstream-Defaults.** Echte Abweichungen: ~15 Keys, u. a.
  `widgetBackgroundColor = "sch"` (Z. 10), Power-Timeouts `acMonitorTimeout/acLockTimeout 300`,
  `acSuspendTimeout 1800`, `battery*Timeout 120/120/600` (Z. 200–208), `acProfileName = "performance"`
  (Z. 204), `batteryProfileName = "power-saver"` (Z. 209), `enableU2f = true`/`u2fMode = "and"` (Z. 295),
  `lockScreenShowPowerActions`, `lockScreenPowerOffMonitorsOnLock` (Z. 284) — plus zwei echte
  Struktur-Abweichungen: `barConfigs`-Layout (Z. 351) und `appIdSubstitutions` (Z. 136).
- Zeile 454: `configVersion = 5;` — aber DMS @locked migriert intern bis **configVersion 16**
  (`SettingsStore.js` Z. 444/445: *"Dropping keys that match defaults; settings.json now stores only changed
  values"*, v13 verschiebt `brightnessDevicePins` & Co. nach `cache.json`, v16 löscht `spotlightCloseNiriOverview`).
  Der Mirror schreibt also einerseits Keys, die die v13/v16-Migration **explizit löscht**
  (`brightnessDevicePins` Z. 218, `spotlightCloseNiriOverview` Z. 160 = tote Keys), und triggert
  andererseits bei jedem DMS-Start die komplette Migrationskette 5→16 — die HM bei jedem Switch wieder
  auf v5 zurücksetzt. Permanentes Churn-Ping-Pong.
- Doppel-Writer: DMS-Home-Modul schreibt `settings.json` via `jsonFormat.generate`
  (Upstream `home.nix`: *"to be written to ~/.config/DankMaterialShell/settings.json"*), DMS-Runtime
  (`SettingsStore.js`, 768 LOC) schreibt dieselbe Datei zur Laufzeit (Migration + `stripDefaults`).

Warum wichtig: Das ist Wartbarkeitsbombe UND Startup-Kosten zugleich. Jedes DMS-Update (Input-Bump)
ändert Schema/Defaults → Mirror driftet still (fehlende neue Keys, lebende tote Keys), HM-Switch vs.
DMS-Runtime kämpfen um dieselbe Datei, und bei jedem Shell-Start läuft eine 11-Stufen-Migration.
Fix-Richtung: Datei auf die ~15 echten Abweichungen + `barConfigs` + `appIdSubstitutions` reduzieren,
`configVersion` nicht pinnen (DMS verwaltet ihn selbst). Das hätte die Datei von 457 auf ~40 LOC.

#### H2: `programs.dsearch.enable = true` — Option existiert in keinem gelockten Input (Eval-Bruch-Verdacht)
Datei: `modules/aspects/desktop/shell/dms.nix:12`

Beleg:
- `grep -rl "dsearch" DMS-Tarball@a609b5f999a9 --include="*.nix"` → **0 Treffer**. dsearch ist bei diesem
  Rev nur ein QML-interner Service (`quickshell/Services/DSearchService.qml`, testet Verfügbarkeit via
  `command -v dsearch`) — KEIN NixOS-Optionsmodul.
- Auch niri-flake@1a3b34bc, dank-greeter@334b2c93, dms-plugin-registry@90ddfd24: 0 `.nix`-Treffer.
- Im dotnix-Repo selbst definiert kein Modul `programs.dsearch` (Repo-weiter grep: einziger Treffer ist
  die setzende Zeile selbst). DMS-Master hat die Option ebenfalls nicht
  (Commit-Suche `programs.dsearch` in AvengeMedia/DankMaterialShell: 0 Commits).

Warum wichtig: Der NixOS-Modul-Parser wirft bei nicht existierenden Optionen
("The option `programs.dsearch.enable' does not exist"). Entweder evaluert das Flake seit dem letzten
Input-Update (`ac7724c chore: update flake inputs (#26)`) nicht mehr sauber, oder die Zeile ist ein totes
Relikt aus einem älteren Stand, das versehentlich im Bundle blieb. Beides ist ein Wartbarkeits-/Betriebs-
Problem und 5 Minuten vor dem nächsten Rebuild wert. (Verifikation mit `nix eval` war mir per Regel
verboten — als HardQuestion formuliert.)

#### H3: Qt-Theming dreifach gestapelt — `qt-theme.nix` nachweislich wirkungslos
Dateien: `modules/aspects/desktop/shell/qt-theme.nix`, `modules/aspects/core/stylix.nix`,
`modules/aspects/desktop/shell/dms-settings.nix` (Z. 232 ff.)

Beleg:
- `qt-theme.nix:5-6`: `platformTheme = lib.mkDefault "gnome"; style = lib.mkDefault "adwaita-dark";`
  (`mkDefault` = Priorität 1000).
- Stylix@fb28acd59 autoEnable (`core/stylix.nix`: `autoEnable = true;`), qt-Target
  (`modules/qt/nixos.nix`, Upstream): setzt `qt.platformTheme = "qt5ct"; qt.style = "kvantum";`
  als **Plain-Assignment** (Priorität 100, vgl. nixpkgs `lib/modules.nix`: Plain-Definitionen haben
  Priorität 100, `mkDefault = mkOverride 1000`). Da `services.desktopManager.gnome` nicht enabled ist,
  wählt Stylix `qtct` → `qt5ct` + `kvantum`.
- DMS spiegelt parallel `matugenTemplateQt5ct/Qt6ct = true` (dms-settings.nix Z. 236–237) — matugen
  regeneriert qt5ct/qt6ct-Farbschemata bei jedem Theme-Regen.

Warum wichtig: Die manuelle Qt-Konfiguration tut nichts (Stylix gewinnt per Priorität), erzeugt aber
Fehlvertrauen in die Datei. Gleichzeitig laufen zwei aktive Theming-Generatoren mit unterschiedlichen
Paletten-Quellen (Stylix: fixe `catppuccin-mocha.yaml`, `core/stylix.nix:9`; DMS-matugen:
Wallpaper-abgeleitet, `dms.nix:32 enableDynamicTheming` + 22 `matugenTemplate*`-Keys) plus DMS-Portal-
Sync (`syncModeWithPortal = true`). Ergebnis: drei writer für Look&Feel, Fehlerbilder („Qt-Apps falsch
gethemed") sind unauffindbar logisch. Empfehlung: Einen Stack deklarieren (vermutlich DMS-matugen, da
DMS die Bar/Shell themed), Stylix-qt-Target gezielt deaktivieren, `qt-theme.nix` löschen oder stylix-
konform machen.

### MEDIUM

#### M1: DMS-Runtime-Kosten-Cluster: Polling-Widgets, Per-Frame-Animationen, Audio-Visualizer, Wetter-Daemon
Dateien: `shell/dms-settings.nix`, `shell/dms.nix`, `shell/dms-plugins.nix`

Beleg (alles an, alles Default außer `showGpuTemp = false`):
- Bar-Widgets `showCpuUsage/showMemUsage/showCpuTemp = true` (Z. 53–55) + `dms.nix:33
  enableSystemMonitoring = true`. Upstream `DgopService.qml` Z. 19:
  `updateInterval: refCount > 0 ? (powerSaver ? 6000 : 3000) : ...` — DMS spawnt alle **3 s** den externen
  `dgop`-Prozess und parst JSON, solange die Bar sichtbar ist.
- `enableAudioWavelength = true` (`dms.nix:29`) + `audioVisualizerEnabled = true` (Z. 117):
  Audio-Visualizer in der Bar = kontinuierliche Amplituden-Sampling + Rendering, solange Audio läuft.
- `enableRippleEffects = true` (Z. 37), `waveProgressEnabled = true` (Z. 115),
  `scrollTitleEnabled = true` (Z. 116, marquee-Scrolling des Fenstertitels), `soundsEnabled = true`,
  `notificationPopupShadowEnabled = true` (Z. 281) — Material-Feedback-Animationen, einzeln harmlos,
  in Summe konstante Render-Arbeit.
- Wetter dreifach: `showWeather = true` (Z. 50) + `weatherEnabled = true` (Z. 171) +
  Plugin `dankDesktopWeather.enable = true` (`dms-plugins.nix`) — Netzwerk-Polling-Service
  (`WeatherService.qml`, `updateTimer` mit Backoff).
- `enableCalendarEvents = true` (`dms.nix:30`, khal-Integration), Clipboard-Daemon
  (`enableClipboardPaste`, `maxHistory = 25`), `dankBatteryAlerts`-Plugin.

Warum wichtig: DMS ist der Kandidat Nr. 1 für „Desktop fühlt sich träge an": eine dauerhaft laufende
Quickshell-Instanz mit 3-s-Polling, Audio-FFT, Ripple/Scroll/Wave-Animationen und Netzwerk-Wetter.
Kein Einzelteil ist ein Skandal — aber die Summe ist der Beitrag des Shells zum schlechten Gefühl.
Schnellste Probe: `showCpuUsage/showMemUsage/showCpuTemp/audioVisualizerEnabled` testweise aus →
Bar-Layout steht schon strukturell in `barConfigs` (Z. 351).

#### M2: Ghostty — animierter Custom-Shader + Blur + Transparenz = permanente GPU-Last
Datei: `modules/aspects/desktop/terminal/ghostty.nix:16-22`

Beleg:
```nix
background-blur = 20;
background-opacity = 0.98;
background-opacity-cells = true;
custom-shader = "${cursorShaders pkgs}/cursor_warp.glsl";
custom-shader-animation = true;
```
Warum wichtig: `custom-shader-animation = true` heißt: der Fragment-Shader läuft **jeden Frame**
(unbegrenzte Animations-Loop, ghostty rendert bei aktivem Shader dauerhaft neu), zusätzlich 20-px-Blur
und Opacity 0.98 auf dem Terminal-Surface. Ein sichtbares Terminal erzeugt damit konstante GPU-Compositing-
Arbeit — auf einem Wayland-Stack mit niri (GPU-Komposit-Instanz) plus DMS (eigene Quickshell-Layer) der
konkreteste Einzelposten für „fühlt sich träge an" abseits der Bar. Günstige Alternative:
`custom-shader-animation = false` (Shader nur beim Cursor-Warp-Ereignis) oder Blur senken/abschalten.

#### M3: `batteryProfileName = "power-saver"` — bewusster CPU-Throttle auf Akku
Datei: `modules/aspects/desktop/shell/dms-settings.nix:209` (+ DMS-NixOS-Modul)

Beleg: `batteryProfileName = "power-saver";` (Upstream-Default wäre `""`). DMS' NixOS-Modul enabled
standardmäßig `services.power-profiles-daemon` (Upstream `nixos.nix`: `mkDefault true`), DMS schaltet das
Profil beim Wechsel auf Akku um. `acProfileName = "performance"` (Z. 204) ist der Gegenpol am Netzteil.
Warum wichtig: „power-saver" senkt CPU-Governor/EPP → sichtbar träges UI-Feeling im Akkubetrieb. Wenn die
Trägheit vor allem mobil auftritt, ist DAS der wahrscheinlichste Verursacher — und eine bewusste
Entscheidung, kein Bug. Klären: gewollt? Dann dokumentieren; wenn nicht: `""` (DMS-Default).

#### M4: `dms.nix` mkForce-Hack auf der niri-`config.kdl` — hohe Kopplung an DMS-Internalia + builtins-Verstoß
Datei: `modules/aspects/desktop/shell/dms.nix:41-64`

Beleg:
- Z. 47: Kommentar `"# niri-flake's own config, renamed by the DMS HACK (default: \"hm\")"`;
  der Block liest `cfg.originalFileName`, `cfg.filesToInclude`, `cfg.override` und baut per
  `lib.mkForce` die niri-Haupt-Config neu, inkl. Border-Sonderfall (Z. 60: `"border {} inside an include
  is a no-op"`).
- Z. 64: `builtins.concatStringsSep` statt `lib.concatStringsSep` (Repo-Konvention „lib über builtins";
  einziger builtins-Treffer im ganzen Desktop-Aspekt).
- Z. 9: `systemd.restartIfChanged = true` — DMS-Service startet bei jeder HM-Aktivierung neu, die die
  niri/DMS-Konfig berührt (zusammen mit H1: Switch → settings.json zurückgesetzt → Migration → Restart).

Warum wichtig: Der Block ist die fragilste Stelle des Aspekts: er hängt an undokumentierten Interna des
DMS-Niri-Moduls (Dateinamen-Konvention `"hm"`, Include-Liste, Border-Semantik). Jedes DMS-Update kann ihn
leise brechen oder — schlimmer — ihn wirken lassen, ohne dass die Border-Korrektur noch stimmt.
Außerdem verstößt `builtins.*` gegen die eigene Konvention. Empfehlung: beim nächsten DMS-Bump
obligatorisch mittesten (niri parsed Config beim Start nicht aus → Fehler fällt erst zur Laufzeit auf).

### LOW

#### L1: `tuigreet.nix` ist toter Code
Datei: `modules/aspects/desktop/greeter/tuigreet.nix` (18 LOC)

Beleg: Definiert `flake.modules.nixos.tui-greeter`; Repo-weiter grep nach `tui-greeter` (außerhalb der
Datei): 0 Treffer; `desktop.nix`-Bundle importiert nur `dms-greeter`; `templates/` referenziert ihn nicht.
Warum wichtig: Zwei Greeter-Aspekte, einer aktiv — die Datei verwirrt („welcher Greeter läuft?" Antwort:
dms-greeter mit niri + Quickshell am Login-Screen, `dms-greeter.nix:7 compositor.name = "niri"`).
Löschen oder im Bundle-Kommentar auflösen.

#### L2: firefox.nix — solide strukturiert, aber Per-Page-Overhead durch 6 Extensions + ein toter Pref
Datei: `modules/aspects/desktop/apps/firefox.nix`

Beleg:
- Z. 121–128: sechs Extensions gleichzeitig: `bitwarden`, `i-dont-care-about-cookies`, `localcdn`,
  `multi-account-containers`, `private-relay`, `ublock-origin`. IDCCAC manipuliert DOM pro Seite,
  localcdn leitet CDN-Ressourcen um, multi-account-containers isoliert Kontexte — jeweils messbarer
  Page-Load/Interaktions-Overhead, kumulativ spürbar bei „Browser fühlt sich zäh an".
- Z. 70: `"media.autoplay.enabled" = false;` — dieser Pref ist seit ~Firefox 41 durch
  `media.autoplay.default` ersetzt und wirkt in modernem Firefox nicht mehr (totes Setting; prüfen, dann
  ersetzen oder löschen).
- Z. 64: `browser.urlbar.speculativeConnect.enabled = false` — bewusster Privacy-Tradeoff, kostet aber
  gefühlte Navigationsschnelligkeit (kein Preconnect mehr). Erwähnen, nicht ändern.
- Z. 110: `"sidebar.visibility" = "expand-on-hover"` — Vertikal-Tabs-Overlay, Relayout bei Hover; minimal.
Warum wichtig: Firefox ist die meistgenutzte App; wenn „der Desktop träge ist", messen Nutzer oft zuerst
den Browser. Die prefs selbst sind sauber gruppiert (Telemetry/Tracking/HTTPS/DoH) — kein Struktur-Monster
wie dms-settings.nix. Positiv: `stylix.targets.firefox.colorTheme` (Z. 140–141) läuft über Stylix-Thema,
kein Extra-Build.

#### L3: Redundanzen und Konsistenz-Kleinigkeiten
Dateien: `compositor/gnome-services.nix`, `shell/thunar.nix`, `compositor/xdg-portals.nix`,
`apps/firefox.nix`, `shell/dms-settings.nix`

Beleg:
- `services.gvfs.enable = true` doppelt: `gnome-services.nix:20` UND `thunar.nix:13` (harmlos durch
  idempotentes Enable, aber redundant).
- `xdg-portals.nix:21 xdgOpenUsePortal = true` — jeder `xdg-open` geht durch einen Portal-Roundtrip;
  spürbare ~100–300 ms Latenz beim Öffnen von Dateien/Links. Bewusste Wahl (Konsistenz im Sandbox-Kontext),
  aber ein Perceived-Perf-Posten.
- `firefox.nix:144-158`: App-Modul schreibt niri-`window-rules` (Firefox-CSD-Korrektur + PiP-Floating).
  Im Dendrite-Pattern legitim (Multi-Context-Aspekt), aber von der Datei her überraschend — wer niri-
  Regeln sucht, schaut in `compositor/`. Gilt genauso für `apps/handy.nix:31-38` (niri-Bindings für
  Handy-Toggle).
- `dms-settings.nix:8-9`: `popupTransparency`/`dockTransparency` als einzige zwei Keys mit `lib.mkDefault`
  gewrappt — in einer Datei voller unbedingter Plain-Assignments sinnlos (es gibt keinen zweiten Writer).
- `xdg.nix`: `{ } // lib.mapAttrs` — flaches Attrset, kein Konventionsverstoß; `lib.const`/`mapAttrs` sauber.
  Non-Standard-XDG-DIR `projects` zusätzlich persistiert — ok.
- Konventionen insgesamt: 19 Dateien, 1× `builtins.*` (M4), 0 eigene `mkOption`s im ganzen Aspekt
  (reiner Consumer — ok), `{ pkgs, ... }`/`inherit`-Stil konsistent, impermanence-Angaben sauber
  (`.cache/mesa_shader_cache` in `niri.nix` ist sogar eine Startup-Optimierung: Shader-Cache überlebt
  Reboots).
- Positiv fürs träge Gefühl: `blurEnabled = false` (dms-settings.nix Z. 38 — DMS-Blur aus),
  `hotkey-overlay.skip-at-startup = true` (`niri.nix:22`), `niri-unstable` mit eigenem Cachix
  (`niri.nix:8-10`) und xwayland-satellite sauber angebunden (`niri.nix:21`). niri selbst ist unauffällig:
  keine Animation-Overrides (Defaults sind kurz), `focus-follows-mouse` + `scroll-factor = 2` sind
  Verhaltens-, keine Perf-Settings.

## HardQuestions

1. **Evaluiert das Flake aktuell überhaupt?** `programs.dsearch.enable` (dms.nix:12) existiert in keinem
   gepinnten Input — falls `nixos-rebuild`/`nix flake check` heute durchläuft, definiert irgendwo ein
   Modul die Option, das ich nicht gefunden habe (dann: wo, und sollte der Setting-Wert ans tatsächliche
   dsearch-CLI durchreichen?); falls nicht, ist der nächste Rebuild kaputt und die Zeile zu löschen.
2. **Wer ist Single-Source-of-Truth fürs Theme?** DMS-matugen (Wallpaper-abgeleitete Palette, themed die
   Shell + 22 Template-Ziele) oder Stylix (fixe catppuccin-mocha-Palette, themed GTK/Qt/Firefox)?
   Aktuell laufen beide + ein wirkungsloses qt-theme.nix. Ein Stack sollte gewählt und der andere
   gezielt ausgeschaltet werden (`stylix.targets.*.enable = false` bzw. DMS-Templates reduzieren) —
   sonst sind Farb-Drifts zwischen Bar, Apps und Terminal dauerhaft unklarer Ursache.
3. **Ist die Trägheit akkubetrieben reproduzierbar?** `batteryProfileName = "power-saver"` throttelt per
   power-profiles-daemon. Falls ja: bewusste Entscheidung dokumentieren oder auf DMS-Default `""`
   zurücksetzen. Und parallel: Lohnt es, dms-settings.nix auf die ~15 echten Abweichungen zu reduzieren
   (would-be ~40 LOC statt 457) und damit die 5→16-Migrations-Churn nach jedem HM-Switch zu killen?
