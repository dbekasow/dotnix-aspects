# 12: Git, Helix und Entwicklungswerkzeuge ohne Host-Nebenwirkungen verwenden

**What to build:** Entwicklungsfähigkeiten einzeln und ohne unerwünschte Host-Aktivierung konsumierbar machen. Git-/VCS-Werkzeuge, Helix samt Sprachkonfiguration sowie Automation, Kubernetes und übrige vorhandene Entwicklungswerkzeuge bleiben beim jeweiligen Feature-Eigentümer.

**Blocked by:** [02: Feature-Discovery und Ablage nach bestätigtem Ordnungskriterium umstellen](02-feature-ownership-discovery.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] Git, Git-Aliases, GitHub CLI, Lazygit, Delta und Difftastic behalten eigenständige Auswahlen; ein bereits vorhandener Host-Git-Anteil bleibt ausdrücklich wählbar.
- [ ] Helix, Helix-Keys und vorhandene Bash/Fish/JSON/Just/Markdown/Nix/Python/Text/TOML/YAML-LSP-Konfigurationen bleiben nutzbar, ohne eine verpflichtende Sprach-Matrix.
- [ ] Bacon, Just, Watchexec, Kubernetes und übrige vorhandene DevOps-/Automation-Fähigkeiten bleiben konsumierbar.
- [ ] Eine Home-Auswahl aktiviert weder Docker noch Nix-LD als versteckte Host-Voraussetzung; Host-Facetten bleiben explizite Host-Auswahlen.
- [ ] Native Optionen bleiben überschreibbar; kein Development-Profil ist für ein einzelnes Werkzeug erforderlich und keine per-Sprache-Testmatrix wird eingeführt.
