# 15: DMS und Noctalia für unterschiedliche Benutzer betreiben

**What to build:** DMS- und Noctalia-Runtimes samt zugehörigen Integrationen und per-User-Polkit-Agenten gezielt pro Home auswählen. Eine gemeinsame Maschine kann unterschiedliche Benutzerruntimes nutzen; echte Exklusivität gilt nur für tatsächlich inkompatible Auswahlen desselben Ziels.

**Blocked by:** [14: Niri-Unterstützung und Benutzerkonfiguration trennen](14-niri-scope-separation.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] Alice kann DMS und Bob Noctalia auf demselben Host auswählen, ohne dass eine globale Desktop- oder Home-Auswahl Dienste für den jeweils anderen User umschaltet.
- [ ] DMS, Plugins, Settings, Noctalia-Runtime und ihre Integrationen bleiben ihren jeweiligen Features zugeordnet; per-User-Polkit wird nicht global für alle Accounts aktiviert.
- [ ] Ein echter Konflikt auf demselben Ziel schlägt mit klarer Diagnose fehl; unterschiedliche kompatible Ziele werden nicht durch globale Desktop-Exklusivität blockiert.
- [ ] Vorhandene Desktop-Fixture wird gezielt zur Prüfung der Zwei-User-Komposition verwendet; statische Fundstellen werden nicht als Laufzeitbeweis ausgegeben. Keine Kombinationsmatrix.
- [ ] U2F-Ressourcen werden über native Optionen und nicht geheime Fixture-Werte bereitgestellt; kein geratenes Consumer-Pfadformat und keine zwingende Abhängigkeit von Ticket 06 für nicht sicherheitsgebundene Grundfälle.
