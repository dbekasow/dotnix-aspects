# Querschnitts-Gutachten 2/6 — STRUKTUR

Repo: `/home/denis/repositories/private/.dotnix-aspects` (HEAD `ac7724c`; Working Tree hat `M modules/aspects/term/shell-ux/sesh.nix` — unangetastet, Aussagen beziehen sich auf den gelesenen Stand).
Maßstab: `dendritic-nix`-Skill (SKILL.md, references/setup.md, references/aspect-patterns.md, references/why-and-tradeoffs.md). Basis: 10 Forschungsberichte + 9 vorhanden Orakel-Gutachten in `/tmp/dotnix-research/`; alle im Folgenden zitierten Belege habe ich selbst am Repo nachgelesen (Read/Grep), nicht nur aus den Berichten übernommen.

---

## Verdikt

**Das Dendritic-Pattern ist nicht das Problem — die Ausführung ist es.** Alle strukturtragenden Invarianten des Patterns halten (selbst verifiziert): keine konditionalen Imports, saubere Modulklassen-Disziplin (`generic` nur an erlaubten Stellen), keine Doppel-Imports entlang eines Consumer-Pfads, `mkMerge` statt `//`, überall offene Modul-Argumente, kanonisches `mkFlake + import-tree ./modules` (`flake.nix:68-69`). Die Aspekt-Mechanik ist konform, die Granularität (ein Werkzeug = eine Datei = ein Aspekt) ist der Kernwert des Patterns und genau richtig.

Die empfundenen Struktur-/Wartbarkeitsprobleme entstehen an vier Ausführungslücken, jede einzeln in Stunden fixbar, keine erfordert Abkehr vom Pattern oder Umbau der Architektur:

