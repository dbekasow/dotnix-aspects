# 10: Popup-Katalog mit beiden Backends verwenden

**What to build:** Popup-Launcher mit einer autoritativen, bibliothekseigenen Datenquelle und expliziter Backend-Auswahl nutzbar machen. Tmux- und Herdr-Renderer erhalten dieselben Launcher-Daten, ohne Zellij/Sesh-Fähigkeiten aus deren Eigentümerschaft zu ziehen.

**Blocked by:** [02: Feature-Discovery und Ablage nach bestätigtem Ordnungskriterium umstellen](02-feature-ownership-discovery.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] Launcher-Datensätze halten Befehl, Größe und nötige Backend-Schlüssel einmalig; Tmux- und Herdr-Renderer übersetzen diese Quelle statt parallele vollständige Pflicht-Mappings zu pflegen.
- [ ] Durch native Home-Manager-Optionen aktivierte Programme bleiben auffindbar, auch wenn kein gleichnamiges Aspect ausgewählt wurde.
- [ ] Fehlt ein Backend-Schlüssel, lässt der Renderer den Kandidaten aus und gibt eine handlungsfähige Diagnose aus; kein ungeprüfter Lookup und kein erzwungenes Feature.
- [ ] Bestehendes Scratch-, Directory- und Menüverhalten sowie gewöhnliche native Overrides bleiben erhalten.
- [ ] Zellij und Sesh behalten ihre bestehende Eigentümerschaft; die Backend-Auswahl setzt keine Fish-Auswahl voraus, wenn absolute Programmdateien verfügbar sind.
