# 09: Shell und Login-Shell unabhängig auswählen

**What to build:** Fish und Nushell so aufteilen, dass Host-Voraussetzung, Account-Login-Shell und Home-Konfiguration unabhängig wählbar bleiben. Zugehörige Shell-UX wie Atuin, Carapace, Starship, FZF, Skim und Zoxide bleibt eigenständig kombinierbar.

**Blocked by:** [05: Accounts ohne versteckte Shell- oder Vault-Entscheidungen konfigurieren](05-account-selection.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] Fish- und Nushell-Home-Konfigurationen lassen sich ohne automatische Account-Login-Shell-Auswahl aktivieren; die Login-Shell wird nur für ausgewählte Accounts gesetzt.
- [ ] Erforderliche Host-Pakete/Voraussetzungen sind separat von User- und Home-Auswahl; hostseitige Aktivierung trifft keine unbeteiligten Accounts.
- [ ] Atuin, Carapace, Starship, FZF, Skim und Zoxide behalten ihre vorhandenen auswählbaren Fähigkeiten und werden nicht pauschal durch die Basisshell aktiviert.
- [ ] Completions, Prompt- und Navigationsverhalten bleiben für vorhandene Shell-Kombinationen nutzbar; native Optionen überschreiben Defaults.
- [ ] Shell-Auswahl braucht weder Popup-/Multiplexer-Auswahl noch Secrets/Vault-Konventionen.
