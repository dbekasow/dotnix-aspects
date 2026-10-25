# 08: Docker gezielt für Host, Account und Home auswählen

**What to build:** Docker-Host-Daemon, Account-Einstellungen und User-Werkzeuge als getrennte Consumer-Auswahlen anbieten, sodass Rootful- und Rootless-Nutzung erhalten bleiben. Vorhandene Subuid/Subgid- und Linger-Beiträge dürfen nicht länger ungefragt auf alle Host-Accounts verteilt werden.

**Blocked by:** [05: Accounts ohne versteckte Shell- oder Vault-Entscheidungen konfigurieren](05-account-selection.md), [07: Persistence unabhängig vom Btrfs-Root-Reset wählen](07-persistence-root-reset.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] Host-Daemon, gezielt ausgewählter Account und Home-seitige Docker-Werkzeuge können unabhängig ausgewählt werden.
- [ ] Subuid/Subgid und Linger betreffen nur den ausdrücklich ausgewählten Account statt pauschal alle Host-Accounts.
- [ ] Die tatsächlichen Fähigkeiten werden korrekt beschrieben: keine Docker-Gruppenmitgliedschaft oder behaupteten Root-Rechte, sofern sie nicht ausdrücklich separat konfiguriert sind.
- [ ] Rootful- und Rootless-Fähigkeiten bleiben verfügbar; Rootless-State/Persistence wird gezielt gewählt, nicht vom Daemon oder einer Developer-Auswahl stillschweigend aktiviert.
- [ ] Bestehendes Runtime-Verhalten wird nicht neu entworfen; ein Docker-Feature erzwingt kein Development-Profil.
