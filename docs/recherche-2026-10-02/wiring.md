# Research 1/10 — Flake-Wiring & Boilerplate (.dotnix-aspects)

## Summary

Repo ist eine Aspekt-Bibliothek, KEINE Host-Konfiguration: `config.dotnix` (Host-Registry-Option, `modules/parts/configuration.nix:24-28`) ist im Bibliotheks-Repo leer, d. h. `nixosConfigurations`, ISO-`packages` etc. sind hier triviale Leerwerte. Hosts und User leben im Konsumenten-Repo (Schema sichtbar in `templates/dotnix/**`). Kern-Wiring: `flake.nix:70` = `mkFlake { inherit inputs; } (inputs.import-tree ./modules)` — 141 .nix-Dateien unter `modules/` (132 Aspekte + 8 parts + expose.nix) werden als flake-parts-Module geladen. Der Export an Konsumenten läuft über `modules/expose.nix:16`: `flake.flakeModule.imports = wrapMods (import-tree aspects + parts)` — d. h. Konsumenten bekommen **auch die komplette Dev-Tooling-Parts** (devshell, treefmt, pre-commit, templates, `debug = mkDefault true`) mit. Alle 21 Inputs sind referenziert, keiner ist tot. flake.lock enthält 3 verschiedene flake-parts-Revisionen (6 Lock-Nodes); die uralte (2024-12-04, rev `205b12d8b7cd`) ziehen **agenix-rekey und NUR** über ihre Upstream-Lockfiles. CI (`nix flake check`) evaluiert nur die Bibliothek, hat keinerlei eigene `checks`, und der Kommentar „covers: treefmt, … commitizen" stimmt nicht — Hooks laufen nur lokal via prek, nicht in CI.

Beantwortung der Leitfragen:

