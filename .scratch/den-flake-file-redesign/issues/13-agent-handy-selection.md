# 13: Agentenwerkzeuge und Handy eigenständig auswählen

**What to build:** Agentenwerkzeuge und Handy als eigenständige Feature-Auswahlen konsumierbar machen. Library-eigene Inputs sowie nötige Unfree-/Overlay-Voraussetzungen bleiben explizit dem verantwortlichen Feature und Consumer zugeordnet.

**Blocked by:** [02: Feature-Discovery und Ablage nach bestätigtem Ordnungskriterium umstellen](02-feature-ownership-discovery.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] LLM-Agents, AI-Tools, Workmux, Repomix, Tuicr und Handy behalten einzeln auswählbare vorhandene Fähigkeiten.
- [ ] Erforderliche Inputs werden vom Feature erfasst; Unfree- und Overlay-Voraussetzungen sind ausdrücklich sichtbar und werden nicht durch ein globales Fixture-Overlay verschleiert.
- [ ] Handy bleibt nicht-doppelt-eigentümig zu Desktop-Anwendungsintegrationen aus Ticket 18; seine Desktop-Integration bleibt lokal wählbar und löst keinen Backend-Dienst automatisch aus.
- [ ] Eine Standalone-Auswahl erfordert keine implizite Host-Zugriffserweiterung. Statische Risikohinweise werden nicht als bereits verifizierter Laufzeitfehler oder als neue Freigabebehauptung ausgegeben.
- [ ] Vorhandene native Optionen und Feature-Grenzen bleiben erhalten; fehlende breite Agentenmatrix wird nicht durch pauschale Einzeltests ersetzt.
