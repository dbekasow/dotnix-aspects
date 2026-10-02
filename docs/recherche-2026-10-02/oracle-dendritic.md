# Orakel-Gutachten — Dimension: Dendritic-Konventionen & Aspekt-Struktur

Repo: `/home/denis/repositories/private/.dotnix-aspects` (HEAD `ac7724c`, Working tree `M modules/aspects/term/shell-ux/sesh.nix` — unangetastet).
Maßstab: `dendritic-nix`-Skill (SKILL.md, references/aspect-patterns.md, references/setup.md).
Methode: Jede High-/Medium-/Low-Finding des Researcher-Berichts (`/tmp/dotnix-research/dendritic.md`) am Quellcode nachgelesen, Zähler selbst reproduziert, Compliance-Claims unabhängig verifiziert. Nix-Kommandos: keine (statische Analyse; die Template-Fehler sind allein per Auswertungssemantik beweisbar).

---

## Urteil

Das Dendritic-Pattern ist hier **nicht** das Problem. Die mechanischen Kerninvarianten halten alle: keine konditionalen Imports, saubere Klassendisziplin, keine Doppel-Imports entlang eines Consumer-Pfads, `generic` korrekt, Collector/Constants/Multi-Context im pattern-gemäßen Einsatz — das habe ich unabhängig vom Researcher verifiziert. Die empfundenen Struktur- und Wartbarkeitsprobleme sind **Ausführungs- und Disziplinlücken**, nicht Pattern-Abweichung: ein nicht evaluierbares Template plus README, das eine nicht existierende Architektur beschreibt; ~6 echte Dateiname≠Aspektname-Verstöße; eine Library-Schnittstelle, die eigenes Repo-Tooling inkl. `debug = true` in jeden Consumer injiziert; und die Namensgleichheit physischer Gruppen mit logischen Tiers, deren Mitgliedschaften auseinanderlaufen. Die Aspekt-Granularität (shell-ux 14, monitoring 10 Dateien) ist **genau richtig** — ein Tool, eine Datei, ein Aspekt ist der Kernwert des Patterns; die einzige echte Granularitäts-Störung läuft in die Gegenrichtung (zwei Programme unter einem Aspektnamen `television`). Performance-Brücke: Strukturbeiträge zur Trägheit sind eval-seitig (`debug = true` erzwingt flake-weite Introspektions-Evaluation, Tooling-Parts mergen in jeden Consumer-Eval) — sie machen jeden `nix`-Aufruf der Consumer-Flake teurer, aber nicht den laufenden Desktop schneller; Runtime-Verdächtige (stylix/matugen, DMS, niri) liegen außerhalb dieser Dimension. Erste Aktion: Template + README fixen (Aufwand <1 h), danach die `expose.nix`-Schnittstelle verschmälern.

---

## Widerlegtes

Adversarial-Prüfung je Finding. Reihenfolge wie im Researcher-Bericht. Beleg-Zitate habe ich alle selbst gelesen; Zeilennummern teils präziser als im Original.

### High 1 — Template nicht evaluierbar: **HÄLT (vollständig)**

- Case-Mismatch bestätigt: `templates/dotnix/modules/hosts/myHost/configuration.nix` setzt `members = [ "myUser" ]`, `templates/dotnix/modules/users/myUser/default.nix` definiert `let user = "myuser"`. `modules/parts/configuration.nix:39` (`let userModules = lib.attrVals host.members modules.nixos;`) wirft `attribute 'myUser' missing`, bevor irgendetwas baut.
- Fehlende `core`-Tier bestätigt: Host-Modules sind `[ dell-precision-5570 system development ]` — `nixos.home-manager` (das einzige Import von `inputs.home-manager.nixosModules.home-manager`, `modules/aspects/core/home-manager.nix:3-7`) ist nur über `nixos.core` erreichbar. Die Template-User-Datei setzt `home-manager.users."${user}".imports` → undefinierte Option, zweiter Eval-Fehler. (`dell-precision-5570` ist übrigens sauber definiert — `templates/dotnix/modules/hosts/myHost/hardware.nix:2` — das hält.)
- README bestätigt: `README.md` verweist auf `modules/options.nix` und `factories.nix` — keine der beiden Dateien existiert im Baum (146 Dateien vollständig gelistet).
- **Ergänzung, die der Researcher verpasst hat (Root Cause des Verrottens):** CI (`.github/workflows/flake-check.yml`) evaluiert nur die Library-Flake. `templates/dotnix` ist eine eigene Flake mit eigenem `flake.nix` — sie wird von `nix flake check` nie angefasst. Der Zustand konnte deshalb unbemerkt brechen.