- **Wie entsteht nixosConfigurations?** `modules/parts/configuration.nix:37-49`: `lib.mapAttrs` über `config.dotnix` — Option `dotnix = attrsOf hostSubModule` (Zeile 24-28), `hostSubModule = submoduleWith { specialArgs.nixos = flake.modules.nixos; }` (Zeile 11-21). Pro Host: `inputs.nixpkgs.lib.nixosSystem { system; modules = host.modules ++ (attrVals host.members modules.nixos) ++ [stateVersion-Default "26.11", { dotnix = { inherit hostname host; }; }, { networking.hostName = hostname; }, zfs-Default, modules.nixos.dotnix] }`. `modules.nixos.dotnix` (Zeile 30-34) definiert die NixOS-seitigen Optionen `dotnix.hostname`/`dotnix.host`, über die Aspekte User/Members lesen (z. B. `core/users.nix:6` `config.dotnix.host.members`). Upstream-Typ `flake.nixosConfigurations = lazyAttrsOf raw` (flake-parts `modules/nixosConfigurations.nix`) → lazy pro Hostname.
- **Zeile 60:** `perSystem.packages."<hostname>-iso" = lib.getAttrFromPath (splitString "." host.iso.buildOutput) config.flake.nixosConfigurations.${hostname}.config.system.build`. Erzwingt für ISO-Hosts die **vollständige NixOS-Evaluation** des Hosts (`config.*`-Merge inkl. home-manager/stylix/niri), sobald das `packages`-Output angefasst wird (`nix flake check/show/build .#<host>-iso`). `getAttrFromPath` selbst ist lazy (nur der Pfad `images.iso-installer` wird forciert), aber `.config` auf `nixosConfigurations.<host>` = kompletter Modul-Merge. Kosten hier: **null** (kein Host registriert); im Konsumenten-Repo: ein zweiter voller Eval-Pfad zusätzlich zu toplevel. Default `buildOutput = "images.iso-installer"` (Zeile 8) zeigt auf `system.build.images.iso-installer`, das **im Repo nichts bereitstellt** (grep: einzige Erwähnung ist der Default) — Konvention, die der Konsument liefern muss.
- **Hosts/User-Definition:** Konsumenten-Repo. `templates/dotnix/modules/hosts/myHost/configuration.nix` setzt `dotnix.myHost = { nixos, ... }: { modules = with nixos; [dell-precision-5570, system, development]; members = ["myUser"]; }`; `templates/dotnix/modules/users/myUser/default.nix` registriert `flake.modules.{nixos,homeManager,generic}."myuser"`. Importkette: Konsumenten-`flake.nix` (import-tree ./modules) → `modules/parts.nix:2` `imports = [ inputs.dotnix.flakeModule ]` → Bibliotheks-`expose.nix` wrappt import-tree über `${self}/modules/aspects` + `${self}/modules/parts`. Leaf-Aspekte registrieren sich als `flake.modules.<class>.<name>`; Klassen-Kollektoren (`core.nix`, `system.nix`, `terminal.nix`, `desktop.nix`, `development.nix`, `bootstrap.nix`) bündeln sie zu Aggregaten; `core/home-manager.nix:9` injiziert `home-manager.sharedModules = [ modules.homeManager.core ]` für jeden User automatisch.
- **Outputs:** `devshells.default` (parts/devshell.nix), `formatter` = treefmt-Wrapper (parts/treefmt.nix:16), `flake.templates.default` (parts/templates.nix), `perSystem.packages."<host>-iso"` (parts/configuration.nix:55-60, hier leer), `flake.flakeModule` + `flake.modules.{nixos,homeManager,generic}` (expose.nix + Aspekte), `systems`/`debug`-Config (parts/flake-parts.nix), agenix-rekey-Optionen (parts/age.nix). **Kein** `checks`-Output, **kein** `apps`, keine `nixosModules`/`homeModules`-Outputs.
- **Input-Anbindung:** alle 5 verdächtigen Inputs leben: devshell (parts/devshell.nix:2), treefmt (parts/treefmt.nix:2), git-hooks (parts/pre-commit.nix:2), direnv-instant (aspects/term/shell-ux/direnv.nix:3), llm-agents (aspects/development/ai/llm-agents.nix). Vollständige Inputs-Referenzkarte per grep: alle 21 Root-Inputs min. 1× referenziert. `flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs"` (flake.nix:42) ist neutral — nixpkgs ist eh im Graph, kein Extra-Fetch.
- **CI:** `flake-check.yml`: push/PR → DeterminateSystems-Installer + flake-checker-action (fail-mode) + `nix flake check`. `flake-update.yml`: wöchentlich (Mo 04:00 UTC) `update-flake-lock` → PR + Auto-Merge (squash), sobald check grün.
- **flake-parts 6× im Lock:** Nodes `flake-parts` + `flake-parts_5` = rev `205b12d8b7cd` (**2024-12-04**) — gezogen von **agenix-rekey** und **NUR** via deren eigene Lockfiles; das Repo hat nur `agenix-rekey.inputs.nixpkgs.follows` / `nur.inputs.nixpkgs.follows` (flake.nix:8-9, 45-46), aber KEIN follows auf deren transitive flake-parts. `flake-parts_6` (rev `17c9d6cdfc60`, 2026-07-01) = stylix-Pin. Root + direnv-instant + llm-agents teilen sich `flake-parts_3` (rev `31729ca8cbdb`, 2026-09-03). Die alte flake-parts wertet via Follows-Kette `['agenix-rekey','nixpkgs']` gegen aktuelles nixpkgs-lib (2026-09-27). Effekt: 3 flake-parts-Quellbäume im Eval-Graph + Kompatibilitätsrisiko, aber KEIN Laufzeit-Performancefaktor.

Uncommitted `M modules/aspects/term/shell-ux/sesh.nix` zur Kenntnis genommen, unangetastet.

## Findings

### HIGH — `flake.flakeModule` exportiert die komplette Dev-Tooling-Parts an jeden Konsumenten

Dateien: `modules/expose.nix:16-23`, `modules/parts/{devshell,treefmt,pre-commit,flake-parts,templates}.nix`, `templates/dotnix/modules/parts.nix:2`

