# Research 3/10: Qualität der Aspekte core + system

Repo: `/home/denis/repositories/private/.dotnix-aspects` (flake-parts + import-tree `./modules`,
dendritic; nixpkgs = unstable). Dimension: `modules/aspects/core/*` (20 Dateien, 638 LOC) und
`modules/aspects/system/*` (11 Dateien, 346 LOC) plus die sie konsumierenden Aggregator-Dateien
(`aspects/core.nix`, `aspects/system.nix`, `aspects/bootstrap.nix`).

## Summary

Die Aspekte core+system sind überwiegend **hochwertig und performance-bewusst**: konsequentes
"enabling is importing" (keine eigenen enable-Flags, nur nixpkgs-native), saubere
Konventionen (0× `builtins.*`, 0× `//`-Merge, überall `{ pkgs, ... }`, konsequentes `inherit`),
gute Warum-Kommentare (nix.nix, network.nix, network-wifi.nix, performance.nix). Die
Impermanence ist NICHT tmpfs-basiert (btrfs-Blank-Snapshot-Rollback + `/persist`
Bind-Mounts) und verursacht daher **keinen RAM-Druck** — die Trägheit des Desktops hat ihre
Ursache wohl nicht in core/system. Die drei größten Schwächen: (1) die Hibernation-Kette ist
unvollständig (`resume_offset` fehlt systemweit, obwohl `suspend-then-hibernate` überall
aktiv ist), (2) core ist nicht standalone-fähig — age/ssh/nix-Fragmente schreiben auf das
system-Impermanence-Layout (`/persist`) und brechen ohne es, (3) die Kategorien-Taxonomie ist
brüchig: `fonts.nix`/`nix-ld.nix` liegen in `core/`, werden aber von `desktop`/`development`
konsumiert; `core.nix` importiert umgekehrt `fish`/`git`/`llm-agents` aus term/development.
Eigene `mkOption`s haben durchweg explizite `types.*`, aber **null** `description`s.

## Findings

### HIGH

#### H1: Hibernation-Kette unvollständig — `resume_offset` fehlt
Dateien: `modules/aspects/system/power.nix`, `modules/aspects/system/disko.nix`

Beleg:
- `power.nix:29`: `boot.resumeDevice = "/dev/mapper/cryptroot";` — und sonst **kein**
  resume-Parameter. `grep -rn resume modules/` liefert nur `power.nix:29` und einen
  Kommentar in `performance.nix:24`. Kein `resume_offset` im ganzen Repo.
- `disko.nix:50-54`: Swap ist ein **Swapfile auf Btrfs** (Subvol `@swap`, Mountpoint
  `/swap`, `swap.swapfile.size = lib.mkDefault "64G"`). Btrfs-Swapfiles sind nicht
  kontinguous; der Kernel braucht dafür zwingend `resume_offset=` (Datei-Extent-Offset),
  `resume=` (hier via `resumeDevice`) allein genügt für Partitionen, nicht für Swapfiles.
- `power.nix:4-7`: `HandlePowerKey = "suspend-then-hibernate"`,
  `HandleLidSwitch = "suspend-then-hibernate"`; `power.nix:21-27`:
  `AllowSuspendThenHibernate = "yes"`, `HibernateDelaySec = "30min"`;
  `power.nix:15`: `criticalPowerAction = "Hibernate"`.
- `upower.nix` (power.nix:10-16) konfiguriert battery-critical → Hibernate.

Warum wichtig: systemd prüft bei Hibernate, ob ein konsistenter resume-Pfad konfiguriert
ist (`canhibernate`); ohne `resume_offset` für ein Btrfs-Swapfile schlägt Hibernate
typischerweise fehl (Laptop bleibt nach Ablauf der 30 min einfach suspendiert — Akku
läuft leer) oder Resume nach Disk-Restart bricht die Session. Das ist der einzige
echte Funktions-/Performance-Verdächtige in dieser Dimension: jede Deckel-Zu-Bewegung
hängt an dieser Kette. Fix wäre `boot.kernelParams = [ "resume_offset=<filefrag-Wert>" ]`
bzw. NixOS-Wiki-Rezept; lsattr-Check `/swap/swapfile` (NOCOW) empfohlen — disko erzeugt
die Datei mit `btrfs filesystem mkswapfile` (disko master, `lib/types/btrfs.nix`),
was NOCOW korrekt setzt.

### MEDIUM