### High 2 — Aspect-Name ≠ Datei-Name: **TEILWEISE — 3 von 9 Tabellenzeilen widerlegt**

Geprüfte Zeilen:

| Zeile | Befund |
|---|---|
| `development/ai/skills.nix` → `homeManager.ai-tools` | **Hält.** Aspekt `ai-tools` in Datei `skills.nix`; einzig über `terminal.nix` referenziert. Per Dateiname nicht auffindbar. |
| `desktop/greeter/tuigreet.nix` → `nixos.tui-greeter` | **Hält** (mild: gleiche Domäne, aber grep-Pflicht). |
| `term/secrets/gpg.nix` → `nixos.gnupg` + `homeManager.gpg-agent` | **Hält.** Zwei Aspekte, zwei Namen, eine Datei. |
| `core/yubikey.nix` → `nixos.yubikey` + `nixos.yubikey-pam` | **Hält.** `core.nix` importiert beide; Wohnsitz von `yubikey-pam` nur per grep findbar. |
| `term/monitoring/television-nix.nix` → `homeManager.television` (konfiguriert `programs.nix-search-tv`) | **Hält und ist der schlimmste Fall.** `television.nix` definiert denselben Aspektnamen für ein anderes Programm (`programs.television`). Beide werden über `terminal.nix` gemeinsam importiert — wer nur das eine will, bekommt beide. Kein Konflikt (disjunkte Options-Pfade), aber eine faktische Fusion zweier Features auf einem Namen. |
| `core/nix-substituters.nix` → `nixos.nix` | **WIDERLEGT.** Das ist ein sanktionierter Feature-Split: das Feature `nix` lebt in zwei Dateien (`core/nix.nix` + `core/nix-substituters.nix`), beide tragen den Aspektnamen `nix` = Featurename. SKILL.md: „Split into several files as soon as it has more than one concern" — genau das. |
| `desktop/compositor/niri-bindings.nix` → `homeManager.niri` | **WIDERLEGT.** Dasselbe: Feature `niri` = `niri.nix` + `niri-bindings.nix`, Aspektname = Featurename. |
| `development/devops/k9s.nix` → `homeManager.kubernetes` | **Hält.** Datei heißt k9s, Aspekt kubernetes; konfiguriert wird ausschließlich k9s (+ fish-Abbr). Aspektname verspricht mehr als die Datei hält. |
| `desktop/shell/dms-settings.nix` → `homeManager.dms` | **WIDERLEGT.** Feature-Split dms.nix / dms-settings.nix / dms-plugins.nix; Aspektname `dms` = Featurename. |

Fazit: ~6 echte Verstöße statt 9; der Pattern-Pfeiler ist nicht „tot", sondern in ~90 % der Dateien intakt. Der Schaden ist real (Aspekt-Suche per Dateiname scheitert in der Minderheit der Fälle — aber genau dort, wo man sie braucht), die Zahl war überzeichnet.

### High 3 — Tooling-Injektion in Consumer: **HÄLT** (eine Detail-Präzisierung)