Beleg: expose.nix addiert beide Pfade:
```nix
(i: i.addPath "${modules}/aspects")
(i: i.addPath "${modules}/parts")
```
Template-Konsument importiert nur `inputs.dotnix.flakeModule` — bekommt damit STILLSCHWEIGEND: die Bibliotheks-Devshell inkl. 16 Paketen (devshell.nix:12-36), treefmt-Einstellungen inkl. `formatter`-Output (treefmt.nix:16-18), pre-commit-Hooks (commitizen, typos, prek — pre-commit.nix:6-17), `systems = mkDefault ["x86_64-linux"]` und `debug = mkDefault true` (flake-parts.nix:4-5) sowie `flake.templates.default` (templates.nix:2-7), was ein eigenes `templates.default` des Konsumenten kollidieren lässt.

Warum wichtig: Jede Änderung an Bibliotheks-ToolingDefaults zwingt sich in jedes Konsumenten-Repo (Wartbarkeit); `debug = true` zusätzlich ein echter Eval-Kostenfaktor (siehe nächstes Finding). `mkDefault` erlaubt Überschreiben, aber der Default-Zustand ist Injektion, nicht Opt-in.

### HIGH — `debug = mkDefault true` kostet auf jedem `nix flake check/show` im Konsumenten

Dateien: `modules/parts/flake-parts.nix:5`, belegt gegen flake-parts `modules/debug.nix` (Upstream, verifiziert)

Beleg:
```nix
debug = lib.mkDefault true;
```
flake-parts debug.nix: `config = mkIf config.debug { flake.debug = mkDebugConfig {...}; allSystems = ...; }` mit `mkDebugConfig = config // { inherit config; inherit options; inherit extendModules; }` — d. h. `flake.debug` forciert die **gesamte Optionen-Struktur** des kompletten flake-parts-Evals. `nix flake show/check` evaluiert diesen Output mit. Upstream-Default ist `false`; die Bibliothek schaltet es für sich UND alle Konsumenten an.

Warum wichtig: Im Konsumenten-Repo (Desktop-Config mit echten Hosts, home-manager, stylix) macht das jeden `flake check`/`flake show`/`nix repl`-angrenzenden Eval messbar teurer — ohne dass der Nutzer es je angefragt hat. Direkter Beitrag zum „träge"-Gefühl bei allen flake-Operationen. (Runtime-Performance des Desktops erklärt das nicht — aber Eval-Latenz schon.)

### MEDIUM — README dokumentiert Phantom-Dateien und falsche Factory-Semantik

Dateien: `README.md:21,46`

Beleg: „See `modules/options.nix` … and `factories.nix`" — **keine** dieser Dateien existiert (find über das ganze Repo, 2026-10-02). Und: „`factories.nix` iterates over `dotnix` and produces `nixosConfigurations`, injecting `core` modules and host metadata automatically" — `modules/parts/configuration.nix:37-49` injiziert KEIN core-Modul (nur stateVersion/hostname/zfs-Default/dotnix-Metadaten), und das Template-Host-Beispiel (`templates/dotnix/modules/hosts/myHost/configuration.nix:4-8`) importiert core auch nicht.

Warum wichtig: Dokumentations-Drift verwirrt Konsumenten und zukünftige Maintainer; die beschriebene „Core-Injektion" ist die zentrale Design-Annahme der Doku, existiert aber im Code nicht (offen, ob Doku oder Code falsch — s. HardQuestions).

### MEDIUM — Wiring-Schicht hat null `checks`; CI-Kommentar behauptet Hook-Coverage, die nicht existiert

Dateien: `.github/workflows/flake-check.yml:26-27`, `modules/parts/*` (grep nach `checks` = leer), belegt gegen git-hooks.nix Upstream (`modules/pre-commit.nix` — definiert settings, KEIN checks-Output)

Beleg:
```yaml
- run: nix flake check --accept-flake-config
  # covers: treefmt, deadnix, statix, typos, commitizen, detect-private-keys
```
`nix flake check` baut nur `checks.*` (keines definiert) und evaluiert den Rest; die prek-Hooks laufen ausschließlich lokal in der Devshell (pre-commit.nix:14-17 `devshell.startup.pre-commit.text = pre-commit.installationScript`). Das exportierte `flake.flakeModule` wird in der eigenen CI nie in ein Modul-Merge importiert — Brüche des Exports bemerkt erst das Konsumenten-Repo.

