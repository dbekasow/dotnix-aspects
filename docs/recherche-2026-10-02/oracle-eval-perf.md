# Orakel-Gutachten: Eval-/Rebuild-Performance — .dotnix-aspects

Oracle, 2026-10-02. Adversarial-Verifikation des Researcher-Berichts (eval-perf.md).
Messbox: gleiche Maschine, aber Last 0.6–2.0 (Researcher: 2.4–3.0), nix 2.34.8,
nixpkgs-Pin identisch (rev 3181085, via Synthetic-Consumer-Lock). Jede Zahl hier:
eigene Messung oder mit `path:line` belegter Codebefund. Repo unangetastet; alle
Synthetic-Consumers liegen unter /tmp/dotnix-oracle/ (flake reproduzierbar).

## Urteil

Die Headline des Researchers — „disko kostet +7 s pro Host-Eval" — ist ein
**Messartefakt und damit widerlegt**: Sein perfW-Baseline-Eval schlägt fehl
(`Failed assertions: The 'fileSystems' option does not specify your root file
system`, reproduziert: 3,55 s Abbruch), sein perfDX läuft vollständig durch
(10,84 s). Verglichen wurde Abbruch-vs-Erfolg. Mit sauberen Paaren (beide Seiten
mit definiertem Root-FS, interleaved 3×) liegt der disko-Effekt bei **0,0 s
(±0,4 s Rauschen)**; auch das nackte Upstream-disko-Modul ohne Device-Tree und
ein Minimal-Tree kosten nichts Messbares.

Die wahre Eval-Landschaft auf ruhiger Box: volles Host-Eval ~11 s, bare
nixosSystem ~6,4 s, dotnix-Scaffolding (import-tree + flake-parts, 141 Dateien)
+0,1 s. Der mit Abstand größte Einzelblock ist das **nixpkgs-eigene
`services.pipewire`-Modul: +3,9 s allein** (Upstream-Kosten, nicht die Library),
dazu network/network-wifi +0,9 s. stylix, home-manager, disko, impermanence,
DMS: je ~0–0,2 s; niri +0,0–0,9 s (im Rauschen, nicht +1,5 s). Die Library ist
eval-seitig sauber — Trägheitsursachen liegen woanders: DMS-Trio ohne Binary-Cache
(bei wöchentlichem Bump = quickshell+DMS+Greeter aus Source; Cache-Abwesenheit in
allen drei Flakes am gelockten Rev per grep bewiesen) und das **kaputte Template**
(crashed reproduzierbar am `myUser`/`myuser`-Case-Mismatch — wurde offenbar nie
vollständig evaluiert).

## Widerlegtes / korrigiert

1. **HIGH „disko +7 s pro Host-Eval" — WIDERLEGT.**
   Reproduktion des Researcher-Setups (/tmp/dotnix-perf/consumer-flake2, unverändert):
   - `perfW` → `error: Failed assertions: The 'fileSystems' option does not specify
     your root file system.` nach **3,55 s** (Abbruch, kein drvPath).
   - `perfDX` → drvPath nach **10,84 s** (Erfolg; disko definiert das Root-FS).
   Ursache: Nur `modules/aspects/system/disko.nix:68-69` definiert `fileSystems` im
   ganzen Aspekt-Baum — jeder Host ohne disko stirbt an der Assertion, und die
   Abbruchzeit landete als „Baseline" im Report.
   Saubare Paarmessung (Consumer /tmp/dotnix-oracle/consumer, beide Seiten erfolgreich,
   3 Runden interleaved):
   | Variante | Median | Delta |
   |---|---|---|
   | oA (perfW-Liste + statisches Root-FS) | ~11,0 s | — |
   | oB (oA + disko-Aspekt) | ~11,1 s | **±0,0 s** |
   | oG (oA + nur Upstream-disko-Modul, kein Tree) | ~11,8 s | ±0 (Rauschen) |
   | oH (oA + Upstream + Minimal-Tree, kein LUKS/btrfs/swap) | ~11,7 s | ±0 |
   Die behaupteten 10,60/11,48/11,38 s für perfDX passen zu meinen oB-Werten —
   der Aspect selbst ist eval-fast-gratis. Das „zahlt jeder nixos-rebuild"-Argument
   entfällt. HardQ-1-Gegenprobe (`dry-activate` vor/nach Entfernen) unnötig.

