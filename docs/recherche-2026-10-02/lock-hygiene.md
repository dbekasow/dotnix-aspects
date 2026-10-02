# Research 10/10 — Input-/Lock-Hygiene (.dotnix-aspects)

Dimension: flake.nix-Inputs, flake.lock (58 Nodes via jq), .github/workflows, git log.
Methodik: nur jq + Lesen + git; keine nix-Befehle; keine Code-Änderungen.

## Summary

Der Lock umfasst **58 Nodes (57 Input-Nodes + root), 21 direkte Inputs, 36 transitive Nodes**.
Die nixpkgs-Follows-Architektur ist intakt: **jede einzelne nixpkgs-Kante (direkt und
transitiv, alle 17 follow-Edges) landet auf Root-`nixpkgs` (unstable)** — einzige Ausnahme
ist `niri/nixpkgs-stable`, das ausschließlich den ungenutzten `niri-stable`-Zweig versorgt.
Es existieren also **nur 2 nixpkgs-Instanzen** (unstable `3181085`, 2026-09-27 + stable
`cf5e765`, nixos-26.05). Die vermeintlich „alten" Nodes (devshell 2024-10-07,
treefmt-nix 2024-12-25, flake-parts 2024-12-04, pre-commit-hooks 2025-01-03, systems
2023-04-09, fromYaml 2024-11-18, base16-vim 2024-11-28, gitignore 2024-02-28,
flake-compat 2023-10-04) sind **keine vergessenen Root-Inputs, sondern eingefrorene
Transitiv-Pins**: byte-identisch mit den flake.lock-Pins der Upstream-Flakes
(agenix-rekey, stylix, NUR). Der GitHub-Update-Bot (wöchentlich, Montag 04:00 UTC,
`update-flake-lock` + Auto-Merge) **aktualisiert nur Root-Inputs und Transitiv-Nodes,
deren Upstream-Flake selbst rolliert** (Beleg: PR #26 bewegt 19 Inputs — u.a.
`niri/niri-unstable`, `dms/dank-qml-common` — lässt aber agenix-rekeys Dev-Toolchain
unberührt; `git log -S` zeigt: devshell-Node seit Repo-Gründung auf `dd6b809`).
Hygiene-Probleme sind damit nicht Stale-Rot, sondern: **9 Repos mit Duplicate-Nodes
(30 von 57 Nodes = Duplikate), eine doppelte niri/stable-Versorgungsschiene ohne
Nutzer, zwei divergierende `dank-qml-common`-Revs im DMS-Stack, kein Binary-Cache für
den gesamten AvengeMedia-Stack** (wöchentliche Source-Rebuilds), ein persönlicher
Fork (`epireyn/niri-flake`) als Compositor-Quelle und 24 Auto-Merge-Update-Commits
in 186 Commits Gesamt-Historie. Performance-Relevanz des Locks selbst ist gering
(gleiche Revs → gleiche Store-Paths, 2 nixpkgs-Instanzen sind moderat); die spürbare
Last entsteht aus der Kombination **weekly unstable + volle Follow-Kopplung +
cache-loser DMS/greeter-Stack**.

## Findings

### [high] Duplicate-Cluster: flake-parts ×6, treefmt-nix ×4, flake-compat ×3, devshell ×2 — 9 Repos doppelt/mehrfach, 30/57 Nodes Duplikate

**Beleg** (`jq` über flake.lock):
- `hercules-ci/flake-parts` ×6 Nodes mit **3 verschiedenen Revs**:
  `flake-parts_3` (Root, `31729ca`, 2026-09-03), `flake-parts_2` (direnv-instant, `31729ca`),
  `flake-parts_4` (llm-agents, `31729ca`) — identischer Rev;
  `flake-parts` (agenix-rekey) + `flake-parts_5` (NUR) beide `205b12d` **2024-12-04**;
  `flake-parts_6` (stylix) `17c9d6c` 2026-07-01.
- `numtide/treefmt-nix` ×4: Root `treefmt` = `treefmt-nix_2` = `treefmt-nix_3` =
  `27b3b12` (2026-08-16); **veralteter** `treefmt-nix` `9e09d30` **2024-12-25**
  (nur via agenix-rekey).
- `numtide/devshell` ×2: Root → `devshell_2` `a67c0f8` 2026-09-02; alt `devshell`
  `dd6b809` **2024-10-07** (nur via agenix-rekey.devshell).
