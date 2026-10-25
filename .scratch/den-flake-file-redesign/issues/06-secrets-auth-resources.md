# 06: Secrets und Authentifizierung mit expliziten Consumer-Ressourcen verwenden

**What to build:** Vorhandene Secrets- und Authentifizierungsfähigkeiten einzeln und mit klarer Rollen- und Ressourcenverantwortung konsumierbar machen. Dazu gehören Age/Age-Rekey, optionale Passwortgenerierung, Zertifikate, SSH, GnuPG/GPG-Agent, rbw sowie YubiKey- und YubiKey-PAM-Unterstützung.

**Blocked by:** [05: Accounts ohne versteckte Shell- oder Vault-Entscheidungen konfigurieren](05-account-selection.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] Consumer liefern benötigte Ressourcen über native Optionen; Bibliotheksfeatures raten keine Repository-Pfade und übergreifen nicht implizit Host-, Account- oder Home-Grenzen.
- [ ] Host-Authentifizierung und User-Identität bleiben unabhängig auswählbar; ein Ziel kann eine davon wählen, ohne die andere mitzuziehen.
- [ ] Age/Age-Rekey, Passwortgenerierung, Zertifikate, SSH, GnuPG/GPG-Agent, rbw, YubiKey und YubiKey-PAM behalten ihre vorhandenen optionalen Fähigkeiten.
- [ ] GUI-Pinentry-Integration gehört zur passenden Feature-Eigentümerschaft und wird nicht durch versteckte Profil-Overrides erzwungen.
- [ ] Prüfungen verwenden nicht geheime Fixture-Werte; es gibt keine Bereitstellung echter Secrets oder Credentials und kein neues Ressourcen-Registry.
- [ ] Keine künstliche Abhängigkeit von Generator-Tooling oder Desktop-Unterstützung; shell-spezifische Integrationen bleiben bei ihren Eigentümern.
