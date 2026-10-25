# 18: Desktop-Anwendungen mit ausdrücklich gewählten Integrationen verwenden

**What to build:** Bestehende Desktop-Anwendungen als einzeln nutzbare Features mit ausdrücklich ausgewählten optionalen Integrationen konsumierbar machen. Firefox, Anki, Alacritty, Ghostty, OnlyOffice, Thunderbird und weitere vorhandene Anwendungen funktionieren ohne implizite Desktop-Backend-Auswahl.

**Blocked by:** [14: Niri-Unterstützung und Benutzerkonfiguration trennen](14-niri-scope-separation.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] Vorhandene Desktop-Anwendungen einschließlich Firefox, Anki, Alacritty, Ghostty, OnlyOffice und Thunderbird bleiben einzeln auswählbar; App-State/Persistence-Beiträge bleiben beim Feature.
- [ ] Firefox-Niri-Integration ist ausdrücklich featurelokal auswählbar und erweitert nicht global das Niri-Feature.
- [ ] Firefox ohne ausgewählte Niri-Unterstützung bleibt als App nutzbar; kein Backend wird stillschweigend aktiviert.
- [ ] Handy bleibt im Eigentum von Ticket 13 und wird nicht doppelt als App-Integration implementiert; Fonts und graphische Basis bleiben bei Ticket 14.
- [ ] Normale native Optionen bleiben überschreibbar; es entsteht kein globales App-/Backend-Integrationsframework.