2. **„bare nixosSystem 3,07–3,87 s" — WIDERLEGT.** Auch das war ein fehlgeschlagener
   Eval (grub-Assertion, reproduziert). Wahres, erfolgreiches Minimal-System
   (hostPlatform + Root-FS + grub.devices): **6,0/6,7/6,7 s**. Researcher-Vergleiche
   gegen „bare" waren damit alle Abbruch-vs-Abbruch (internal konsistent, aber die
   Absolutzahl war falsch).

3. **„perfW zeigt: alles System-Andere inkl. boot/pipewire zusammen ≈ +0 s" —
   FALSCH.** System-Stack (bluetooth, boot, boot-systemd, geolocation, network,
   network-wifi, performance, pipewire, power) kostet erfolgreich evaluiert
   **+4,1 s** über leeren Host (oS ~10,5–10,9 s vs oM ~6,5 s), davon **pipewire
   allein +3,9 s** (oS3 10,5/10,5 s) und network+network-wifi +0,85 s (oS4
   7,4/7,5 s). Das Aspekt-File selbst ist trivial (system/pipewire.nix:4-32 —
   Optionen setzen, kein IFD): die Kosten sind das nixpkgs-Modul. Das ist
   Upstream, nicht Library-Verschulden — aber es ist der reale Eval-Block.

4. **MEDIUM „niri-flake ≈ +1,5 s" — NICHT REPRODUZIERBAR.** oA+niri: 10,8/11,6 s
   vs oA 10,6/10,7 s → +0,0 bis +0,9 s, innerhalb der Bandbreite; kein
   belastbarer +1,5-s-Effekt. Dafür bestätigt: dms eval ≈ +0,1 s (oD ≈ oA),
   stylix ≈ +0,2 s (oST 6,8/6,8 vs oM ~6,6), home-manager-Aspekt ≈ +0,1 s
   (oH 6,6/6,4), impermanence ≈ +0,2 s (oI ≈ oA+0,2).

5. **„quickshell.drv belegt den lokalen Build-Pfad" — ABSCHWÄCHEN.** Die
   quickshell-0.3.1.drv und dms-shell-1.7-beta.drv existieren, aber: Outputs
   fehlen (GC/nie gebaut), /nix/var/log/nix/drvs ist leer (keine lokalen
   Build-Logs), kein /run/current-system. Diese Box ist nicht das
   Ziel-Desktop-System. drv-Präsenz beweist Instantiierung, nicht lokalen Build.
   Der DMS-Local-Build bleibt plausible Hypothese für die Zielbox — Cache-losigkeit
   ist trotzdem bewiesen (s. u.), also tritt der Effekt ein, sobald dort gebaut wird.

### Bestätigt (Kurzbefunde)
- **import-tree + flake-parts ≈ 0,15–0,5 s ✓** (nun mit sauberer Methode): leerer
  dotnix-Host oM ~6,5 s vs bare ~6,4 s → Scaffolding +0,1 s. Volle Host-Eval
  9–12 s ✓ (meine Werte 10,2–11,8 s).
- **DMS ohne Binary-Cache ✓** (HardQ 2): grep über die gelockten Upstream-Flakes
  (raw.githubusercontent, revs aus flake.lock: dms a609b5f…, dms-plugins 90ddfd2…,
  dank-greeter 334b2c9…): **kein cachix/substituter/nixConfig in allen drei
  flake.nix** (dms enthält nur `substituteInPlace`-Build-Schritte). Consumer-seitig
  konfiguriert nur: niri.cachix.org (desktop/compositor/niri.nix:5-7), helix,
  llm-agents, cache.nixos.org + nix-community (core/nix-substituters.nix,
  contribuiert via `flake.modules.nixos.nix`-Merge in denselben Aspekt-Namen wie
  core/nix.nix). Nichts für DMS → Nix fragt für quickshell/DMS/Greeter keinen
  Cache an; jeder Bump = Source-Build.
- **Lock-Bloat ✓**: 58 Nodes; 2 nixpkgs (3181085 gefolgt überall; nixpkgs-stable
  cf5e765 nur im niri-Teilgraph); 6 flake-parts-Nodes; devshell a67c0f87 und
  treefmt 27b3b12a (2024er) nur unter agenix-rekey — bei der Eval dieser Flake
  nicht instantiiert, Kosten ~0, nur Bloat. Die Warnung reproduziert: `warning:
  input 'agenix' has an override for a non-existent input 'home-manager'`
  (agenix-Lock-Node hat nur nixpkgs; flake.nix-Zeile tot).
- **ISO-Pakete in parts/configuration.nix ✓** (Zeilen 53-66: getAttrFromPath auf
  `flake.nixosConfigurations.<host>.config.system.build`): `nix flake show/check`
  evaluiert iso-Hosts vollständig; Library hat 0 Hosts → heute 0 Kosten,
 _future_-Kosten real.