#### M1: core ist nicht standalone-fähig — Fragmente schreiben auf system-Layout `/persist`
Dateien: `modules/aspects/core/age.nix`, `core/ssh.nix`, `core/nix.nix`;
Konsumer: `modules/aspects/system/impermanence.nix`

Beleg:
- `age.nix:24-26`: `flake.modules.nixos.impermanence = { age.identityPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ]; }` — age (core) verweist hard auf `/persist`.
- `ssh.nix:37-44`: persistiert die SSH-Host-Keys nach `/persist` (`environment.persistence."/persist".files = [ "/etc/ssh/ssh_host_rsa_key" ... ]`); `ssh.nix:46-48` ebenso `.ssh` im HM.
- `nix.nix:52-57`: persistiert `/etc/nixos`, `/var/lib/nixos`, `/var/lib/systemd` nach `/persist`.

Warum wichtig: Das Dendritic-Collector-Muster (viele Dateien tragen Fragmente zu
`nixos.impermanence` bei — hier zusätzlich term/, desktop/, development/) ist als
Muster korrekt, aber die Zuordnung ist einseitig: core-Funktionalität (Secrets!) setzt
das system-Impermanence/Disko-Layout voraus. Host, der `core` ohne `system` importiert:
`age.identityPaths` zeigt auf nicht existierendes `/persist` → agenix-Secrets bei Boot
unlesbar → Boot-Failure. Entweder Impermanence-Fragmente nach system/ verschieben oder
die Kopplung in der Doku als verbindliche Kompositionsregel festschreiben.

#### M2: Passwordless sudo für wheel + `nouserok` = faktor-loses sudo für Unregistrierte
Dateien: `modules/aspects/core/security.nix`, `core/yubikey.nix`

Beleg:
- `security.nix:3-8`: `security.sudo.enable = lib.mkForce false;` + `security.sudo-rs = { enable = true; execWheelOnly = true; wheelNeedsPassword = false; }` — sudo ohne Passwort für die gesamte wheel-Gruppe.
- `yubikey.nix:17-25`: `security.pam.u2f.settings = { authfile = config.age.secrets.u2f.path; interactive = true; cue = true; nouserok = true; };` und `security.pam.services.sudo.u2f.enable = true;` — der zweite Faktor soll der Yubikey sein.
- `yubikey.nix:9-11`: Der Generator für die U2F-Authfile druckt **nur einen Kommentar**
  (`printf '# nix shell nixpkgs#pam_u2f -c pamu2fcfg ...'`) — d. h. bis der Besitzer
  Key-Handles manuell einträgt, ist die Authfile im Leerzustand.
- Konsistenter Besitz-Faktor-Only-Posture: `disko.nix:9` `extraFido2EnrollArgs = [ "--fido2-with-client-pin=no" ]` — auch die LUKS-Entsperrung per Touch ohne PIN.

Warum wichtig: `nouserok = true` heißt explizit: User **ohne** registrierten Key fallen
durch die U2F-Prüfung durch — und da `wheelNeedsPassword = false`, bleibt als einzige
Barriere die wheel-Mitgliedschaft. Für ein Ein-Personen-Laptop vertretbar, aber die
Komposition (core ohne yubikey-pam) ergäbe passwort- und faktor-loses sudo, und nichts
im Code erzwingt das Pairing (beide stecken nur zufällig im selben `core.nix`-Aggregat).
Zusätzlich offen: läuft pam_u2f unter sudo-rs (PAM-Implementierung weicht von sudo ab)
in der Praxis zuverlässig? `mkForce` auf `sudo.enable` (security.nix:3) ist außerdem
ohne Begründungs-Kommentar (vgl. network.nix:18, wo mkForce kommentiert ist).

#### M3: mkOption-Qualität: types konsequent, descriptions fehlen komplett; hostname-Option hat Typfehler-Default
Dateien: `modules/aspects/core/users-profile.nix`, (konsumierend)
`modules/parts/configuration.nix`

Beleg:
- `users-profile.nix:3-8`: alle vier Optionen mit explizitem `types.*` (`str`, `nullOr str`)
  — aber **keine einzige** `description`:
  ```nix
  username = lib.mkOption { type = str; };
  fullname = lib.mkOption { type = nullOr str; default = null; };
  email    = lib.mkOption { type = nullOr str; default = null; };
  theme    = lib.mkOption { type = str; default = "catppuccin-mocha"; };
  ```
