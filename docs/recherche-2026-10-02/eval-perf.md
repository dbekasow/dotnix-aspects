# Eval-/Rebuild-Performance — .dotnix-aspects (Researcher 8/10)

Datum: 2026-10-02 · Messbox: gleiche Maschine, Load 2.4–3.0 (Parallel-Forschung), Varianz ±1,5 s.
Alle Messungen: `timeout 120` vorangestellt, kein Build, kein Switch. Timeout nie erreicht.

## Summary

Die vermuteten Eval-Sündenbcke entlastet und belastet:
**import-tree + flake-parts über 141 Module sind mit 0,15–0,5 s vernachlässigbar**; auch
stylix (≤0,3 s), DMS (+0,1 s) und der Desktop-Stack gesamt (+0,5–2 s, v. a. niri-flake
+1,5 s) sind eval-seitig klein. Der größte messbare Eval-Block ist **disko: +7 s pro
Host-Eval** (`toplevel.drvPath` 3,4 s → 10,6–11,5 s allein durch Hinzufügen des
`disko`-Aspekts) — das zahlt jeder `nixos-rebuild` bzw. `nh os switch`, sofern der Host den
`system`-Collector zieht (Template `myHost` tut genau das). Volle Host-Eval im
Synthetic-Consumer: **9–12 s**.