- `cachix`-Hooks ×2 unter zwei Namen: Root nutzt `git-hooks` (git-hooks.nix,
  `a0e4241` 2026-09-27); parallel schleppt agenix-rekey `pre-commit-hooks`
  (pre-commit-hooks.nix, `a5a9613` **2025-01-03**) — **dasselbe Projekt** (upstream
  umbenannt).
- `NixOS/flake-compat` ×2 (`5edf11c` 2025-12-29 via dms + git-hooks) plus
  `edolstra/flake-compat` `0f9255e` **2023-10-04** (via agenix-rekey → pre-commit-hooks).
- `nix-systems/default` ×2: `systems` **2023-04-09** (llm-agents) vs `systems_2`
  2026-03-25 (stylix).
- `AvengeMedia/dank-qml-common` ×2 mit **verschiedenen Revs** (s. DMS-Finding).
- `niri-wm/niri` ×2 und `Supreeeme/xwayland-satellite` ×2 (stable+unstable, s. niri-Finding).
- `NixOS/nixpkgs` ×2 (unstable + stable, s. niri-Finding).

**Warum wichtig:** Identische Revs kosten keinen Store-Path (gleiche narHash → gleicher
Pfad), aber der Lock wird bei 58 Nodes unlesbar, Review der wöchentlichen
Update-PRs wird größer, und jede Redundanz ist ein zusätzlicher
Divergenz-Kandidat. Die **3 alten flake-parts-Nodes (2024-12-04 / 2026-07-01) und die
alte devshell/treefmt/pre-commit-Hooks-Toolchain sind vollständig gefroren** — der Bot
bringt sie nie nach (Beleg: `git log -S '"repo": "devshell"' -- flake.lock` zeigt
devshell-Rev `dd6b809` seit Repo-Beginn unverändert über 24 Update-PRs;
agenix-rekeys Transitiv-Pins sind byte-identisch mit
`raw.githubusercontent.com/oddlama/agenix-rekey/master/flake.lock` — verifiziert:
devshell `dd6b809`, treefmt-nix `9e09d30`, flake-parts `205b12d`,
pre-commit-hooks `a5a9613`).

### [high] DMS-Substrat ohne Binary-Cache + zwei divergierende dank-qml-common-Revs

