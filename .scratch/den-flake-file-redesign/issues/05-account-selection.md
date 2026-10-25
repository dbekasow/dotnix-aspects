# 05: Accounts ohne versteckte Shell- oder Vault-Entscheidungen konfigurieren

**What to build:** Consumer-eigene Account-Auswahl so bereitstellen, dass nur ausdrücklich ausgewählte Accounts betroffen sind und Account-Grundlagen unabhängig von deren Home-Auswahl bleiben. Normale native Account-Optionen und eine optionale integrierte Home-Manager-Nutzung bleiben möglich; Host-only-Accounts bleiben gültig.

**Blocked by:** [02: Feature-Discovery und Ablage nach bestätigtem Ordnungskriterium umstellen](02-feature-ownership-discovery.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] Der Consumer besitzt Account-Inventar und Account-Auswahlen; eine Auswahl wirkt nur auf den ausdrücklich benannten Account.
- [ ] Account-Grundlagen setzen weder blanket `host.users`-Rechte noch Default-Shell, Vault-Konventionen oder Passwortgenerator voraus.
- [ ] Account-Auswahl funktioniert unabhängig davon, ob für diesen Account Home Manager ausgewählt wird; integrierte Home-Manager-Nutzung bleibt explizit und optional.
- [ ] Native Optionen bleiben überschreibbar und eine unbeteiligte Person am selben Host bleibt unverändert.
- [ ] Passwortrezepte und Secrets/Auth liegen bei Ticket 06; Fish-Login-Shell bleibt bei Ticket 09. Keine davon wird durch Account-Grundlagen implizit aktiviert.