1. **Der Bibliotheks-Vertrag rottet still**: Template eval-brochen, README beschreibt Phantom-Dateien, CI evaluiert den Export-Pfad nie (Details unten, A1).
2. **Die Export-Schnittstelle ist zu breit**: `expose.nix` liefert Dev-Tooling und `debug = true` in jeden Consumer (A2).
3. **Namens- und Ordnungsdisziplin bricht an ~6 Stellen** gegen die repo-eigene Konvention (`31e30d3` „set aspect names to file name") — Dateiname als Dokumentation kollabiert genau dort, wo man sie braucht (A3).
4. **Die Dokumentation lügt über die Architektur**: „self-contained" und „factories.nix" sind Fiktion; der tatsächliche Layout-Kontrakt ist nirgends geschrieben (A4).

**Zur Architektur-Frage (Punkt 2 der Ausschreibung): Die Bibliothek-ohne-Hosts-Aufteilung ist für diesen Anwendungsfall richtig** — aber sie ist eine bewusste Produktentscheidung mit eingerechneten Kosten, und die wichtigste davon (impliziter, ungetesteter Vertrag) muss jetzt bezahlt werden. Begründung und Abwägung im eigenen Kapitel.

**Erste Aktion**: Template fixen (`myuser`, `core`-Tier rein), README auf Realität umschreiben, und einen CI-Job einführen, der `templates/dotnix` als synthetischen Consumer evaluiert. Das kostet zusammen <2 h und schaltet die Wurzel des Verrottens ab — alle späteren Struktur-Fixes werden erst dann gegen Regressionen gesichert.

Priorisierte Fix-Liste (Aufwand kumuliert ≈ 6–8 h):

| # | Aktion | Wirkung | Aufwand |
|---|---|---|---|
| 1 | Template: `members = [ "myuser" ]`, `core` in Host-Module; README: `options.nix`/`factories.nix` → `modules/parts/configuration.nix` + `modules/expose.nix` | Onboarding-Pfad funktioniert; „wo steht was" wird wahr | 1 h |
| 2 | CI-Job: `templates/dotnix` kopieren + `nix flake check`/`eval` darauf | Root-Cause-Absicherung des Exports; verhindert erneutes Rot | 1 h |
| 3 | `expose.nix` verschmälern: statt `addPath parts/` nur die vier Pflicht-Parts (`flake-parts`, `configuration`, `home-manager`, `age`); `debug`-Default für Consumer auf `false` | Keine Tooling-Überraschungen im Consumer; weniger Eval-Last | 2–3 h |
| 4 | Namens-Sweep (Renames dank import-tree gratis): `skills.nix`→`ai-tools.nix`, `k9s.nix`→`kubernetes.nix`, `tuigreet.nix`→`tui-greeter.nix`, `gpg.nix` splitten, `television-nix.nix`→ Aspekt `homeManager.nix-search-tv` | Dateiname wird wieder zuverlässige Dokumentation; Namens-Fusion aufgelöst | 1–2 h |
| 5 | README-Absätze: Tier≠Gruppe, Layout-Kontrakt (Secrets/Cert-Verzeichnisse, Consumer-Wurzel-Identitäten), Impermanence-Audit-Einzeiler, Alternativ-Aspekte | Such- und Navigationsreibung sinkt ohne Code-Änderung | 1 h |

---

## Abweichungen & ihre Wirkung

### A1 [wirkmächtigste Abweichung] — Bibliotheks-Vertrag ungeprüft: Template kaputt, README veraltet, CI blind

**Belege (alle selbst verifiziert):**
- `templates/dotnix/modules/hosts/myHost/configuration.nix:9`: `members = [ "myUser" ]` vs. `templates/dotnix/modules/users/myUser/default.nix:2`: `let user = "myuser";` → `lib.attrVals host.members modules.nixos` (`modules/parts/configuration.nix:39`) wirft `missing attribute`, bevor irgendetwas baut.
- `templates/dotnix/modules/hosts/myHost/configuration.nix:4-8`: Host-Module `= [ dell-precision-5570 system development ]` — **keine `core`-Tier**. `nixos.home-manager` (einziger Import des HM-NixOS-Moduls, `core/home-manager.nix:7`) ist nur über `nixos.core` erreichbar; die User-Datei setzt `home-manager.users."${user}".imports` → zweite Eval-Error-Klasse. Das Template ist der Onboarding-Pfad (`flake.templates.default`, `parts/templates.nix`).
- `README.md:21` verweist auf `modules/options.nix` und `factories.nix` — beide existieren im Baum nicht (146 `.nix`-Dateien gelistet). `README.md:8` („Each aspect is a self-contained flake-parts module") und `:29-31` („factories.nix … injecting core modules automatically") beschreiben eine Architektur, die so nicht existiert: das Registry/Factory-Äquivalent ist `modules/parts/configuration.nix`, und `core` wird NICHT automatisch injiziert (Gegenbeweis: Template-Host ohne `core`).
- **Root Cause**: `.github/workflows/flake-check.yml` evaluiert nur die Bibliotheks-Flake. `templates/dotnix` ist eine eigene Flake — `nix flake check` fasst sie nie an; ein `checks`-Output existiert nirgends (grep über `modules/`, `templates/`, `flake.nix` leer). Der Workflow-Kommentar („covers: treefmt, deadnix, statix, typos, commitizen") behauptet Hook-Coverage, die die Flake nicht hergibt.

**Wirkung**: Das ist der direkteste Treffer auf die Struktur-Unzufriedenheit. Der Template-Schema-Artefakt — die einzige maschinenlesbare Dokumentation des Konsumenten-Vertrags — ist falsch, die menschliche (README) auch, und der Mechanismus, der beides hätte grün halten müssen (CI), existiert nicht. Jede Wiedereinarbeitung, jeder neue Host, jeder externe Verwender rennt zuerst in zwei Eval-Fehler. Nebenwirkung: die CI-Lücke ist auch der Grund, warum die anderen Abweichungen unentdeckt blieben.

### A2 — Export-Schnittstelle zu breit: Dev-Tooling + `debug = true` in jeden Consumer

**Belege:**
- `modules/expose.nix:16-23`: `flake.flakeModule.imports = wrapMods (import-tree addPath aspects + addPath parts)` — der Consumer-Import (belegt: `/home/denis/repositories/private/.dotnix/modules/flake/dotnix.nix:2` und `templates/dotnix/modules/parts.nix:2`) zieht damit **alle** `modules/parts/` mit: `devshells.default` inkl. Name/Pakete (`parts/devshell.nix`), treefmt-`formatter` (`parts/treefmt.nix`), pre-commit-Hooks (`parts/pre-commit.nix`), `flake.templates.default` (`parts/templates.nix`), `debug = lib.mkDefault true` (`parts/flake-parts.nix:5`).
- Input-Rebasing in `expose.nix:5-11` (`inputs = dotnixInputs // args.inputs`): Library-Inputs werden Defaults — technisch sauber, aber Teil desselben impliziten Vertrags.

**Wirkung**: Zwei sortierte Probleme. (1) Struktur→Eval-Brücke: `debug = true` zwingt flake-parts zur Eager-Evaluation eines Introspektions-Spiegels der gesamten Consumer-Config — das verteuert jeden `nix`-Aufruf des Consumers (rebuild, switch, direnv); die Tooling-Parts mergen zusätzlich in jeden Consumer-Eval (eval-perf: import-tree selbst ist mit 0,15–0,5 s vernachlässigbar — die Last kommt aus `debug` + zusätzlichem Modul-Baum, nicht aus der Dendritic-Mechanik). (2) Schnittstellen-Hygiene: Die Consumer-Flake zeigt devshells, formatter und templates, die sie nie deklariert hat — ein klarer Verstoß gegen das Prinzip minimaler Schnittstellen und die häufigste Quelle von „Warum tut meine Flake das?"-Verwirrung. Präzisierung gegenüber dem Researcher: `mkDefault` (Prio 1500) ist mit schlichtem `debug = false` (Prio 100) übersteuerbar — das Problem ist das Nicht-Wissen, nicht die Prioritätsarithmetik.

### A3 — Namens- und Ordnungsdisziplin: ~6 echte Dateiname≠Aspektname-Fälle, darunter eine Namens-Fusion

**Belege (jede Zeile selbst gelesen):** `development/ai/skills.nix:2` → `homeManager.ai-tools`; `development/devops/k9s.nix:2` → `homeManager.kubernetes` (konfiguriert ausschließlich k9s); `desktop/greeter/tuigreet.nix:2` → `nixos.tui-greeter`; `term/secrets/gpg.nix:2` → `nixos.gnupg` (+ `homeManager.gpg-agent` in derselben Datei); `core/yubikey.nix` → `nixos.yubikey` + `nixos.yubikey-pam` (beide via `core.nix` importiert, Wohnort nur per grep findbar); `term/monitoring/television-nix.nix:2` → `homeManager.television`, konfiguriert aber `programs.nix-search-tv` — **denselben Aspektnamen** wie `television.nix:2` (`programs.television`); beide werden über `terminal.nix` gemeinsam gezogen: eine faktische Fusion zweier Programme auf einem Namen (Merge zufällig harmlos, disjunkte Options-Pfade).

**Widerlegte Schein-Verstöße** (wichtig für die Fairness des Urteils): `nix-substituters.nix`, `niri-bindings.nix`, `dms-settings.nix` sind sanktionierte Feature-Splits (Feature lebt in mehreren Dateien, Aspektname = Featurename — Skill: „Split into several files as soon as it has more than one concern"). Die Zahl der echten Verstöße ist ~6 auf 146 Dateien, nicht ~10 — der Pattern-Pfeiler ist in ~96 % der Dateien intakt. Aber: Das Repo hat die Konvention selbst festgeschrieben (`31e30d3` „set aspect names to file name") — die verbleibenden Fälle sind Abweichungen von der eigenen, commitfestgeschriebenen Entscheidung, nicht vom Skill-Exzess.

**Wirkung**: „File names are documentation" ist der zentrale Lesbarkeits-Mehrwert des Patterns. Der bricht punktuell — genau an den Stellen, an denen man ihn am wenigsten entbehren kann (Aspekt-Suche per Dateiname scheitert). Die television-Fusion ist die einzige echte Granularitäts-Störung im Repo, und sie läuft in Richtung Unter-Splitting, nicht Über-Splitting: wer nur `television` will, bekommt `nix-search-tv` dazu. Fix ist billig, weil Renames dank import-tree mechanisch gratis sind.

### A4 — Gruppe/Tier-Gleichnamigkeit und Aktivierungs-Realität ≠ Verzeichnisgrenze

**Belege:** Tier `core` (`core.nix:3-14`) importiert `fish` (wohnt `term/shell/`), `git` (`development/vcs/`), `llm-agents` (`development/ai/`); Tier `system` (`system.nix:3-13`) importiert `performance` (`core/`); Tier `desktop` importiert `fonts` (`core/`); Tier `terminal` (`terminal.nix:46-62`) importiert `ai-tools` (in `development/ai/skills.nix`), `workmux`, `tuicr` (`development/ai/`). Drei unabhängige Forscherberichte (dendritic, core-system, development — dort „Struktur-Lüge" genannt) fanden dasselbe aus drei Richtungen.

**Einordnung**: Dass Tiers quer zu Themen-Gruppen schneiden, ist dendritisch Normalzustand, kein Defekt — Tiers sind Kompositionslayer, Gruppen Themenregale (das Skill-Beispiel `system-desktop` lebt von genau diesem Schnitt). Der Defekt ist die **Namensgleichheit**: Verzeichnis `core/` und Tier `core` suggerieren Entsprechung, die nicht existiert; `core/fonts.nix` gehört zum Desktop-Tier, `term/shell/fish.nix` zum Core-Tier. Vollständige Angleichung per File-Move ist unattainbar (`fish` bleibt thematisch eine Login-Shell, egal welches Tier es zieht) und würde die Themen-Ordnung zerstören. **Fix ist Dokumentation** (README-Absatz: Tier-Dateien an der Aspekt-Wurzel = verbindliche Kompositionslayer; Gruppen = Themenregale; Antwort auf „wo gehört das hin?" = Tier-Importliste), optional Brackets.

**Wirkung**: Die häufigste Quelle für „wo muss ich suchen?"-Reibung im Alltag — aber ein Benennungs-/Doku-Problem, kein Strukturproblem, und nicht durch Verschieben heilbar.

### A5 — Core-Aspekte nicht standalone: Registry-Abhängigkeit, Layout-Kontrakt, Personalia im Public-Aspekt

**Belege:** `core/users.nix:6,28`, `core/nh.nix:11-13`, `core/age.nix:13`, `core/users-profile.nix:17`, `core/age-rekey.nix:6`, `core/certificates.nix:5`, `development/devops/docker.nix:12`, `desktop/greeter/dms-greeter.nix:11` lesen `config.dotnix.host.members`/`dotnix.hostname` — Optionen, die nur über den Registry-Part deklariert werden (`parts/configuration.nix:30-34`). `age-rekey.nix:6,15-25` erzwingt das Consumer-Layout `modules/hosts/<host>/secrets/` + `modules/users/<user>/secrets/` und verankert persönliche Master-Identitäten (YubiKey-/Backup-Inline-Pubkeys, hier bewusst nicht reproduziert) in einem MIT-lizenzierten „reusable library"-Aspekt; benötigt werden außerdem `yubikey.pub`/`masterkey.age` an der Consumer-Wurzel. Prunkstück des Widerspruchs: `README.md:8` „self-contained". Typ-Falle nebenbei: `parts/configuration.nix:32` `hostname = mkOption { type = str; default = null; }` — str mit null-Default.

**Wirkung**: Medium. Wer einzelne Core-Aspekte ohne den `dotnix`-Registry-Import in eine bestehende NixOS-Config zieht, bekommt undefined-option-Fehler; wer das README glaubt, scheitert am undokumentierten Layout-Kontrakt. Das ist die zweite Doku-Lüge neben A1. Die Kopplung selbst ist aber **Design**, nicht Unfall: die members-getriebene Secrets-Generierung (`users.nix`, `age.nix`) ist der Mechanismus, der die Registry trägt — sie rückzubauen, hieße die funktionierende Fabrik zerstören. Fix: README ehrlich machen („Aspekte komponieren innerhalb eines dotnix-Consumers"; Layout-Kontrakt dokumentieren) und die Master-Identitäten per `mkDefault`/Consumer-Override aus dem Public-Aspekt herausziehen.

### A6 — Verwaiste Alternativ-Aspekte + Tier-Kopplung (mild)

**Belege**: `nixos.boot-limine`, `nixos.tui-greeter`, `nixos.yubikey-lock` sind definiert (`boot-limine.nix:2`, `tuigreet.nix:2`, `yubikey-lock.nix:2`) und werden von keinem Tier und keinem Template referenziert (Referenz-Scan negativ). `system.nix:5-6` pinnt `boot` + `boot-systemd`, `desktop.nix` pinnt `dms-greeter`. Auch `bootstrap.nix` (sechste Tier: `nixos.bootstrap` = minimales Install-Set) hat im sichtbaren Horizont keinen Konsumenten.

**Wirkung**: Gering. In einer Aspekt-**Bibliothek** sind nicht importierte Aspekte Exporte, kein toter Code — und der dead-dupes-Oracle belegt aktive Iteration am Desktop-Ast durch einen Konsumenten außerhalb des sichtbaren Horizonts. Das echte Manko ist Komposition: es gibt keine `system`-Variante ohne Boot-Entscheidung; wer `boot-limine` will, muss sich eine eigene Tier bauen und riskiert beim Zusatz-Import zwei konfigurierende Boot-Aspekte. Fix: Liste der Alternativ-Exporte + Pinning-Hinweis ins README (Inheritance-Varianten sind Optional, kein Muss).

### A7 — Kleinraum (kosmetisch, zusammen <1 h)

Namespace `dotnix` mehrfach belegt (flake-parts-Registry-Option `parts/configuration.nix:22`, NixOS-Host-Meta `:30-34`, HM-Feature-Optionen `dotnix.tmux.*`, `dotnix.git.*` — niemals im selben Auswertungskontext, also überladen, nicht kollidiert); „shell" doppelt vergeben (`desktop/shell/` = DankMaterialShell vs. `term/shell/` = Login-Shells); Bracket-Konvention (`[N]`/`[NDn]`) ungenutzt; `mkOption`s ohne `description` (core/development, selbst gesehen: `parts/configuration.nix:33` u. a.); No-Op-Aspekt `bash` (term-Oracle). Keine davon verursacht die empfundenen Wartbarkeitsprobleme einzeln; sie addieren sich zu Rauschen, das man mit einem Doku-Absatz und zwei Umbenennungen entschärft, wenn man ohnehin im README ist.

### Was NICHT abweicht (verifizierter Compliance-Bestand — das ist die Beweislast für „Pattern unschuldig")

- Keine konditionalen Imports (`mkIf` ausschließlich auf Modul-Inhalt: `core/stylix.nix:53`, `term/shell-ux/tmux.nix:144`, `term/monitoring/fastfetch.nix:23`, `development/vcs/git-credentials.nix:27`).
- Klassendisziplin: `nixos.*`→`nixos.*`(+ `generic.*` an `users-profile.nix:14,18`), `homeManager` analog; `home-manager.sharedModules = [ modules.homeManager.core ]` (`core/home-manager.nix:7`) = reguläres Multi-Context.
- Keine Doppel-Imports entlang eines Pfades (Tier-Listen paarweise disjunkt geprüft; `homeManager.core` erreicht User nur via `sharedModules`).
- Keine geschlossenen Modul-Argumente; konsequentes `lib.*`, 0× `builtins.*` in core/system; Collector (`impermanence`, 22 Dateien — selbst nachgezählt), Constants (`generic."<user>"` im Template), Multi-Context und die Options-Collector `dotnix.tmux.bindings`/`popups` mit Duplikat-Key-Validierung sind pattern-gemäß bis vorbildlich im Einsatz.
- Granularität: shell-ux 14, monitoring 10, helix-lsp 9 Dateien — ein Werkzeug pro Datei; einziger Granularitäts-Fehler ist die `television`-Fusion (A3), und zwar in Richtung Unter-Splitting.

---

## Architektur-Abwägung

**Ist-Zustand**: Öffentliche, MIT-lizenzierte Aspekt-Bibliothek (146 `.nix`, 4.571 LOC, 120 `homeManager`- + 54 `nixos`-Aspekt-Definitionen) ohne Hosts; Hosts/User als Features bzw. Registry-Einträge im Konsumenten-Repo; Vertrag = `flake.flakeModule` + `templates/dotnix` als Schema-Artefakt. Sichtbare Konsumenten: `.dotnix` (WSL-Host `dmi`: `modules = [ core wsl development ]`, `members = [ "denis" ]`, pinnt Bibliothek auf `0c33875` ≠ HEAD) — plus ein Laptop-Konsument außerhalb des sichtbaren Horizonts (Azure-DevOps-Remote; belegt durch aktive Desktop-Iteration laut Git-Historie, dead-dupes-Oracle). Git-Historie belegt bewusste Struktur-Entscheidungen: `31e30d3` (Aspekt=Dateiname), `fddc7c5` (bootstrap→core), `880c2b1` (core aus Default entfernt).

| Option | Pro | Contra | Risiko |
|---|---|---|---|
| **A. Split behalten + Vertrag fixen** (Template-CI, expose verschmälern, Layout-/Tier-Doku, Personalia raus) | Secrets/Personalia bleiben aus dem Public-Repo (Consumer `.dotnix` führt echte `.age`-Secrets, Zertifikate — verifiziert); Veröffentlichungs- und Dendrix-Intention (LICENSE/README/Template) bleibt erfüllbar; Host-Churn isoliert; kleinste Diffs | Zwei Locks/Flakes bleiben zu pflegen; Consumer-Pin kann weiter hinter HEAD laufen | Gering — alle Teilschritte sind additive Fixes |
| B. Hosts in die Bibliothek ziehen (kanonisches Ein-Repo-Dendritic) | Ein Lock, direkte CI-Eval realer Hosts, kein Export-Vertrag, kein Rebasing | Host-Secrets, Zertifikate, Privates in öffentlichem Repo — oder Bibliothek müsste privat werden; Host-Churn im öffentlichen Verlauf | Hoch (Geheimnis-Leck bzw. Aufgabe des Public-Release) |
| C. Bibliothek auflösen, alles ins Consumer-Repo | Eine Flake, keine Schnittstelle | Public-Release-Absicht aufgegeben; zweiter Konsument (Laptop) verlört die geteilte Basis; 4.571 LOC bewährte Aspekt-Struktur würde in ein Host-Repo degradiert | Mittel-hoch |
| D. Host-Registry → Host-Features migrieren (kanonisch „a host is just a feature") | `members`-String-Bugs strukturell unmöglich; Hosts erben/komponieren wie User-Tiers | Registry ist die Factory-Seite des Musters und trägt die members-getriebene Secrets-Generierung (`users.nix`, `age.nix`, `nh.nix`, `docker.nix`); Migration = Breaking Change über alle Core-Aspekte, Tage Aufwand; der einzige reale Bug dieser Klasse (Case-Mismatch) ist ein Ein-Zeichen-Fix + CI-Test | Mittel (Aufwand ohne Gegenwert) |

**Empfehlung: Option A.** Die Aufteilung „öffentliche Aspekt-Bibliothek + private Konsumenten-Repos mit Secrets" ist für diesen Fall die richtige: Sie ist keine Spekulation (zwei reale Konsumenten; Veröffentlichungsabsicht durch LICENSE/README/Template belegt), sie ist die einzige Option, die Geheimhaltung und Veröffentlichung gleichzeitig erlaubt, und die gesamte gefühlte Struktur-Last ist auf Fixe innerhalb des Splits zurückführbar. Das Mischmodell „User = Features (Lehrbuch-Multi-Context), Hosts = Registry-Einträge (Factory)" ist dabei kein Pattern-Verrat, sondern eine tragfähige Erweiterung mit echten Vorteilen (`iso`-Suboption, hostname-Injektion, kein Boilerplate pro Host) — dokumentiert gehören sie dazu.

**Ehrliche Kostenrechnung des Splits — das gehört ins Urteil, nicht unter den Teppich**: Der Split ersetzt das natürliche Feedback-Loop des kanonischen Patterns (Hosts im selben Baum, von `nix flake check` evaluiert) durch einen Vertrag, der bis heute implizit und ungetestet war. Genau deshalb ist das Template verrottet, das README davongelaufen und 24 Desktop-Dateien gegen einen unsichtbaren Konsumenten gepflegt worden (dead-dupes: einziger sichtbarer Konsument erreicht den Desktop-Ast nicht). Der Template-CI-Job (Aktion 2) ist daher keine Nice-to-have-Hygiene, sondern das strukturelle Missing Piece der Architektur: Er macht `templates/dotnix` zum synthetischen Konsumenten, der den Export-Pfad bei jedem Commit evaluiert. — **Last-condition**: Wäre die Veröffentlichungsabsicht Fiktion (der Owner teilt die Bibliothek nie), kippt die Abwägung zu Option C, und der Split wäre für einen Zwei-Host-Einzelbetrieb Overengineering. Nach heutigem Befund (LICENSE, README-Sprache „reusable library", Template, GitHub-Remote) ist sie es nicht.

Konfidenz: **hoch** für Muster-vs-Ausführung (mechanische Invarianten vollständig selbst verifiziert) und für A1–A5 (jeder Beleg selbst gelesen). **Mittel** für die Laptop-Konsumenten-Annahme (indirekt über Commit-Historie geschlossen; Remote ohne Credentials nicht enumerierbar) — sie ändert aber am Struktur-Verdikt nichts, nur an der Dringlichkeit des Template-CI.

---

## Bewusst lassen (Nicht anfassen)

1. **Impermanence-Beiträge inline in App-Dateien (22 Dateien)** — gegen die Skill-Namenskonvention für Collector-Beiträge, aber hier richtig: Die Beiträge sind je 1–3 Zeilen und gehören inhaltlich zur App („fish persistiert `.local/share/fish`" = Data-next-to-Consumer); App-Datei löschen entfernt automatisch die Persistenz-Spur. 22 nach Collector benannte Zusatzdateien verschlechtern Entfernbarkeit und Waisen-Risiko. Wo Beiträge kollisionsgefährdet sind, macht das Repo es bereits vorbildlich: `dotnix.tmux.bindings`/`popups` mit Duplikat-Key-Validierung und das `helix-lsp/`-Verzeichnis (Collector = Verzeichnis, Datei = Sprache). Einziger Nachtrag: der Audit-Richtungssinn („Was persistiert?") gehört als `grep`-Einzeiler ins README, nicht als Refactor ins Repo.
2. **Host-Registry statt Host-Features** — bewusste, funktionierende Factory-Erweiterung (oben, Option D). Nicht migrieren; den Case-Bug-Klassen-Rest erledigt der Template-CI-Test.
3. **Granularität: ein Werkzeug = eine Datei = ein Aspekt** — shell-ux (14), monitoring (10), files (10), helix-lsp (9 Dateien). Das ist der Kernwert des Patterns und der Grund, warum die große Mehrzahl der Dateien selbsterklärend ist. Nicht verdichten.
4. **Tier↔Gruppen-Schnitt quer zu Themenregalen** — konstitutiv fürs Pattern; die Tiers als Kompositionslayer sind bereits selbstdokumentierend (reine Import-Listen). Keine File-Moves zur Angleichung (zerstört die Themen-Ordnung); nur die Namensgleichheit `core/`↔Tier `core` per README entzaubern.
5. **User-als-Features inkl. Multi-Context-Wiring** — Lehrbuch (Template `myUser/default.nix`: `nixos."${user}"` + `homeManager."${user}"` + `generic."${user}"`, HM-Injektion per `home-manager.users.<user>.imports`). Nicht vereinheitlichen.
6. **Die gesamte Mechanik**: `mkFlake`+`import-tree` (eval-perf: 0,15–0,5 s — billig), Modulklassen-Disziplin, `generic`-Verwendung, mkMerge-Disziplin, offene Argumente. Nichts davon umbauen; die Compliance ist der Beweis, dass das Pattern hier trägt.
7. **Verwaiste Alternativ-Aspekte und `bootstrap.nix` als Exporte behalten** — `boot-limine`, `tui-greeter`, `yubikey-lock`, `nixos.bootstrap` sind wählbare Bibliotheks-Exporte, kein toter Code (dokumentieren, s. A6). Löschen wäre ein Rückschlag gegen die Bibliotheks-Idee.
8. **Desktop-„Trägheit" nicht strukturell adressieren** — die Strukturarbeit endet bei A2 (Eval-Last des Consumers); was am laufenden Desktop träge ist (Ghostty-Shader, DMS-Polling, Akku-Profil, dsearch), liegt inhaltlich in den Runtime-Dimensionen und ist dort bereits gerankt. Keine Struktur-Refactors „wegen Performance" jenseits von Aktion 3.