- **nix.nix Runtime-Tuning ✓** (core/nix.nix: auto-optimise-store=false mit
  Begründung, weekly optimise, connect-timeout 5, fallback, idle-Scheduler).
- **nix-index-database prebuilt ✓** (term/nix/nix-index-database.nix: nur Import
  des Input-HM-Moduls + comma; keine FOD/IFD lokal).
- **stylix-Details ✓** (core/stylix.nix:44 enableReleaseChecks=false; :12
  base16Scheme = pkgs.base16-schemes-Storepfad; :51-54 Wallpaper mkIf pathExists).
- **`${inputs.self}`-Pfade ✓ UND VERSCHÄRFT**: core/age-rekey.nix:8-9
  (nixos, `${inputs.self}/modules/hosts/<host>/secrets` + **ungeguardetes**
  readFile des Host-Pubkeys) und :29-31 (HM, `modules/users/<user>/secrets` +
  ungeguardetes readFile home-key.pub). certificates.nix:6 ist dagegen
  pathExists-geguardet. Über core/home-manager.nix:8-10
  (`home-manager.sharedModules = [ modules.homeManager.core ]`) zieht jeder User
  HM-core inkl. age-rekey → jeder External-Consumer mit User crasht reproduzierbar
  (Researcher-Fehlermeldung). Das Template crasht allerdings noch früher (s. HardQ 3).

## Antworten auf HardQuestions

**1. Warum steht disko im `system`-Collector statt pro Host / hinter einem Gate?**
Eval-Kosten-Argument: entfällt (0,0 s gemessen). Struktur-Argument bleibt
berechtigt: disko.nix:29-67 verdrahtet ein komplettes Layout (GPT, ESP 1G,
LUKS2+argon2id+FIDO2-Enrollment, btrfs-Subvols @root/@persist/@nix/@log/@swap,
64G-Swapfile via mkDefault, postCreateHook) in den Collector. Jeder Host, der
`system` zieht (Template myHost tut es: templates/dotnix/modules/hosts/myHost/
configuration.nix), erbt dieses Layout; abweichende Hosts müssen überschreiben,
statt ihr eigenes Layout zu deklarieren. Urteil: **umsiedeln** — Aspekt auf
Modul-Import reduzieren, Layout pro Host unter modules/hosts/<host>/ ablegen (oder
hinter `host.disko.enable`). Impact = Wartbarkeit, nicht Performance. Aufwand 2–3 h.

**2. Gibt es für dms/dms-plugins/dank-greeter einen Binary-Cache?**
**Nein, nicht für Consumer beworben** — in keiner der drei flake.nix am
gelockten Rev existiert nixConfig/substituter/cachix (grep bewiesen). Ob
AvengeMedia-CI (Workflows existieren: nix-pr-check.yml, dms-stable.yml, …)
irgendwohin pusht, konnte ich nicht abschließend prüfen — irrelevant, solange kein
Cache dem Nix-Client beworben wird: ohne substituter+key fragt Nix nicht an.
Bump-Kadenz: Lock-Revs 2026-09-27/28, Bump-Commits #25/#26 ≈ wöchentlich
(git log). Konsequenz steht: jeder DMS-Bump kompiliert quickshell (C++/Qt) +
DMS + Greeter auf der Zielbox. Verifikation auf der Zielbox nach dem nächsten
„chore: update flake inputs": `nix build --dry-run
.#nixosConfigurations.<host>.config.system.build.toplevel` — wenn quickshell/
dms-shell in der Build-Liste stehen: bestätigt. Auf THIS Box nicht verifizierbar
(keine Build-Logs, Outputs fehlen).

**3. Wurde templates/dotnix je vollständig evaluiert? Wurde widerlegt?**
**NEIN — das Template crasht reproduzierbar, und zwar früher als der Researcher
annahm:** `error: attrVals ... Did you mean myuser?` (8,8 s) — configuration.nix
sagt `members = [ "myUser" ]`, aber users/myUser/default.nix registriert
`nixos."myuser"` (lowercase). Nach einem Case-Fix folgen zwei weitere Brüche:
(a) der Host zieht `home-manager` nicht als Aspekt (Host-Module: dell-precision-5570,
system, development — kein home-manager-Aspekt), also existiert die Option
`home-manager.users` nicht; (b) danach age-rekey: `${inputs.self}`-Pfade
(core/age-rekey.nix:8-9,29-31) lösen im External-Consumer auf die LIBRARY-Flake
auf, die weder modules/users/ noch Host-Secrets hat. Urteil: **Bug, keine Absicht**
— ein Template, das public als „works" beworben wird, aber nie einmal evaluiert
wurde. Fix: Case korrigieren, home-manager-Aspekt in den Template-Host, age-rekey-
Pfade über dotnix-Host-Optionen deklarierbar machen (Default beibehalten, aber
mkIf pathExists-geguardet), und ein CI-Gate (`nix flake check` auf einen
Template-Consumer) gegen Regression.

