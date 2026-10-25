# 20: Integrierten Consumer und tatsächliche Projekt-Gates abnehmen

**What to build:** Die integrierte Consumer-Komposition mit Host-only- und Multiuser-Auswahlen final abnehmen. Belege müssen tatsächliche Evaluation, Build und Laufzeitgrenzen unterscheiden; öffentliche Feature- und Profil-Auswahlen bleiben nutzbar, ohne private Consumer-Änderung oder Live-Aktivierung.

**Blocked by:** [15: DMS und Noctalia für unterschiedliche Benutzer betreiben](15-per-user-desktop-shells.md), [16: Greeter ohne abgeleitetes Benutzer-Home konfigurieren](16-explicit-greeter-resources.md), [19: Bestehende Profile als optionale, rollenreine Kombinationen anbieten](19-role-pure-profiles.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] Integrierte Prüfungen decken Host-only ohne Home Manager, einzelne Feature-/optionale Profil-Auswahlen und Multiuser-Komposition mit ausdrücklich ausgewählten DMS-, Noctalia- und Greeter-Fällen ab.
- [ ] Bestehende manuelle Broad-, Headless- und Niri/DMS-Evaluationen sowie den betroffenen Template-Build tatsächlich ausführen; Formatter und Root-`flake check` passend ergänzen. Root-`flake check` allein beweist diese manuellen Evaluationen oder eigenständige VM-Prüfungen nicht.
- [ ] Den Generator-Lifecycle aus Ticket 03 wiederverwenden, nicht als zweiten Job duplizieren. Notwendige Regressionen werden einmal an einen passenden bestehenden Prüfpfad angeschlossen.
- [ ] Ergebnisse unterscheiden Evaluation, Build und Laufzeit; keine Laufzeitbehauptung aus Evaluation und keine Live-Aktivierung.
- [ ] Der vollständige bestehende Fähigkeitenbestand ist abgedeckt; private Consumer-Dateien bleiben unberührt und Quell-Inputs/Lock-Pins unverändert.
- [ ] Nur nötige aktuelle Child-facing-Dokumentation wird während dieser Implementierung angepasst. Kanonische Spec und Eltern-Ticket werden weder geschlossen noch umgeschrieben.