Warum wichtig: Eine Bibliothek mit 132 Aspekten hat keinen einzigen automatisierten Evaluations-/Merge-Test des eigenen öffentlichen API-Vertrags. Wartbarkeitsrisiko Nr. 1 im Wiring-Teil; CI-Kommentar vermittelt falsche Sicherheit.

### MEDIUM — Drei flake-parts-Revisionen im Lock; 2024-12-04-Node via agenix-rekey + NUR

Dateien: `flake.lock` (Nodes `flake-parts`, `flake-parts_5` rev `205b12d8b7cd` lastModified `1733312601` = 2024-12-04), `flake.nix:8-9,45-46`

Beleg (Lock-Analyse): `agenix-rekey` → Node `flake-parts` (205b12d8b7cd), `nur` → Node `flake-parts_5` (identischer Rev); `stylix` → `flake-parts_6` (17c9d6cdfc60, 2026-07-01); Root + direnv-instant + llm-agents → `flake-parts_3` (31729ca8cbdb, 2026-09-03). flake.nix setzt für agenix-rekey/nur nur `inputs.nixpkgs.follows`, kein `inputs.flake-parts.follows`.

Warum wichtig: 3 flake-parts-Quellbäume im Eval-Graph; agenix-rekeys flakeModule (via parts/age.nix:2 tatsächlich importiert) stammt aus einem Flake, der gegen flake-parts 2024-12 gebaut ist, aber gegen nixpkgs-lib 2026-09 evaluiert — Kompatibilitätsrisiko bei jedem nixpkgs-Update. Lock-Hygiene, kein Laufzeit-Faktor. Behebung wäre je ein follows-Eintrag, mit dem Risiko, Upstream-Pins zu überstimmen (Urteilssache, s. HardQuestions).

### MEDIUM — Versteckte Konsumenten-Pfad-Konventionen (wallpaper, secrets, certificates, iso-installer)

Dateien: `modules/aspects/core/stylix.nix:49-53`, `modules/aspects/core/age-rekey.nix:6`, `modules/aspects/core/certificates.nix:5`, `modules/parts/configuration.nix:8`

Beleg:
```nix
stylix.image = … "${inputs.self}/modules/users/${config.home.username}/assets/wallpaper.png"
secretsDir = "${inputs.self}/modules/hosts/${config.dotnix.hostname}/secrets"
certDir = "${inputs.self}/modules/hosts/${config.dotnix.hostname}/certificates"
buildOutput = … default "images.iso-installer";   # nichts im Repo stellt das bereit
```
(`inputs.self` resolves dabei dank expose.nix:9 Merge-Reihenfolge `dotnixInputs // args.inputs` auf das KONSUMENTEN-self — gewollt, aber nirgends dokumentiert; das Template enthält kein `modules/users/myUser/assets/` und keinen ISO-Aspekt.)

Warum wichtig: Der öffentliche API-Vertrag der Bibliothek besteht aus undokumentierten Pfad-Konventionen im Konsumenten-Layout; Ausfallbilder/secrets verschwinden stumm (`mkIf pathExists` / leere Verzeichnisse), statt konfigurierbarer Optionen. Wartbarkeit + Erster-Kontakt-Frust.

### LOW — `flake.flakeModule` wird als Freeform-Output gesetzt, nicht über die flake-parts-Konvention

Dateien: `modules/parts/flake-parts.nix:2` (importiert nur `flakeModules.modules`), `modules/expose.nix:16`, `README.md:33`

Beleg: Upstream `extras/modules.nix` (rev 31729ca8cbdb und 205b12d8b7cd, beide verifiziert) definiert nur die Option `flake.modules` — kein `flake.flakeModule`. Der Alias `_class = "flake"`-Wrapper + `flakeModules.default`-Export käme aus `extras/flakeModules.nix`, das NICHT importiert wird. expose.nix setzt `flake.flakeModule` also über den freeform-Typ (`types.lazyAttrsOf (types.unique … types.raw)` in `modules/flake.nix`, upstream).