- `modules/expose.nix`: `flake.flakeModule.imports = wrapMods (...)` umfasst nachweislich `(i: i.addPath "${modules}/parts")` — der Consumer (`templates/dotnix/modules/parts.nix:2`: `imports = [ inputs.dotnix.flakeModule ];`) erbt alle Parts: devshell (Name „dotnix", `parts/devshell.nix`), treefmt inkl. `formatter`-Output (`parts/treefmt.nix`), pre-commit (`parts/pre-commit.nix`), `flake.templates.default` „Dendritic NixOS configuration using dotnix" (`parts/templates.nix`), `systems = mkDefault ["x86_64-linux"]` und `debug = mkDefault true` (`parts/flake-parts.nix:5`).
- Input-Rebasing bestätigt: `wrapMods` setzt `inputs = dotnixInputs // args.inputs` — Consumer-Inputs überschreiben Library-Defaults (und `inputs.self` zeigt im Aspekt-Kontext auf den Consumer; das trägt unten Medium 6).
- `debug = true`: flake-parts baut damit `debug.options` / `debug.allSystems` — einen evaluierten Spiegel der gesamten Config für Introspektion (belegt über flake-parts-Skill, SKILL.md:194-204). Dass das Every-Eval verteuert, ist plausibel; **ungemessen** bleibt die Größe (siehe Risiken). Richtung und Mechanismus stimmen.
- **Präzisierung:** Die Behauptung, `debug` sei „nur mit Kenntnis der Stelle über `mkForce` übersteuerbar", ist falsch. `mkDefault` = Priorität 1500; ein schlichtes `debug = false;` im Consumer (Priorität 100) gewinnt. Das Problem ist das Nicht-Wissen, nicht die Prioritätsarithmetik.

### Medium 1 — Collector-Beiträge inline gestreut: **Zahlen halten, Konsequenz abgewertet**

- Reproduziert: `homeManager.impermanence` in 22 Dateien, `nixos.impermanence` in 9 (inkl. `core/age.nix`, `core/nix.nix`, `core/ssh.nix`, `system/*`, `docker.nix`), `homeManager.tmux` in 6 Dateien. `helix-lsp` liegt in **9** Sprach-Dateien (bash, fish, json, just, markdown, nix, text, toml, yaml) — der Researcher zählt 10, falsch, Substanz unberührt.
- **Aber zwei Entlastungen, die das Bild ändern:**
  1. Die tmux-Beiträge (`sesh.nix:58`, `tuicr.nix:49`, `workmux.nix:31,38`) laufen nicht als rohe `programs.tmux`-Schreiberei, sondern über die deklarierten, duplikatvalidierten Options `dotnix.tmux.bindings` / `dotnix.tmux.popups` (`tmux-bindings.nix`, `tmux-popups.nix`) — das ist die Bestform des Collector-Musters, keine Streuung.
  2. Inline-Impermanence ist für die **Entfernbarkeit** (ein explizites Forscher-Kriterium) besser als die empfohlene Kur: App-Datei löschen = Persistenz-Spuren weg. 22 nach Collector benannte Beitragsdateien bedeuten 22 Dateien mehr und Waisen-Risiko beim App-Löschvorgang.
- Rest-Risiko ist nur der Audit-Richtungssinn („Was persistiert alles?") — und der ist ein Einzeiler: `grep -rn 'home.persistence' modules/`.

### Medium 2 — Physische Gruppen divergieren von logischen Tiers: **Fakten halten, Interpretation korrigiert**

- Alle Wohnorte verifiziert: `core.nix` importiert `fish` (term/shell), `git` (development/vcs), `llm-agents` (development/ai); `system.nix` importiert `performance` (core/); `desktop.nix` importiert `fonts` (core/); `development.nix` importiert `nix-ld` (core/); `terminal.nix` importiert `ai-tools` (development/ai/skills.nix), `workmux`, `tuicr`.
- **Korrektur:** Dass Tiers quer zu Themen-Gruppen schneiden, ist dendritisch **Normalzustand, kein Defekt** — das Skill-Beispiel (`system-desktop` importiert mail/browser/kde aus verschiedenen Gruppen) lebt von genau diesem Schnitt. Die Gruppen sind laut Skill „for humans only". Der einzige echte Defekt ist die **Namensgleichheit**: Gruppe `core/` und Tier `core` suggerieren Entsprechung, die nicht existiert. Das ist ein Benennungs-/Doku-Problem („wo muss ich suchen?"), kein Strukturproblem — und es ist durch Verschieben auch nicht behebbar: `fish` bleibt thematisch eine Login-Shell, egal welche Tier es importiert.

### Medium 3 — Core-Aspekte nicht self-contained: **HÄLT, eine Sub-Behauptung widerlegt, Liste sogar unvollständig**

- Verifiziert: `users.nix:6` (`users.users = genAttrs config.dotnix.host.members ...`), `age.nix`, `age-rekey.nix` (`secretsDir = "${inputs.self}/modules/hosts/${config.dotnix.hostname}/secrets"`), `nh.nix`, `certificates.nix`, `docker.nix`, `users-profile.nix:17` — alle lesen `config.dotnix.*`, deklariert ausschließlich über den zentral injizierten Registry-Aspekt (`parts/configuration.nix:32-37`). README:8 („Each aspect is a self-contained flake-parts module") wird dadurch konterkariert.
- **Zusätzlich gefunden (Forscherliste unvollständig):** `desktop/greeter/dms-greeter.nix:11` liest ebenfalls `config.dotnix.host.members`.
- **WIDERLEGT:** „das Template-Verzeichnis erfüllt ihn zufällig nicht — dort existiert kein `secrets/`". Falsch — `templates/dotnix/modules/hosts/myHost/secrets/.gitkeep`, `certificates/.gitkeep` und `modules/users/myUser/secrets/.gitkeep` existieren (Verzeichnis-Gerüst steht). Was stattdessen hält und schärfer ist: Die **verlangten Dateien** sind undokumentiert — `ssh_host_ed25519_key.pub`/`home-key.pub` in jenen Verzeichnissen sowie (wegen des Input-Rebasing zeigt `inputs.self` auf den Consumer) `yubikey.pub` und `masterkey.age` an der **Consumer-Wurzel** (`age-rekey.nix` masterIdentities). Wer nur das README liest, kann die Core-Tier nicht zum Laufen bringen.

### Medium 4 — Hosts als Registry statt Features: **Fakten halten; Bewertung: bewusste, funktionierende Erweiterung**

- Verifiziert: `options.dotnix = mkOption { type = attrsOf hostSubModule; }` + zentrale `nixosConfigurations`-Erzeugung (`parts/configuration.nix:25-60`), Singleton-Aspekt `dotnix` mit `hostname`/`host`-Optionen; User sind dagegen Features im Lehrbuch-Sinn (`myUser/default.nix`: `nixos."${user}"` + `homeManager."${user}"` + `generic."${user}"`, Multi-Context-Wiring per `home-manager.users."${user}".imports`).
- Einordnung: `parts/configuration.nix` **ist** die Factory, die das README als „factories.nix" beschreibt — der Registrierungsansatz ist die.Library-Seite des Factory-Musters: `mapAttrs` über Hosts, Injektion von Metadaten, `iso`-Suboption, kein Boilerplate pro Host, und die members-Getriebene Secrets-Generierung (`users.nix`, `age.nix`) ist der Mechanismus, der das trägt. Der Case-Bug im Template ist ein Typo, der durch String-Indirektion **ermöglicht** wurde — im Import-Modell strukturell ausgeschlossen — aber die Behebung ist ein Ein-Zeichen-Fix, keine Strukturmigration. Empfehlung: Registry behalten (Begründung unter HardQuestions 3).

### Medium 5 — Verwaiste Alternativ-Aspekte + Tier-Kopplung: **HÄLT (als Bibliothek mild)**

- Verifiziert: `boot-limine`, `tui-greeter`, `yubikey-lock` werden von keinem Tier und vom Template importiert (Referenz-Scan negativ); `system.nix` pinnt `boot` + `boot-systemd` fest, `desktop.nix` pinnt `dms-greeter`.
- Einordnung: In einer Aspekt-**Bibliothek** sind nicht importierte Aspekte Exporte, kein toter Code. Das echte Manko ist: Es gibt keine `system`-Tier-Variante ohne Boot-Entscheidung (wer limine will, muss sich die Tier selbst zusammenbauen und riskiert beim Zusatz-Import von `system` zwei konfigurierende Boot-Aspekte). Das ist eine Doku-/Kompositionsfrage, kein Verstoß.

### Low 1-3: **Halten, mit Korrektur bei Low 1**

- Low 1 (Namespace `dotnix` dreifach): faktisch korrekt, aber unvollständig gezählt und milder als behauptet: Es gibt eine **vierte** Verwendung — `dotnix.git.credentials` / `dotnix.git.repositories` (`git-credentials.nix:19-22`, `git-repos.nix:21-29`), Plus `dotnix.tmux.*`. Entscheidend: Die drei Ebenen (flake-parts-Registry-Option, NixOS-Host-Meta, HM-Feature-Options) kollidieren **nie im selben Auswertungskontext**. Semantische Überladung des Worts, kein Funktionsrisiko.
- Low 2 (`shell` doppelt: desktop/shell = DankMaterialShell vs. term/shell = Login-Shells): bestätigt. Kosmetik.
- Low 3 (Bracket-Konvention ungenutzt): bestätigt (keine `[N]`-Verzeichnisse im Baum). Optional laut Skill; Priorität gering.

### Compliance-Bestand des Researcher-Berichts: **unabhängig verifiziert, hält**

- `lib.mkIf` ausschließlich auf Modul-Inhalt (`core/stylix.nix:53`, `term/shell-ux/tmux.nix:144`, `term/monitoring/fastfetch.nix:23`, `development/vcs/git-credentials.nix:27`) — kein konditionaler Import. Bestätigt.
- Klassendisziplin: `generic.*`-Importe nur an den erlaubten Stellen (`users-profile.nix:14,18`); `home-manager.sharedModules = [ modules.homeManager.core ]` (`core/home-manager.nix:7`) = reguläres Multi-Context. Bestätigt.
- Keine Doppel-Imports entlang des User-Pfads: Tier-Listen `homeManager.core` (age, age-rekey, git*, gpg-agent, home-manager, ssh, stylix, users-profile), `terminal`, `development` paarweise disjunkt verifiziert; `homeManager.core` erreicht den User-Kontext nur über `sharedModules`. Bestätigt.
- Keine geschlossenen Modul-Argumente (`{ pkgs }:` ohne `...`): Suchläufe negativ. Bestätigt.

---

## Antworten auf HardQuestions

### HQ1 — Gruppen vs. Tiers: verschieben oder dokumentieren?

**Dokumentieren (und die Namenskollision entzaubern) — nicht verschieben.** Begründung: (a) Group≠Tier-Divergenz ist konstitutiv fürs Pattern — Tiers sind Kompositionslayer, Gruppen Themenregale; sie *müssen* auseinanderlaufen, sonst ist eine der beiden Ebenen redundant. (b) Vollständige Angleichung ist gar nicht erreichbar: `fish` ist gleichzeitig Core-Tier-Mitglied (jeder User braucht eine Shell) und thematisch `term/shell`; jede Verschiebung zerstört eine der beiden Ordnungen. (c) Der einzige Defekt — Gruppe `core/` und Tier `core` heißen gleich, meinen aber Verschiedenes — kostet einen README-Absatz („Tier-Dateien an der Aspekt-Wurzel sind die Kompositionslayer; Gruppen sind Themenregale; Tier-Importlisten sind die verbindliche Antwort auf ‚wo gehört das hin?'"), keinen Datei-Umzug. Die Tier-Dateien sind bereits selbstdokumentierend (reine Import-Listen). Konfidenz: hoch. Was die Antwort ändern würde: wenn der Owner regelmäßig Module physisch sucht statt Tier-Listen zu lesen, wären Brackets (`[N]`-Konvention) ein billiger Scanbarkeits-Zusatz — optional, kein Muss.

### HQ2 — Collector-Beiträge: inline oder Beitragsdateien?

**Inline behalten — gegen die Skill-Konventions-Signalisierung gibt es hier einen triftigen Grund.** Begründung: (a) Die SKILL-Konvention („Beitragsdatei benannt nach dem Collector im Contributor-Verzeichnis") adressiert Config-Repos, in denen ein Contributor (Host) ein nicht-lokales Fragment beisteuert. Hier sind die Impermanence-Beiträge je 1-3 Zeilen und gehören inhaltlich zur App („fish persistiert `.local/share/fish`") — das Skill-Prinzip „Data next to its consumer" spricht *für* Inline. (b) Entfernbarkeits-Kriterium (App + Persistenz löschen) ist mit Inline besser erfüllt als mit 22 Zusatzdateien. (c) Wo Beiträge kollisionsgefährdet sind, macht das Repo es bereits richtig: `dotnix.tmux.bindings`/`popups` mit Duplikat-Key-Validierung und `helix-lsp/` (Verzeichnis = Collector, Datei = Sprache) als verallgemeinerbare Formel. Empfehlung: Inline-Impermanence als dokumentierte Konvention festschreiben plus Audit-Einzeiler (`grep -rn 'home.persistence' modules/`) ins README; nur bei künftigen Contributions mit Konfliktpotenzial (Listen an einer Option, die mehrere Schreiber teilen) das tmux-Options-Muster vorschreiben. Konfidenz: hoch.

### HQ3 — Library-Schnittstelle: Tooling aus dem flakeModule heraus? Host-Registry behalten?

**Schnittstelle verschmälern — ja, unbedingt.** Der `flake.flakeModule`-Vertrag mit dem Consumer sollte sein: Aspekte + die Parts, ohne die die Aspekt-Mechanik nicht funktioniert (`parts/flake-parts.nix` [flake.modules-Maschinerie + systems], `parts/configuration.nix` [Registry + nixosConfigurations], `parts/home-manager.nix`, `parts/age.nix`). Alles andere — `devshell.nix`, `treefmt.nix`, `pre-commit.nix`, `templates.nix`, `debug = true` — ist Repo-Tooling der Bibliothek und gehört nur in deren **eigene** Auswertung (die via `flake.nix` weiterhin `import-tree ./modules` fährt und alles behält). Technisch ist das ein ~5-Zeilen-Diff in `expose.nix` (addPath für `aspects/` behalten, für `parts/` durch explizite Dateiliste der vier Pflicht-Parts ersetzen) plus `debug`-Default auf `false`/Entfernen aus dem Consumer-Pfad. Gewinn: saubere Schnittstelle (kein namensfremder devshell/formatter/templates-Output im Consumer), messbar schnellere Consumer-Evals (weniger zu mergende Module; kein `debug`-Introspektionsspiegel).

**Host-Registry: behalten, nicht auf Host-Features migrieren.** Begründung: (a) Die Registry ist keine Pattern-Abweichung, sondern die Factory-Seite des Musters — `parts/configuration.nix` macht exakt, was das README „factories.nix" nennt: iterieren, injizieren, `nixosConfigurations` erzeugen. (b) Sie trägt die members-getriebene Secrets-Generierung (`users.nix`, `age.nix`, `nh.nix`, `docker.nix`, `dms-greeter.nix`); eine Import-Graph-Migration müsste diese Logik in Per-User-Aspekte umziehen und alle Core-Aspekte umbauen — Tage, Breaking Change für den eigenen Consumer, Gegenwert gering. (c) Der Fallstrick, der die Migration motiviert (String-`members` → Case-Bug), ist im Import-Modell nur *strukturell* unmöglich; ein Template-Test in CI erledigt das zu 100 % für ein Hundertstel des Aufwands. Konfidenz: mittel-hoch — was die Antwort ändern würde: wenn der Owner mehrere Consumer-Flakes plant, die Host-**Vererbung** brauchen (Host-Ableitungen wie heute User-Tiers), käme Host-Features-Inheritance wieder ins Spiel; aktuell gibt es dafür keinen Beleg.

### Zusatzfrage der Ausschreibung — Granularität: zu fein?

**Nein — die Granularität ist genau richtig und der Kern dessen, was hier gut funktioniert.** shell-ux (14 Dateien), monitoring (10), files (10), helix-lsp (9): jeweils ein Werkzeug = eine Datei = ein Aspekt (`homeManager.<tool>`), einzeln komponierbar — die `terminal`-Tier importiert sie en bloc, ein schlankerer User könnte sie einzeln ziehen. „One feature = one name" ist keine Aussage über Datei-*Zahl*, sondern über die 1:1-Entsprechung Feature↔Aspektname — und die ist in der großen Mehrzahl der Dateien intakt (s. Widerlegtes, High 2: ~6 echte Verstöße auf 146 Dateien). Die einzige echte Granularitätsstörung ist **unter**-gesplittelt, nicht über: `television` + `television-nix` verschmelzen zwei Programme auf einem Aspektnamen, sodass die Tier beide immer gemeinsam zieht. Fix: Aspekt `homeManager.nix-search-tv` + Datei-Umbenennung (Renames sind dank import-tree mechanisch gratis — „File names are documentation, not mechanism"). Konfidenz: hoch.

### Kernfrage der Ausschreibung — Pattern-Abweichung oder Ausführung?

**Ausführung.** Beweislage: Alle strukturtragenden Regeln des Patterns halten (Compliance-Liste, oben unabhängig verifiziert) — das sind die Regeln, deren Bruch Refactorings erzwingen würde (konditionale Imports, Klassentypisierung, Doppel-Imports). Alles, was reibt, ist Disziplin im Kleinen: Namens-Hygiene (6 Fälle), Onboarding-Pflege (Template, README, CI-Lücke), Schnittstellen-Hygiene (Tooling-Injektion), Namens-Kollision (Gruppe/Tier) — jedes einzeln in Stunden fixbar, keines erfordert Abkehr vom oder Umbau des Patterns. Das Mischmodell (User = Features, Hosts = Registry) ist als bewusste Bibliotheks-Erweiterung tragfähig, wenn es dokumentiert ist. Konfidenz: hoch.

**Perf-Abgrenzung (explizit):** Struktur bedingt Eval-Latenz, nicht Runtime-Trägheit. `debug = true` + 4 Tooling-Parts im Consumer-Pfad verteuern jeden `nix`-Aufruf der Consumer-Flake (rebuild, switch, direnv); deren Entfernung ist der einzigePerformance-Beitrag dieser Dimension. Ein träge *lauftender* Desktop (niri, DMS, stylix/matugen) ist inhaltlich, nicht strukturell bedingt — Hypothese, andere Forscher-Dimension.

---

## Empfehlungen

| # | Aktion | Impact | Aufwand | Prio |
|---|---|---|---|---|
| 1 | **Template fixen**: `members = [ "myuser" ]` (hosts/myHost/configuration.nix); `core` in die Host-Modules aufnehmen (damit `nixos.home-manager`, `users`, `age` rein); README auf Realität umschreiben (Registry/Factory = `modules/parts/configuration.nix`, Export = `modules/expose.nix`; Layout-Kontrakt dokumentieren: `modules/hosts/<host>/secrets/*.pub`, `modules/users/<user>/secrets/home-key.pub`, Consumer-Wurzel `yubikey.pub`/`masterkey.age`) | Hoch (Onboarding-Pfad funktional; „wo steht was?" wird wahr) | 1 h | **P1** |
| 2 | **expose.nix verschmälern**: statt `addPath parts/` nur `parts/{flake-parts,configuration,home-manager,age}.nix` wrappen; `devshell/treefmt/pre-commit/templates` ausschließlich in die Library-eigene Auswertung lassen; `debug`-Default für Consumer auf `false` | Hoch (Eval-Zeit bei jedem nix-Kommando des Consumers; Schnittstellen-Überraschungen weg) | 2-3 h | **P1** |
| 3 | **Template-Eval in CI**: flake-check.yml um einen Job erweitern, der `templates/dotnix` in ein Temp-Verzeichnis kopiert und `nix flake check`/`nix flake show` darauf läuft | Mittel (Root-Cause-Abschaltung des Verrottens; verhindert auch HQ3-Diskussionen) | 1 h | P2 |
| 4 | **Namens-Hygiene-Sweep** (Renames sind dank import-tree gratis; je auch Tier-Importlisten anpassen): `skills.nix`→`ai-tools.nix`; `k9s.nix`→`kubernetes.nix`; `tuigreet.nix`→`tui-greeter.nix`; `gpg.nix` splitten nach `gnupg.nix`+`gpg-agent.nix`; `yubikey.nix` splitten nach `yubikey.nix`+`yubikey-pam.nix`; `television-nix.nix`→`nix-search-tv.nix` mit Aspekt `homeManager.nix-search-tv` + `terminal.nix` ergänzen | Mittel (Dateiname wird wieder zuverlässige Dokumentation; Granularitäts-Fusion aufgelöst) | 1-2 h | P2 |
| 5 | **Doku-Nachtrag README**: (a) Tier≠Group-Absatz (Tier-Dateien an `modules/aspects/*.nix` = Kompositionslayer; Gruppen = Themenregale; `grep`-Einzeiler für Impermanence-Audit); (b) Alternativ-Aspekte (`boot-limine`, `tui-greeter`, `yubikey-lock`) als „wählbare Exporte, nicht in Tiers" listen plus Hinweis, dass `system`-Tier `boot-systemd` pinnt | Mittel (Reibung „wo suche ich?" ohne Code-Änderung gesenkt) | 1 h | P3 |
| 6 | Optional (gering): `desktop/shell/`→`desktop/dms-shell/` umbenennen (Doppellung „shell" mit `term/shell`); Bracket-Konvention einführen nur, wenn HQ1-Doku nicht greift; `dotnix`-Namespace mit einem README-Satz erklären statt umbauen | Gering | 1 h | P4 |

**Explizite Anti-Empfehlungen** (jeweils geprüft und verworfen):
- Impermanence in 22 nach Collector benannten Dateien rekonstruieren — Aufwand ohne Verhaltensgewinn, verschlechtert Entfernbarkeit (Medium 1).
- Dateien verschieben, um Gruppen an Tiers anzugleichen — strukturell unmöglich ohne Zerstörung der Themen-Ordnung (HQ1).
- Hosts auf Features migrieren — Breaking Change ohne aktuellen Bedarf; Case-Bug-Klasse wird durch CI-Template-Test (Aktion 3) günstiger eliminiert (HQ3).

---

## Risiken und unknowns

- **`debug = true`-Kosten sind ungemessen.** Mechanismus (Introspektionsspiegel `debug.options`/`debug.allSystems`, flake-parts-Skill SKILL.md:194-204) ist belegt; wie groß der Eval-Anteil an der gefühlten Trägheit ist, kann nur ein Timing-Vergleich (Consumer mit/ohne `debug`, `nix eval --raw .#` o. ä.) klären. Aktion 2 lohnt sich auch ohne Messung, aber die Erwartung an Aktion 2 sollte nicht „Desktop wird flink", sondern „Evals werden schneller" sein.
- **Template-Eval-Fehler sind statisch bewiesen, nicht durch Auswertung:** `attrVals` auf fehlendem Schlüssel und die fehlende `home-manager.users`-Option sind zwingend, aber ein `nix flake check` auf dem fixen Template sollte die Korrektheit nach Aktion 1 bestätigen.
- **Benötigte Consumer-Inputs:** Für Aktion 2 ist zu prüfen, ob Aspekte indirekt Inputs brauchen, die nur über die entfernten Parts registriert werden (z. B. agenix-rekey-FlakeModule via `parts/age.nix` — bleibt im Set, aber die Viererliste final gegen `grep inputs.` über alle Aspekte validieren).
- **Unberücksichtigt:** `modules/aspects/term/shell-ux/sesh.nix` ist im Working Tree modifiziert (User-Arbeit); alle Aussagen beziehen sich auf den Stand dieser Datei, wie gelesen.
- **Nicht Gegenstand dieser Dimension:** Runtime-Performance des Desktops (verdächtig inhaltlich: stylix/matugen-Pipeline, DMS, niri — Hypothese, dem Performance-Researcher überlassen); `flake.lock`-Input-Frische (HEAD `ac7724c` = „chore: update flake inputs").