## Empfehlungen

| Aktion | Impact | Aufwand | Prio |
|---|---|---|---|
| Template-Reparatur + Eval-Gate: `members = [ "myUser" ]` → `myuser` (templates/dotnix/modules/hosts/myHost/configuration.nix); home-manager-Aspekt in Template-Host; age-rekey-Pfade als dotnix-Host-Option mit `mkIf (pathExists …)`-Defaults statt hartem readFile (core/age-rekey.nix:8-9,29-31); CI-Job, der einen Template-Clone auswertet (`nix flake check`) | hoch — Library öffentlich nutzbar, Unblock für Consumer | 3–4 h | **1** |
| DMS-Trio aus wöchentlichem Bump-Rhythmus nehmen (dms/dms-plugins/dank-greeter nur monatlich/on-demand bumpen), da kein Binary-Cache existiert (bewiesen) — jeder Bump kompiliert quickshell+DMS+Greeter auf der Zielbox. Optional stattdessen eigenen Cachix im Owner-Repo aufsetzen und die drei Pakete dort cachen | hoch — direkster Hebel am „Rebuild fühlt sich träge an" | 0,5 h (Kadenz) bzw. 4–6 h (Cache) | **2** |
| disko-Layout aus dem Aspekt in die Host-Ebene verschieben: Aspekt behält nur `inputs.disko.nixosModules.disko` + Optionen; GPT/LUKS2/btrfs-Tree nach modules/hosts/<host>/ (Vorlage aus aktuellem disko.nix:29-67) | mittel — Wartbarkeit, mehrdeutige Host-Layouts; Eval ±0 | 2–3 h | **3** |
| Lock-/Flake-Hygiene: tote Zeile `agenix.inputs.home-manager.follows = "home-manager"` aus flake.nix entfernen (druckt bei JEDER Eval eine Warnung, reproduziert); bei nächstem agenix-rekey-Bump die 2024er devshell/treefmt-Alt-Nodes mitnehmen; 6 flake-parts-Nodes bewusst akzeptieren | gering — Warnungs-Noise, Lock-Bloat | 0,5 h | **4** |
| Eval-Realität dokumentieren und akzeptieren: Host-Eval ~11 s (davon pipewire-Modul +3,9 s, network/wifi +0,9 s — nixpkgs-Upstream); Library-Anteil (Scaffolding + Aspekte) < 1,5 s. Kein weiterer Eval-Tuning-Aufwand; Dokusatz in README genügt. ISO-Hosts (parts/configuration.nix:53-66) machen `flake check` künftig teurer — nur bei Bedarf aktivieren | gering | 0,5 h | **5** |

Nicht tun: Umbau von import-tree/flake-parts (messbar unschuldig), stylix-Targets
entschlanken (0,2 s), impermanence umziehen, niri austauschen (Eval-Rauschen),
DMS eval-seitig (0,1 s).

## Messanhang (reproduzierbar)

Synthetic-Consumer: /tmp/dotnix-oracle/consumer/flake.nix (Lock = Kopie des
Researcher-Locks, dotnix als path-Input). Befehl pro Messung:
`time nix eval .#nixosConfigurations.<V>.config.system.build.toplevel.drvPath`,
2–3 Runden interleaved. Mediane (s): bare 6,4 · oM 6,5 · oS1 6,9 · oS4 7,4 ·
oST 6,8 · oH 6,5 · oS3(pipewire) 10,5 · oS2 10,6 · oS 10,7 · oA 11,0 · oB 11,1 ·
oI 11,6 · oG 11,8 · oHmin 11,7 · oN 11,2 · oD 10,6 · oND 10,8 · oNX 10,5.
Fehlgeschlagene Researcher-Baselines (reproduziert): perfW 3,55 s (Assertion),
bare-ohne-grub 3,8 s (Assertion), Template-myHost 8,8 s (attrVals).
Nebenbeweis: `nix eval` druckt bei jeder Auswertung der Library
`warning: input 'agenix' has an override for a non-existent input 'home-manager'`.
