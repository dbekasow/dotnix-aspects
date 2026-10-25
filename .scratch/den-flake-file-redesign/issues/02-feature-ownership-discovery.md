# 02: Feature-Discovery und Ablage nach bestätigtem Ordnungskriterium umstellen

**What to build:** Den bestehenden Fähigkeitenbestand mechanisch nach bestätigter Feature-Eigentümerschaft ordnen und Discovery so begrenzen, dass Feature-Einstiege von Producer-, Adapter- und Tooling-Code unterscheidbar bleiben. Gate G ist geschlossen: direkter Feature-Katalog, kleine Fähigkeiten dürfen Einzeldateien bleiben, komplexe Fähigkeiten halten Varianten, Integrationen und Hilfen lokal. Keine neuen thematischen Kategorien und keine Spiegelung von Host-, Home- oder Account-Auswahlen in der Ablage.

**Blocked by:** [01: PipeWire als vollständige Referenz über den neuen Bibliotheks-Einstieg](01-pipewire-reference-adapter.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] Die vorhandenen Features bleiben als öffentlicher Fähigkeitenbestand semantisch erhalten; Zuordnung folgt konkreter Feature-Eigentümerschaft, nicht einer erfundenen Mail-, Container-, Audio- oder Web-Themenhierarchie.
- [ ] Kleine Features bleiben jeweils in einer Datei möglich. Mehrteilige Features halten Varianten, optionale Integrationen und Helfer bei ihrem Eigentümer; keine erzwungene Datei-pro-Rolle-Aufteilung.
- [ ] Source-Discovery, Adapter/Producer-Zusammenbau und optionales Tooling bleiben getrennte Verantwortungen. Consumer-Code importiert nicht pauschal den Producer-Wald.
- [ ] Discovery dokumentiert die tatsächlich gepinnte import-tree-Regel: Verzeichnisscans schließen relative `/_`-Pfade standardmäßig aus; explizite Dateien und Wurzeln sowie ersetzende `initFilter`-Konfigurationen können diese Vorgabe umgehen. `default.nix` kapselt keinen rekursiven Scan.
- [ ] Öffentliche Namespace-Namen werden explizit festgelegt und nicht aus Dateinamen oder Verzeichnispfaden abgeleitet. Es entsteht kein neues Registry- oder Taxonomie-DSL.
- [ ] Reine Ablageänderungen erhalten vorhandene Selektionen ohne Alias- oder Kompatibilitätsversprechen und erzwingen weder neue Tests noch eine Feature-Matrix.
