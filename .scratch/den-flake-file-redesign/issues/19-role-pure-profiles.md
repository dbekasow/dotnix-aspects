# 19: Bestehende Profile als optionale, rollenreine Kombinationen anbieten

**What to build:** Alle vorhandenen Profilfähigkeiten als optionale Kombinationen bestehender Features weiter anbieten. Profile bleiben bequem benannte Auswahlmöglichkeiten, keine verpflichtenden Stufen, catch-all Features oder Eigentümer der Consumer-Entscheidungen.

**Blocked by:** [03: Generierten Consumer und optionales Tooling vollständig durchlaufen](03-consumer-generation-tooling.md), [04: Host-Basis ohne Home Manager verwenden](04-host-only-foundation.md), [05: Accounts ohne versteckte Shell- oder Vault-Entscheidungen konfigurieren](05-account-selection.md), [06: Secrets und Authentifizierung mit expliziten Consumer-Ressourcen verwenden](06-secrets-auth-resources.md), [07: Persistence unabhängig vom Btrfs-Root-Reset wählen](07-persistence-root-reset.md), [08: Docker gezielt für Host, Account und Home auswählen](08-docker-targeted-selection.md), [09: Shell und Login-Shell unabhängig auswählen](09-shell-selection.md), [10: Popup-Katalog mit beiden Backends verwenden](10-popup-backends.md), [11: Kleine CLI-Fähigkeiten unabhängig kombinieren](11-cli-feature-selection.md), [12: Git, Helix und Entwicklungswerkzeuge ohne Host-Nebenwirkungen verwenden](12-development-feature-selection.md), [13: Agentenwerkzeuge und Handy eigenständig auswählen](13-agent-handy-selection.md), [14: Niri-Unterstützung und Benutzerkonfiguration trennen](14-niri-scope-separation.md), [17: Styling mit expliziten Ressourcen pro Ziel verwenden](17-styling-resources.md), [18: Desktop-Anwendungen mit ausdrücklich gewählten Integrationen verwenden](18-desktop-app-integrations.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] Alle 19 vorhandenen Profilfähigkeiten bleiben optional und setzen sich aus einzeln wählbaren Features zusammen; weder neue Pflichtstufen noch neue Catch-all-Features entstehen.
- [ ] Jedes Profil bleibt transitiv rollenrein und überschreibt keine Consumer-Entscheidungen; Host-, Home- und Account-Auswahl bleiben explizit.
- [ ] Versteckte GUI-Pinentry-Overrides des bisherigen Desktop-Shell-Profils werden der zuständigen Secrets/Auth-Feature-Auswahl aus Ticket 06 zugeordnet, nicht in Profilimplementierung dupliziert.
- [ ] Bestehende graphische Basisprofile wählen DMS-/Noctalia-Runtime oder Greeter nicht stillschweigend; Consumer wählen diese explizit. Ausdrücklich gewählte rollenreine Shell-Profile dürfen weiterhin Fish oder Nushell kombinieren; Tickets 15 und 16 müssen dafür nicht abgewartet werden.
- [ ] Profile bleiben reine optionale Kombinationen; Einzel-Features funktionieren weiterhin ohne Profil.