Warum wichtig: Funktioniert, weicht aber von der flake-parts-Konvention für wiederverwendbare Module ab (kein `flakeModules.default`, kein `_class`, kein Dedup-Key). Rein kosmetisch/API-konsistentisch.

### LOW — CI-Actions nur lose gepinnt + wöchentlicher Auto-Merge der Lock-Updates

Dateien: `.github/workflows/flake-check.yml:22-23`, `.github/workflows/flake-update.yml:22-23,33-36`

Beleg: `determinate-nix-action@v3`, `flake-checker-action@main`, `update-flake-lock@main` (mutable Tags); Auto-Merge `gh pr merge --auto --squash` lässt wöchentlich alle 21 Input-Updates ungetestet vom Menschen ins main fließen (nur `nix flake check` als Gate — s. o. ohne echte checks).

Warum wichtig: Reproduzierbarkeits-Anspruch des Repos vs. mutable Action-Tags; Lock-Churn (20 Inputs, nixpkgs unstable) trifft automatisch jeden Konsumenten. Bewusster Trade-off, aber der Gate dahinter ist schwach.

### LOW — Typ-Falle in der dotnix-Option: `str` mit `default = null`

Dateien: `modules/parts/configuration.nix:31-32`

Beleg:
```nix
hostname = lib.mkOption { type = str; default = null; };
```
Kollidiert die Option je ungefüllt (NixOS-Config, die `modules.nixos.dotnix` ohne Bibliotheks-Injektion importiert), wirft die Default-Prüfung `null is not of type string` statt einer verständlichen Meldung. Nie sichtbar im Happy Path (Injektion setzt hostname immer), aber eine Debug-Falle. `nullOr str` + Pflicht-Pfadschreibweise wäre sauberer.

### LOW — Doppelte Direktiven in den Parts (Devshell aus zwei Dateien, formatter-Pflicht)

Dateien: `modules/parts/devshell.nix:4-37`, `modules/parts/pre-commit.nix:14-17`, `modules/parts/treefmt.nix:16-18`

Beleg: devshell.nix und pre-commit.nix und treefmt.nix schreiben alle drei in `devshells.default` bzw. `formatter` (merge-fähig via mkMerge, funktioniert). `devshell.nix:35` referenziert `config.agenix-rekey.package` — Querverbindung, die nur funktioniert, weil parts/age.nix immer mitgeladen wird (in der Bibliothek garantiert; bei Konsumenten via Export auch, aber implizit).

Warum wichtig: Funktionierender, aber verteilter Zustand — eine Devshell aus 3 Dateien; für Neuankömmlinge schwer zu überblicken. Keine Handlung nötig, nur Dokumentation des Mechanismus.

## HardQuestions

1. **Export-Trennung:** Sollte `expose.nix` die `parts/` aus dem `flake.flakeModule`-Export herausnehmen (nur Aspekte + configuration.nix) und Dev-Tooling (devshell/treefmt/pre-commit/templates, `debug`, `systems`) als separates Opt-in-Modul (`flakeModules.devTools`) anbieten — und dabei `debug` für Konsumenten auf Upstream-Default `false` zurückstellen? Oder ist die „Batterien-inklusive"-Injektion Teil des Wertversprechens der Bibliothek?
2. **Core-Injektion — Doku oder Code?** README behauptet, `core` werde pro Host automatisch injiziert; `configuration.nix` injiziert nichts, das Template importiert kein core. Soll der Code `modules.nixos.core` (bzw. `homeManager.core` für Member-User) nachziehen — oder README auf die Realität kürzen? (Entscheidung mit breaking-change-Folge für bestehende Konsumenten, die core manuell importieren.)
3. **flake-parts-Konsolidierung:** Follows-Pins (`agenix-rekey.inputs.flake-parts.follows = "flake-parts"`, analog NUR/Stylix) setzen, um die 3 Revisionen auf 1 zu reduzieren — oder Upstream-Locks respektieren, weil ein 2024-12-flake-parts gegen nixpkgs-lib 2026 ohnehin nur eval-seitig (Moduldefinitionen) existiert und der echte Schaden bislang null ist? Abzuwägen gegen silent-break-Risiko bei agenix-rekey-Rekey-Operationen.
