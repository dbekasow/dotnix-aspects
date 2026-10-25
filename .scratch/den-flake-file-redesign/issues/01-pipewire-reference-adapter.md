# 01: PipeWire als vollständige Referenz über den neuen Bibliotheks-Einstieg

**What to build:** Eine Consumer-Komposition, die PipeWire als erste vollständige Referenz durch den neuen nativen Rollen-Katalog und den normalen Adapter nutzbar macht. Der Adapter registriert Den, die eine `dotnix`-Namespace und Bibliotheksverträge wie Popup-Quirk und passende Persistence-Klassenmetadaten, aktiviert aber keine Programme, Dienste, Home-Manager-Konfiguration oder Persistence. Die Namespace allein registriert keine Quirks; optionale Entwicklungstools bleiben separat. Eine Host-only-Auswahl bleibt ohne Home Manager gültig.

**Blocked by:** None (can start immediately).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] PipeWire ist über die öffentliche Host- und Home-Auswahl verwendbar; Home PipeWire zieht transitiv weder NixOS-, Account-Verhalten noch Host-Provider ein.
- [ ] Ein expliziter integrierter Home-Manager-Brückenschritt erhält getrennte Rollen. Eine reine Host-Konfiguration kann denselben Bibliothekseinstieg ohne Home Manager evaluieren.
- [ ] Namespace-Import allein bleibt inert und registriert keinen Quirk; der normale Adapter registriert benötigte globale Verträge, ohne Feature-Verhalten zu aktivieren.
- [ ] Der öffentliche Consumer-Einstieg schließt die bekannte user-only-Host-Aktivierung (#694): ausgewählte User- und Host-Ziele wirken nur auf ihre Auswahl; ein unbeteiligter User und Host bleiben unverändert.
- [ ] Ein gewöhnlicher nativer Consumer-Override funktioniert. Die Referenz belegt Input-Eigentum ohne dedizierten externen PipeWire-Input und mit Consumer-Fixture sowie bibliotheksseitig erfasster Impermanence-Abhängigkeit; bestehende Persistence-Beiträge bleiben verfügbar.
- [ ] Eine notwendige Regression wird einmal an einen passenden bestehenden Prüfpfad angeschlossen. Kein neues Varianten- oder Deklarationsspiegel-Matrix.