- `parts/configuration.nix:33`: `hostname = lib.mkOption { type = str; default = null; }` —
  Default `null` verletzt den eigenen Typ `str` (latenter Eval-Fehler, falls der Default
  je greift; korrekt wäre `types.nullOr str` oder kein Default). Diese Option konsumieren
  core-Aspekte direkt: `age-rekey.nix:6`, `certificates.nix:5`.
- `parts/configuration.nix:7-19`: iso/host-Submodule-Optionen ebenfalls ohne descriptions.

Warum wichtig: Repo ist als wiederverwendbare Bibliothek deklariert (README "reusable
library"); Options-Dokumentation ist dort die API-Doku. Das dendritic-Eigengewand
(nixpkgs-Konvention) fordert explizite `description` pro Option — im direkten Vergleich
haben die term-Aspekte (tmux-bindings/popups) descriptions, core nicht. `theme` ist
dazu tot: deklariert und defaulted, aber nirgends konsumiert (`grep` über modules/:
nur Definition; fullname/email konsumieren git.nix:10-11, maildir.nix:20-21).

#### M4: Firewall blockt vermutlich Avahi/mDNS (`.local`) — kein 5353/UDP freigegeben
Dateien: `modules/aspects/system/network.nix`, `core/ssh.nix`

Beleg:
- `network.nix:23,28`: `nftables.enable = true; firewall.enable = true;`
- `network.nix:67-73`: `services.avahi = { enable = true; nssmdns4 = true; publish.enable = false; };` — `.local`-Auflösung ist also gewollt (via avahi-daemon).
- Einzige Port-Freigabe im gesamten Aspects-Baum: `ssh.nix:12` `networking.firewall.allowedTCPPorts = [ 22 ];`. Kein `allowedUDPPorts = [ 5353 ]` (o.ä.) irgendwo (`grep -rn "5353\|allowedUDP" modules/` → nur ssh.nix:12-Treffer für allowedTCP).

Warum wichtig: Der avahi-daemon empfängt Antworten auf UDP/5353; die nftables-Default-
Policy droppt neue eingehende Pakete außerhalb freigegebener Ports — mDNS-Antworten
matchen conntrack bei Multicast unzuverlässig. Sehr wahrscheinlicher Effekt: `.local`-
Namen (Printer, NAS, fritz.box-Nachbarn) lösen nicht auf, Anwendungen hängen in
Timeout-Schleifen — fühlt sich wie "träge" an. Muss zur Laufzeit verifiziert werden
(`resolvectl`, `avahi-browse`, Firewall-Counter); Fix: `allowedUDPPorts = [ 5353 ]`
auf LAN-Interfaces oder `firewall.trustedInterfaces`.

#### M5: Kategorien-Taxonomie brüchig — core≠core und Cross-Category-Imports
Dateien: `modules/aspects/core.nix`, `core/fonts.nix`, `core/nix-ld.nix`,
`system.nix`, `bootstrap.nix`

Beleg:
- `core/fonts.nix` wird **nicht** von `core.nix` importiert, sondern von
  `desktop.nix:8` (`fonts` in nixos.desktop-Imports). Ebenso `core/nix-ld.nix` →
  `development.nix:11`. Dateien liegen also in `core/`, gehören semantisch zu
  desktop/development.
- Umgekehrt importiert `core.nix:3-23` Module aus anderen Kategorien: `fish`, `git`
  (definiert in `term/shell/fish.nix`, `development/vcs/git.nix`) und `llm-agents`
  (`development/ai/llm-agents.nix`) — AI-Agenten-Tooling im "core" ist für eine
  minimale Basis fragwürdig.
- `core/performance.nix` (Kernel-Sysctls, zramSwap, fstrim) ist reines
  Hardware-/Runtime-Tuning, passt thematisch zu `system/` (boot/power leben dort);
  der eigene Kommentar (performance.nix:2-4) trennt es von "boot.nix" — das liegt
  in system/.
- `bootstrap.nix:3-13` ist eine Teilmenge von core+system (fish, git, locale,
  network, network-wifi, nh, nix, yubikey): drei überlappende Aggregator mit
  Drift-Risiko (Aspekt-Neuaufnahme in core muss man in bootstrap erinnern).

Warum wichtig: Die Ordner-Kategorie ist die Navigationsebene des Musters; wenn
Verzeichnis und Aggregator auseinanderfallen, greift die Wartbarkeits-Kritik (1) des
Besitzers direkt. "Trennung core vs system" ist im Kern richtig (core = cross-class
NixOS+HM Basis, system = NixOS-only Hardware), aber die Ränder sind undicht.

### LOW

#### L1: `services.timesyncd` im locale-Aspekt deplatziert
Datei: `modules/aspects/core/locale.nix`
Beleg: `locale.nix:23-24` (`# NTP time sync` / `services.timesyncd.enable = lib.mkDefault true;`) — Zeit-Synchronisierung ist kein i18n/locale-Thema. Warum wichtig: Aspekt = "single cross-cutting concern" (README); hier sind zwei concerns in einer Datei.

#### L2: `boot.tmp.cleanOnBoot` redundant zum @root-Rollback
Dateien: `modules/aspects/system/boot.nix`, `system/impermanence.nix`
Beleg: `boot.nix:19` `tmp.cleanOnBoot = true;` — aber `impermanence.nix:6-26` rollt `@root` bei jedem Boot auf den Blank-Snapshot zurück (inkl. `/tmp`); bei default-tmpfs-`/tmp` wirkt `cleanOnBoot` ohnehin nicht. Harmlos, aber toter Hebel.

#### L3: ZFS-Flags doppelt gesetzt
Dateien: `modules/aspects/system/boot.nix`, `modules/parts/configuration.nix`
Beleg: `boot.nix:21-22` (`supportedFilesystems.zfs = false; zfs.forceImportRoot = false;`) und `parts/configuration.nix:46` (`{ boot.zfs.forceImportRoot = lib.mkDefault false; }`). Duplikat; beide Ebenen ohne Verweis aufeinander.

#### L4: `theme`-Option tot
Datei: `modules/aspects/core/users-profile.nix`
Beleg: `users-profile.nix:7` deklariert `theme` mit Default `catppuccin-mocha`; Repo-weiter `grep` findet keinen Konsum (Stylix pflegt sein Theme separat über `stylix.base16Scheme`, stylix.nix:8). Entweder konsumieren oder streichen (deadnix/statix finden das nicht).

#### L5: README-Dok-Drift
Datei: `README.md`
Beleg: "See `modules/options.nix` for the host/user schema and `factories.nix` for how configurations are assembled" — beide Dateien existieren nicht; tatsächlich: `modules/parts/configuration.nix`. Für eine als wiederverwendbar beworbene Bibliothek ein echtes Onboarding-Hindernis.

#### L6: `mkForce` ohne Begründung
Dateien: `core/security.nix:3`, `system/boot-limine.nix:10`
Beleg: `security.sudo.enable = lib.mkForce false;` bzw. `style.wallpaperStyle = lib.mkForce "centered";` — im Gegensatz zu network.nix:18-20 fehlt der Warum-Kommentar; mkForce blockt Host-Overrides auf der harten Ebene (nur noch mkForce mit späterer Prio gewinnbar).

#### L7: sshd für jeden Host default-an + openssh-Doppelpaket
Dateien: `core/ssh.nix`
Beleg: `ssh.nix:4` `enable = lib.mkDefault true;` — jedes System, das core importiert, betreibt einen SSH-Server, Port 22 netzweit offen (`ssh.nix:12`); Passwort-Login aus (`ssh.nix:8`), Root nur mit Key (`ssh.nix:7` prohibit-password) — solide, aber die Default-on-Entscheidung für Laptop/ISO-Kontexte ist einen Kommentar wert. `ssh.nix:14` `environment.systemPackages = [ pkgs.openssh ]` ergänzt den Client explizit — unschädlich, aber doppelt, sofern sshd-Paket den Client ohnehin zieht ( cosmetic).

#### L8: `uutils-coreutils-noprefix` im Standard-PATH
Datei: `modules/aspects/core/system-packages.nix`
Beleg: `system-packages.nix:5` — Rust-Replacement shadowed `ls`, `cp`, `dd`, ... GNU-Semantik-Unterschiede (Flag-Abweichungen) können Skripte brechen, die GNU-Verhalten annehmen. Bewusste Wahl, aber ein bekanntes Kompatibilitätsrisiko, das im Trägheits-Debugging ( kaputte Skripte) als Störfaktor auftauchen kann.

### Positiv (explizit geprüft, damit keine Schatten-Befunde bleiben)

- **mkOption/enble-Flag-Hygiene**: keine eigenen enable-Flags in core+system —
  "enabling is importing" wird konsequent gelebt (23 `enable`-Setzer sind alle
  nixpkgs-native Optionen). Einzige mkEnableOption-Vorkommen des Repos liegen in
  term (tmux), außerhalb dieser Dimension.
- **Konventionen**: 0× `builtins.*` in core+system Aspekten; 0× `//` als Deep-Merge;
  durchweg `{ pkgs, ... }`/`{ config, lib, ... }`; `inherit` konsequent (age-rekey.nix:10-11,
  disko.nix:14, impermanence via `inherit (osConfig...)` age-rekey.nix:32); `with lib;`
  nur am Modul-Top-Level (certificates.nix:2); 17× `mkDefault` für Host-Overrides —
  sauber.
- **Impermanence**: NICHT tmpfs-basiert → **kein RAM-Druck aus dieser Ecke**.
  `impermanence.nix:6-26` rollt `@root` pro Boot auf den Blank-Snapshot zurück
  (disko `postCreateHook` disko.nix:56-61 legt ihn an); persistent ist nur `/persist`
  (Subvol), `/var/log` (Subvol @log), `/nix` (Subvol @nix). HM-Anbindung funktioniert:
  Upstreams `nixosModules.impermanence` injiziert `./home-manager.nix` selbst in
  `home-manager.sharedModules` (nix-community/impermanence@7b1d382, nixos.nix:225-231,
  verifiziert) — die vielen `home.persistence`-Fragmente sind also gedeckt, obwohl das
  HM-Modul nirgends explizit importiert wird.
- **disko.nix plausibel** (71 LOC): ESP 1G mit `umask=0077` (Zeile 35), LUKS2 + argon2id
  (Zeile 8), FIDO2 + Recovery-Enroll (10-11), `allowDiscards`/`bypassWorkqueues` (12-13),
  btrfs `compress=zstd`+`noatime` (Zeile 3), Blank-Snapshot-Hook (56-61),
  `neededForBoot` für `/persist` UND `/var/log` (68-69, korrekt für age-Secrets und
  Journal). Einzige echte Lücke ist H1 (resume_offset); Swapfile-Erzeugung durch disko
  (`btrfs filesystem mkswapfile`) setzt NOCOW korrekt.
- **certificates.nix korrekt** auf unstable: `security.pki.certificateFiles` ist dort
  additiv (`pkgs.cacert.override { extraCertificateFiles = ... }`,
  nixos/modules/security/ca.nix, verifiziert) — die Zuweisung ERSETZT also NICHT das
  Mozilla-Bundle; hinzu kommt ein robuster `pathExists`-Guard (Zeile 6), den age-rekey
  (lib.readFile, Zeile 9) analog gebrauchen könnte.
- **network.nix (84 LOC)**: NetworkManager + internes DHCP + iwd-Backend
  (network-wifi.nix:5), systemd-resolved mit Cache (39-65), DNSSEC `allow-downgrade`
  + DoT `opportunistic` (54-55, laptop-vernünftig), FallbackDNS Cloudflare (60-63),
  `nameservers = mkForce []` mit dokumentiertem Warum (18-20), avahi ohne publish
  (67-73). DNS-seitig ist für "träge Desktop" bereits vieles gerichtet — gute
  Kommentarkultur.
- **Performance-Bewusstsein**: `nix.nix:10-14` auto-optimise-store aus (begründet),
  24-30 Netz-Timeouts/fallback, 35-38 Nix-Daemon auf `idle`-Scheduler,
  `performance.nix` zram 25%/prio 100 + swappiness 10, `network-wifi.nix:15-19`
  iwlwifi-Powersave aus. Trägheitsursache liegt mit hoher Wahrscheinlichkeit außerhalb
  dieser Dimension.

## HardQuestions

1. **Hibernation**: Wurde je ein Resume aus dem Disk-Hibernate getestet? `resume_offset`
   fehlt systemweit (power.nix:29, disko.nix:53), obwohl jede Deckel-/Power-Taste auf
   `suspend-then-hibernate` mit 30-min-Delay steht — schlägt Hibernate still fehl
   (Akku-Leere im Rucksack) oder resettet der Rechner nach Hibernate die Session?
2. **Sudo-Posture**: Ist passwort-loses sudo für wheel (`wheelNeedsPassword = false`,
   security.nix:7) für User ohne registrierten U2F-Key (nouserok, yubikey.nix:21)
   bewusst in Kauf genommen — und läuft pam_u2f unter sudo-rs in der Praxis zuverlässig?
3. **Kompositions-Vertrag**: Soll `core` standalone-fähig sein? Heute brechen age/ssh/nix
   ohne das system-Impermanence-Layout (`/persist`, age.nix:25) — ist das eine
   dokumentierte Regel oder soll es ein Constraint (Assertion/Abhängigkeits-Doku) werden?