**Beleg:**
- Lock: `dms` `a609b5f` (2026-09-28), `dms-plugins` `90ddfd2` (2026-09-28),
  `dank-greeter` `334b2c9` (2026-09-27); `dms.dank-qml-common` → `660b044`
  (2026-09-28), `dank-greeter.dank-qml-common` → `a88b16e` (2026-09-22) —
  **zwei verschiedene Revs desselben QML-Fundaments in einem System** (Beleg:
  PR #26-Bullets „Updated input 'dms/dank-qml-common' … 660b044" und
  „dank-greeter/dank-qml-common … a88b16e" — sie wandern wöchentlich getrennt).
- Nutzung: `modules/aspects/desktop/shell/dms.nix` importiert
  `inputs.dms.nixosModules.dank-material-shell` + `dms.homeModules.dank-material-shell`
  + `dms.homeModules.niri`; `dms-plugins.nix` importiert
  `dms-plugins.homeModules.default` (6 Plugins enabled);
  `dms-greeter.nix` importiert `dank-greeter.nixosModules.default`
  (quickshell-Greeter, `quickshell.package = pkgs.quickshell` — Greeter nutzt
  nixpkgs-quickshell, während der dms-Flake seine eigene Quickshell-Basis baut).
- Cache-Situation: Für helix (`helix.cachix.org`), niri (`niri.cachix.org`),
  numtide (`cache.numtide.com`), nix-community sind Substituter konfiguriert
  (Beleg: `modules/.../helix.nix:5`, `compositor/niri.nix:6`,
  `development/ai/llm-agents.nix:5`, `core/nix-substituters.nix`).
  **Für AvengeMedia (dms, dms-plugins, dank-greeter) existiert kein Substituter-Eintrag
  in irgendeinem Modul** → bei jedem wöchentlichen nixpkgs-Bump (alle 4 folgen Root)
  lokale Source-Rebuilds der kompletten Quickshell-Stacks (Shell + Greeter + Plugins).

**Warum wichtig:** Das ist der konkrete „träge"-Mechanismus bei Updates: wöchentliche
unstable-Bumps invalidieren die gecachten Fremd-Pakete (helix/niri/numtide haben
Caches), aber der AvengeMedia-Stack wird **jede Woche lokal aus Source gebaut**
(Quickshell/C++/QML-Kompilierung). Dazu divergiert dank-qml-common zwischen dms und
greeter — Greeter- und Shell-QML-Basis können eine Woche auseinanderlaufen
(Inkonsistenz-Risiko bei DMS-Updates).

### [high] niri-Versorgungsschiene: Fork als Quelle + komplette ungenutzte stable-Schiene im Lock

**Beleg:**
- `niri.url = "github:epireyn/niri-flake"` — **persönlicher Fork** (GitHub-API:
  `epireyn/niri-flake` → `fork=true`, `parent=sodiboo/niri-flake`). Aktuell ist der
  Fork synced: Lock-Rev `1a3b34b` (2026-09-28) existiert im Upstream
  `sodiboo/niri-flake` (API-Commit-Lookup bestätigt), Fork gepusht 2026-10-02.
- Lock führt **beide niri-Varianten** (`niri-stable` v26.04 `8ed0da4` 2026-04-25,
  `niri-unstable` `1f03391` 2026-09-25), **beide xwayland-satellite-Varianten**
  (stable `8d135d3`, unstable `63cdf17`) und `nixpkgs-stable` (nixos-26.05, `cf5e765`).
- Genutzt wird laut `modules/aspects/desktop/compositor/niri.nix` **nur unstable**:
  `programs.niri.package = pkgs.niri-unstable` und
  `xwayland-satellite.path = pkgs.xwayland-satellite-unstable`.
- Der Bot aktualisiert trotzdem wöchentlich `niri/nixpkgs-stable` und
  `niri/xwayland-satellite-unstable` etc. (Beleg: PR #26-Bullets „Updated input
  'niri/nixpkgs-stable' … → cf5e765 (2026-09-27)", „niri/niri-unstable …",
  „niri/xwayland-satellite-unstable …").

**Warum wichtig:** Drei Nodes (niri-stable, xwayland-satellite-stable, nixpkgs-stable)
existieren ausschließlich für eine ungenutzte Stable-Variante und erzeugen trotzdem
wöchentlichen Lock-Churn (nixpkgs-stable ist ein voller nixpkgs-Rev, der mit
nirgends gebaut wird — Evaluation bleibt zwar lazy, aber die Lock-Diffs wachsen
sinnlos). Der Fork als einzige Compositor-Quelle ist ein Verfügbarkeitsrisiko, solange
kein Grund dokumentiert ist (derzeit inhaltlich identisch mit Upstream — warum nicht
`sodiboo` direkt?).

### [medium] Unstable als Daily-Driver: wöchentliche Auto-Merge-Bumps, 19 Inputs pro Welle, 13 % der Historie sind Update-Merges

**Beleg:**
- `flake.nix:3`: `nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable"` — der
  unstable-Kanal (nicht master; hydra-vorgetestet, aber brechen kann er trotzdem).
- `.github/workflows/flake-update.yml`: Cron `0 4 * * 1` (jeden Montag 04:00 UTC),
  `DeterminateSystems/update-flake-lock`, danach
  `gh pr merge --auto --squash` — **Auto-Merge sobald flake-check grün ist**.
  flake-check.yml läuft `nix flake check` (treefmt, deadnix, statix, typos, commitizen)
  — evaluiert also baut aber keine Closures: Funktionsbrüche, die nur beim
  eigentlichen Build/Switch auftreten, sieht die CI nicht.
- Git-Log: **24 `chore: update flake inputs`-Commits von #5 (2026-05-11) bis #26
  (2026-09-28)**, durchgehend wöchentlich, in 186 Commits Gesamt-Historie.
- PR #26 bewegt **19 Inputs gleichzeitig** (u.a. nixpkgs, home-manager, stylix, NUR,
  dms, dank-greeter, dms-plugins, niri, llm-agents, agenix, git-hooks,
  nix-index-database, direnv-instant + 6 transitive). nixpkgs-Sprünge:
  `c800737` (2026-09-19) → `3181085` (2026-09-27), davor Woche für Woche.

**Warum wichtig:** Da **alles** (home-manager, helix, dms/greeter/plugins, stylix,
NUR, niri-unstable-Build, llm-agents, agenix, …) auf Root-unstable folgt, ist jede
Montags-Welle potenziell ein Full-Rebuild des Desktop-Stacks. Der Vorteil der
Follow-Architektur (eine nixpkgs-Instanz, kein Version-Mix) kippt hier in seinen
Nachteil: kein selektives Pinning einzelner Substrate möglich, ohne die Follows
aufzubrechen. home-manager@unstable + nixpkgs@unstable ist das empfohlene Pairing —
Kopplung selbst OK, Frequenz + fehlender AvengeMedia-Cache machen's teuer.

### [medium] Follows-Lücken bei Nicht-nixpkgs-Transitiven — Stylix und NUR evaluieren gegen fremde flake-parts-Versionen

**Beleg:** flake.nix deklariert follows nur für `nixpkgs` (und `home-manager` bei
agenix/impermanence, `nur` bei stylix). Nicht gefolgt werden die flake-parts-Inputs
von stylix und NUR:
- `stylix.flake-parts` → `flake-parts_6` (2026-07-01, eigenständig),
  `stylix.systems` → `systems_2`, `stylix.flake-compat`/tinted-Repo-Kette → eigene
  Pins (fromYaml 2024-11-18, base16-vim 2024-11-28, tinted-kitty 2025-01-01 —
  stylix-upstream-Pins, bewusst).
- `nur.flake-parts` → `flake-parts_5` (2024-12-04).
- agenix-rekey bringt unfollowbar seine komplette Dev-Toolchain mit (devshell,
  treefmt-nix, pre-commit-hooks, flake-parts — die 2024/2025-Relikte aus dem
  Duplicate-Finding); einzige Follow-Lücke mit `nixpkgs-lib`-Risiko:
  `flake-parts.nixpkgs-lib` folgt `["agenix-rekey","nixpkgs"]` → Root-unstable
  **2026-09-27 füttert flake-parts-Code von 2024-12-04** mit aktuellem
  nixpkgs-lib (gleiche Kante gilt für `flake-parts_5`/NUR).

**Warum wichtig:** Die evaluierte Komponente ist stylixs/NURs Bibliotheks-Import —
ob deren flake-parts-Module im Baum dieses Repos evaluieren, lässt sich ohne
nix-eval nicht final klären (vermutlich ja bei stylix, da Stylix-Module
flake-parts-Lib verwenden). Latentes Risiko: altes flake-parts (Dez 2024) +
sept. 2026 nixpkgs-lib ist ein ungetestetes Pairing; der wöchentliche Bot verschiebt
nixpkgs-lib weiter unter dem gefrorenen flake-parts. Follow-Lücken sind außerdem
der Grund, warum der Lock auf 58 Nodes aufgebläht ist statt ~30.

### [low] Alte Daten im Lock sind Upstream-Pins, kein Root-Versäumnis — aber sie dominieren den „Stale"-Eindruck

**Beleg (vollständige Zuordnung der 32 Nodes älter als 2026-09):**
- `systems` 2023-04-09 ← llm-agents.systems; `flake-compat` 2023-10-04 ←
  agenix-rekey → pre-commit-hooks; `gitignore` 2024-02-28 ← pre-commit-hooks;
  `devshell` 2024-10-07 ← agenix-rekey; `fromYaml` 2024-11-18 ← stylix → base16;
  `base16-vim` 2024-11-28 ← stylix; `flake-parts`+`flake-parts_5` 2024-12-04 ←
  agenix-rekey/NUR; `treefmt-nix` 2024-12-25 ← agenix-rekey; `tinted-kitty`
  2025-01-01 + `pre-commit-hooks` 2025-01-03 ← stylix/agenix-rekey; `base16`
  2025-08-21, `base16-fish` 2025-12-15, `flake-compat_2/_3` 2025-12-29 (dms,
  git-hooks); `impermanence` 2026-01-27, `agenix-rekey` 2026-03-26 (upstream seit
  März ohne Commits), `systems_2` 2026-03-25, `rust-overlay` 2026-04-05 (helix-Upstream-Pin),
  `gnome-shell` 2026-04-14, `base16-helix` 2026-04-21, `niri-stable` 2026-04-25,
  `flake-parts_6` 2026-07-01, `firefox-gnome-theme` 2026-07-09,
  `xwayland-satellite-stable` 2026-07-22, `helix` 2026-07-23, `tinted-zed`/`tinted-tmux`
  2026-07-26, `tinted-schemes` 2026-07-27, `treefmt`/`treefmt-nix_2`/`treefmt-nix_3`
  2026-08-16, `devshell_2` 2026-09-02, … 25 Nodes datiert 2026-09 (frisch).
- Statisik: 25/57 Nodes 2026-09 (frisch), 32 älter — davon der überwiegende Teil
  Transitiv-Pins von agenix-rekey/stylix/helix-Upstream-Locks (verifiziert für
  agenix-rekey durch Abgleich mit dessen Upstream-flake.lock).

**Warum wichtig:** Klarheit fürs Refactoring: Das Lock zu „säubern" heißt nicht
`nix flake update` (das bringt genau die gefrorenen Transitiven NICHT nach —
Beleg: 24 wöchentliche Updates haben devshell/dd6b809 nie bewegt), sondern
entweder **follows nachziehen** (agenix-rekey.inputs.*.follows, stylix,
nur) oder die Duplikate bewusst akzeptieren. Systems 2023 ist harmlos (statische
Systemliste). Uncommitted `M modules/aspects/term/shell-ux/sesh.nix` (User-Arbeit)
bleibt unberührt.

## Konsequenz-Abschätzung (Flohzähl → Aufwand)

- **Lock-Node-Zahl 58** per se → keine Eval-/Store-Kosten (Lock ist Metadaten;
  identische Revs deduplizieren im Store automatisch).
- **2 nixpkgs-Instanzen** (unstable + stable) → moderat; stable wird nicht gebaut
  (niri-stable ungenutzt) und trägt nur als Lock-Eintrag + wöchentlicher Churn.
- **Eval-Zeit**: getrieben von nixpkgs-Instanzen (2, OK) und Modul-Importtiefe
  (stylix mit 10 tinted/base16-Daten-Repos als Einzelpakete). Kein Messpunkt ohne
  nix-Befehle — hier nur Mechanismus benannt.
- **Store-Größe**: relevante Divergenzen nur bei **gebauten** Varianten:
  dank-qml-common ×2 (divergente Revs, beide im DMS-/Greeter-Umfeld), sonst
  dedupliziert gleiche Revs. Kein Multi-nixpkgs-Store-Blowup.
- **Rebuild-Auslöser**: wöchentlicher Cron + Auto-Merge (Beleg: workflow +
  24 Commits); jede Welle berührt ~19 Inputs (PR #26). Cache-Deckung: helix, niri,
  numtide, nix-community gedeckt; **AvengeMedia-Stack (dms, greeter, plugins) nicht**
  → wöchentliche lokale Source-Rebuilds des Desktop-Stacks = spürbare Update-Last.

## HardQuestions

1. **Follows-Strategie für Transitiven:** Sollen die gefrorenen agenix-rekey-/
   NUR-/stylix-Transitiven (devshell 2024-10-07, treefmt-nix 2024-12-25,
   pre-commit-hooks 2025-01-03, flake-parts 2024-12-04 ×2, systems 2023-04-09)
   per follows auf die frischen Root-Inputs kollabiert werden
   (`agenix-rekey.inputs.devshell.follows = "devshell"` etc.) — Reduktion von 58
   auf ~30 Nodes und eine flake-parts-Version — oder bewusst Upstream-Pins
   respektiert werden (Reproduzierbarkeit von agenix-rekey vs. eine
   flake-parts-Lib für alle)? Die Mischform „altes flake-parts frisst neues
   nixpkgs-lib" (Follow-Kante existiert bereits!) ist die schlechteste Option.
2. **niri-Architektur:** Ist `epireyn/niri-flake` (Fork, aktuell synced mit
   sodiboo) eine bewusste Entscheidung, und wenn ja, warum nicht dokumentiert?
   Und: Rutscht die ungenutzte stable-Schiene (niri-stable + xwayland-satellite-stable
   + nixpkgs-stable, wöchentlich vom Bot gepflegt) aus dem Lock, oder ist ein
   Stable-Fallback als Rollback-Pfad geplant?
3. **Update-Kadenz vs. fehlender AvengeMedia-Cache:** Weekly unstable + Auto-Merge
   heißt: jede Woche Source-Build von dms + dank-greeter + dms-plugins auf der
   Workstation (kein Substituter, Beleg s.o.). Options: eigener Cache
   (cachix/devenv-cache), Kadenz auf 2–4 Wochen reduzieren, oder
   AvengeMedia-Stack auf nixos-release pinnen und nur selektiv unstable fahren?
   Was ist die bewusste Abwägung?
