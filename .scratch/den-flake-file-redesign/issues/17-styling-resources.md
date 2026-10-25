# 17: Styling mit expliziten Ressourcen pro Ziel verwenden

**What to build:** Stylix-Host- und Home-Auswahlen mit expliziten Consumer-Ressourcen und nativen Optionen anbieten. Styling bleibt einzeln ohne Profil wählbar, kann aber Bestandteil eines ausdrücklich gewählten rollenreinen Profils sein; Consumer-Layout oder Image-Pfade werden nicht erraten.

**Blocked by:** [02: Feature-Discovery und Ablage nach bestätigtem Ordnungskriterium umstellen](02-feature-ownership-discovery.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] Host- und Home-Styling werden pro Ziel ausdrücklich ausgewählt; erforderliche Bilder/Ressourcen werden über native Optionen bereitgestellt.
- [ ] Die Bibliothek leitet keine Ressource aus einer angenommenen Consumer-Verzeichnisstruktur oder einem festen Consumer-Pfad ab.
- [ ] Fonts und Theme-Defaults bleiben mit normalen NixOS-/Home-Manager-Optionen überschreibbar.
- [ ] Styling ist standalone ohne Profil nutzbar; einzeln gewählte Niri-, DMS- und Noctalia-Features erzwingen es nicht. Ein ausdrücklich gewähltes rollenreines Profil darf Styling bewusst kombinieren; kein versteckter globaler Default aktiviert es.
- [ ] Ein zielgerichtetes Styling verändert weder andere Hosts noch andere User-Homes.
