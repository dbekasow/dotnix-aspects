# 11: Kleine CLI-Fähigkeiten unabhängig kombinieren

**What to build:** Vorhandene kleine terminalnahe Fähigkeiten einzeln konsumierbar halten, ohne sie zu einem neuen Themen- oder Rollenbaum zu machen. Dazu gehören Datei-, Daten-, Such-, Monitoring- und Nix-Werkzeuge sowie Aerc und Maildir; ihre bestehenden State-Beiträge bleiben beim jeweiligen Eigentümer.

**Blocked by:** [02: Feature-Discovery und Ablage nach bestätigtem Ordnungskriterium umstellen](02-feature-ownership-discovery.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] `bat`, `dua`, `dust`, `eza`, `fd`, `ouch`, `ripgrep`, `ripgrep-all`, `sd`, `fx`, `jq`, `mdcat` und `xh` bleiben unabhängig wählbar.
- [ ] Monitoring-Werkzeuge einschließlich Bandwhich, Bottom, Fastfetch, Hyperfine, Procs, Rustscan, Tealdeer, Television und Tokei bleiben als eigene Fähigkeiten verfügbar.
- [ ] Nix-Werkzeuge wie Nix Index Database, Nix Search TV und Nix Tools sowie Aerc und Maildir bleiben explizit auswählbar, ohne einen neuen Mail- oder Container-Verzeichnisbaum einzuführen.
- [ ] Bestehende Persistence-/State-Beiträge bleiben featurelokal; einzelne kleine Features brauchen keine eigenen Tests oder verpflichtende Verzeichnisse.
- [ ] Shell-UX und Login-Shell gehören zu Ticket 09, Multiplexer/Popup zu Ticket 10, Secrets zu Ticket 06, Direnv zu Ticket 03 und Entwicklungswerkzeuge zu Ticket 12.