Rebuild-Trägheit (nicht Eval): Der DMS/DankMaterialShell-Stack (`dms`, `dms-plugins`,
`dank-greeter`) hat **keinen Binary-Cache** (weder in ihren Flakes noch als konfigurierter
Substituter in den Aspekten — nur niri/helix/numtide/nix-community-Cachix sind gesetzt),
während die Inputs im Wochentakt gebumpt werden (Lock-Revs 2026-09-25…-28, Commits
„chore: update flake inputs“ #25/#26). Jeder DMS-Bump = quickshell + DMS + Greeter aus
Source gebaut (`/nix/store/r3fx2…-quickshell-0.3.1.drv` belegt den lokalen Build-Pfad).
Das ist der plausibelste „Rebuild fühlt sich träge an“-Hebel, zusammen mit nixpkgs =
nixpkgs-unstable.

Kein IFD gefunden; `nix flake check --no-build` der Library 2,6 s; `nix flake show` 0,35 s.
Die Alt-/Doppel-Nodes im Lock (devshell 2024 vs. 2026, treefmt-nix 2024 vs. 2026,
flake-parts ×6) werden bei der Eval dieser Flake nicht instantiiert → Eval-Kosten ~0,
nur Lock-Bloat. Effektiv **eine** nixpkgs-Instanz in der Eval (alle follows zeigen auf
rev 3181085); `nixpkgs-stable` lebt nur im niri-Teilgraph.

## Findings

### HIGH — disko-Aspekt kostet ~+7 s bei jeder Host-Eval
Datei: `modules/aspects/system/disko.nix` (importiert `inputs.disko.nixosModules.disko`
plus volles GPT/LUKS2/btrfs-Layout), Collector: `modules/aspects/system.nix`
(`nixos.system.imports = [... disko ...]`).
Messung (Synthetic-Consumer `/tmp/dotnix-perf/consumer-flake2`, gleicher nixpkgs-Pin
3181085, `toplevel.drvPath` jeweils 3×):
- `perfW` (core + system **ohne** disko/impermanence): 3,44 / 3,53 / 3,46 s
- `perfDX` (= perfW + `disko`): **10,60 / 11,48 / 11,38 s**
- Referenz: bare nixosSystem 3,07–3,87 s; `perfB` (core + voller system-Collector)
  9,1–12,7 s (Median ~10).
Warum wichtig: Das ist der mit Abstand größte einzelne Eval-Kostenblock und fällt bei
jedem `nixos-rebuild`-Eval des Hosts an — nicht nur beim Formatieren. Template `myHost`
(`templates/dotnix/modules/hosts/myHost/configuration.nix`) zieht den
`system`-Collector; Besitzer-Hosts nach demselben Muster zahlen mit.
Anmerkung: Impermanence allein war im Synthetic nicht isoliert messbar (es erzwingt die
age-Optionskette, s. u.), aber `perfW` zeigt: alles System-Andere inkl. boot/pipewire
zusammen ≈ +0 s.

### HIGH — DMS-Stack ohne Binary-Cache: Source-Rebuilds bei jedem Input-Bump
Dateien: `modules/aspects/desktop/shell/dms.nix`, `desktop/shell/dms-plugins.nix`,
`modules/aspects/desktop/greeter/dms-greeter.nix`, `flake.nix` (Inputs `dms`,
`dms-plugins`, `dank-greeter`).
Beleg: grep über die gelockten Input-Quellen (`/nix/store/2wpja…-dms-source`,
`kd6wx…-dank-greeter-source`, `qrqvf…-dms-plugins-source`) — keine
substituter/cache-Konfiguration. In den Aspekten konfiguriert nur `niri.nix:5-7`
(niri.cachix.org), `helix.nix:5-6`, `llm-agents.nix:5-6`,
`core/nix-substituters.nix` (cache.nixos.org, nix-community) — **nichts für DMS**.
`/nix/store/r3fx2sniafmj2r2h4h2q17rg3w94g1rj-quickshell-0.3.1.drv` belegt lokalen
quickshell-Build. Lock: dms/dms-plugins rev 2026-09-28, dank-greeter 2026-09-27;
Commit-Kadenz „chore: update flake inputs“ (#25, #26) ≈ wöchentlich.
Warum wichtig: Eval-messbar fast gratis (`perfE` = B + dms: 9,9–12,3 s ≈ B), aber
Build-zeitlich der Hauptverdächtige für träge Rebuilds: jeder Bump kompiliert
quickshell/DMS/Greeter neu. `nix.nix`-Settings (fallback=true etc.) machen es nicht
schneller, nur robuster.

### MEDIUM — Desktop-Stack gesamt +0,5–2 s Eval, dominiert von niri-flake
Dateien: `modules/aspects/desktop/compositor/niri.nix`, `desktop.nix`-Collector.
Messung: `perfC` (= B + fonts/gnome-services/niri/qt-theme/thunar/xdg-portals/dms)
10,8–12,6 s vs. `perfB` 9,1–12,7 s → Delta ≈ +0,5–1 s. `perfD` (= B + niri allein):
12,8 / 13,9 / 14,0 s → **niri-flake ≈ +1,5 s** (eigenes Options-/KDL-Modulsystem);
`perfE` (+ dms) und `perfF` (+ fonts/gnome/qt/thunar/portals): n. s.
Warum wichtig: Bestätigt, dass Compositor-Theming eval-seitig keine große Rolle spielt;
niri-unstable wird über cachix gecached (substituter in `niri.nix` gesetzt), ist also
Rebuild-unkritisch solange der Cache trifft.

### MEDIUM — stylix eval-seitig günstig; Targets & Delegation dokumentiert
Datei: `modules/aspects/core/stylix.nix`.
Beleg: `stylix.enableReleaseChecks = false` gesetzt; `autoEnable = true`;
base16Scheme zeigt auf `pkgs.base16-schemes`-Storepfad (YAML wird zur Eval-Zeit gelesen,
kein pro-Rebuild-Derivation); Wallpaper nur `mkIf (pathExists …)`; Fonts = normale
nixpkgs-Pakete. Eval-Messung: `perfG` (B ohne stylix) 9,8–10,6 s vs. `perfB` 9,1–10,2 s
→ **stylix ≤ 0,3 s, nicht signifikant**. NixOS-Targets des Synthetic-Hosts (20):
chromium, console, feh, fish, font-packages, fontconfig, glance, gnome,
gnome-text-editor, grub, gtk, gtksourceview, kmscon, lightdm, limine, nixos-icons,
nixvim, nvf, plymouth, qt, regreet, spicetify (u. a.).
Warum wichtig: stylix war Verdächtiger; gemessen entlastet. Theme-Derivations (gtk/qt)
entstehen build-seitig und sind im Store gecached.

### MEDIUM — `${inputs.self}`-Pfade in Aspekten lösen gegen die LIBRARY-Flake auf
Dateien: `modules/aspects/core/age-rekey.nix:8-9,30-31`
(`"${inputs.self}/modules/hosts/${hostname}/secrets/…"`, readFile hostPubkey),
`core/certificates.nix:6` (`${inputs.self}/modules/hosts/…/certificates`,
listFilesRecursive), `core/stylix.nix:53` (Wallpaper).
Beleg: Synthetic-Consumer mit HM-User crasht bewiesen mit
`error: opening file '/nix/store/…-source/modules/users/perfuser/secrets/home-key.pub':
No such file or directory` — die Library hat kein `modules/users/`; das Template
(`templates/dotnix/modules/users/myUser/secrets/` enthält nur `.gitkeep`) kann die
Pfade nicht liefern.
Warum wichtig: (a) Ein Template-Consumer kann keinen Host mit User evaluieren —
Blocker für die öffentliche Library (Kurzdoku „works for template“ widerlegt);
(b) für den Eval-Perf: readFile/listFilesRecursive pro Eval auf dem Owner-Repo
(kleine, aber echte Kosten); (c) mein HM-User-Eval-Anteil blieb deshalb unbeziffert —
der Owner zahlt zusätzlich die HM-Module-Eval seines Users.

### MEDIUM — nix-index-database: prebuilt, kein lokaler Build, triviale Eval-Kosten
Datei: `modules/aspects/term/nix/nix-index-database.nix`.
Beleg: Input-Modul (`/nix/store/a68166…-source/home-manager-module.nix`) setzt
`programs.nix-index.package = nix-index-with-db`, `home.file."$xdgCacheHome/nix-index/files".source
= packages.nix-index-database` (mkIf `symlinkToCacheHome`), comma via `home.packages`;
`generated.nix` pinnt Release `2026-09-27-083517` per fetchurl+Hash (FOD). Store-Symlink
zeigt auf `index-x86_64-linux-small` (~1,8 MB). Kein IFD, kein Large-Build — nur
Re-Download bei Pin-Bump. Impermanence-Aspect persistiert `.cache/nix-index`.
Warum wichtig: Entlastet nix-index-database als Trägheitsursache; Closure-Wachstum
bleibt im MB-Bereich.

### LOW — import-tree + flake-parts über 141 Dateien: 0,15–0,5 s, nicht der Grund
Messungen (Library-Repo selbst, `config.dotnix = { }`):
- `nix eval .#nixosConfigurations --apply builtins.attrNames` → `[ ]`, **0,175 s**
- `nix flake show` (alle Outputs inkl. `debug`, templates, devShells) → **0,35 s**
- `nix flake check --no-build` → „all checks passed“, **2,62 s**
- `nix eval .#formatter.x86_64-linux.name` → 0,30 s; devShells/packages-Eval ≤ 0,35 s
Synthetic: `perfZ` (mkFlake + `dotnix.flakeModule` = expose.nix/import-tree über
Aspekte+Parts, leerer Host) 3,35–3,54 s vs. bare nixosSystem 3,07–3,87 s →
Scaffolding ≈ **+0,3 s**.
Warum wichtig: Beantwortet die Leitfrage „147-Dateien-Eval messbar?“ mit Nein.

### LOW — `parts/configuration.nix:60`: ISO-Pakete erzwingen Voll-Eval des ISO-Hosts
Datei: `modules/parts/configuration.nix` (`perSystem.packages`, default
`host.iso.buildOutput = "images.iso-installer"`).
Beleg: `lib.getAttrFromPath (lib.splitString "." host.iso.buildOutput)
config.flake.nixosConfigurations.${hostname}.config.system.build` — Zugriff auf
`packages` (z. B. `nix flake check`, `nix flake show`) evaluiert für jeden
`iso.enable`-Host die komplette NixOS-Config inkl. `system.build.images.iso-installer`.
Im Library-Repo: keine Hosts → `packages` leer (gemessen 0,11 s). Consumer mit ISO
zahlen Doppel-Eval pro `flake check`; `nixos-rebuild` des normalen Hosts bleibt
unberührt.
Warum wichtig: Als später ISO-Hosts dazukommen, wird `nix flake check` spürbar teurer;
aktuell 0 Kosten.

### LOW — Lock-Alt-/Doppel-Nodes: keine Eval-Kosten, aber Wartungs-Bloat + Warning
Datei: `flake.lock` (58 Nodes, 21,9 KB), `flake.nix:6` (`agenix.inputs.home-manager.follows`).
Beleg: 2 nixpkgs (`nixpkgs` 2026-09-27 für alles gefolgte, `nixpkgs-stable` nur im
niri-Teilgraph, Package `niri-stable` ungenutzt); devshell 2024-10-07 (nur unter
agenix-rekey), treefmt-nix 2024-12-25 (unter agenix-rekey), flake-parts ×6 —
alle werden bei Eval dieser Flake nicht instantiiert (devshell/treefmt der Inputs
laufen nur in deren eigenen Flakes). Jede Eval printed:
`warning: input 'agenix' has an override for a non-existent input 'home-manager'`
(agenix hat den Input entfernt, `flake.nix` override-zeile ist tot).
Warum wichtig: Rebuild-Auslöser kommen nicht aus Doppel-Instanzen (eine echte
nixpkgs-Instanz), sondern aus unstable-Pins + Bump-Kadenz; totes follows-Override-Flag
sollte weg.

### LOW (positiv) — nix.nix Runtime-Tuning bereits richtig
Datei: `modules/aspects/core/nix.nix` — `auto-optimise-store = false` (Kommentar:
Dedup-Pass unterm Lock nach JEDEM Build), wöchentliches `optimise.automatic`,
`connect-timeout = 5`, `stalled-download-timeout = 20`, `fallback = true`,
`daemonCPUSchedPolicy/IOSchedClass = idle`, `keep-derivations/outputs = false`.
Warum wichtig: Nix-seitige Trägheitsursachen (Store-Optimierung blockiert Builds) sind
hier bereits adressiert; unterstützt die These, dass Rest-Trägheit aus
Source-Builds (DMS) + disko-Eval + allgemeiner unstable-Churn kommt.

## HardQuestions

1. **disko:** Warum steht disko (Layout + Script-Generierung) im allgemeinen
   `system`-Collector statt pro Host bzw. hinter einem `disko.enable`-Gate? +7 s
   Eval bei jedem `nh os switch` für einen Host, der i. d. R. nie formatiert —
   Gegenprobe auf der Ziel-Box: `time nixos-rebuild dry-activate` vor/nach Entfernen.
2. **DMS-Build-Pfad:** Gibt es für `dms`/`dms-plugins`/`dank-greeter`
   (AvengeMedia) einen Binary-Cache (GitHub-Actions-Cachix o. ä.)? Wenn nein: Wie oft
   wird `dms` gebumpt, und wie lange dauert ein quickshell+DMS-Rebuild auf der
   Ziel-Hardware? Messung nach nächstem „chore: update flake inputs“:
   `nix build --dry-run .#nixosConfigurations.<host>.config.system.build.toplevel`.
3. **Template-Eval-Bruch:** Wurde `templates/dotnix` je vollständig evaluiert
   (Host mit User)? Die `${inputs.self}`-Pfade in `age-rekey.nix`/`certificates.nix`
   können aus einem External-Consumer nicht bedient werden — Absicht (Library nur
   fürs Owner-Monorepo) oder Bug? Falls Bug: Pfade über die dotnix-Host-Options
   deklarierbar machen statt `inputs.self`-hartcodiert.
