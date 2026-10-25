# 16: Greeter ohne abgeleitetes Benutzer-Home konfigurieren

**What to build:** DMS- und Noctalia-Greeter als hostweite Fähigkeiten mit ausdrücklich bereitgestelltem Konfigurations-Home und Assets verwenden. Greeter-Ressourcen hängen weder von der alphabetischen Reihenfolge der Accounts noch von der Home-Shell-Auswahl eines Users ab.

**Blocked by:** [14: Niri-Unterstützung und Benutzerkonfiguration trennen](14-niri-scope-separation.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] Greeter-Konfiguration ist eine ausdrückliche Host-Auswahl; erforderliches Konfigurations-Home und Assets kommen über Consumer-Ressourcen statt aus einem automatisch gewählten Benutzer-Home.
- [ ] Der Greeter hängt nicht vom ersten alphabetischen Account ab und bleibt unabhängig davon, welche Home-Shell oder Desktop-Runtime einzelne Accounts wählen.
- [ ] DMS- und Noctalia-Greeter behalten vorhandene deklarative Konfiguration und Persistence-Beiträge.
- [ ] Eine Änderung an einem Greeter-Ziel verändert keine unbeteiligten Homes; Ressourcen werden über native Optionen statt Repository-Pfadannahmen übergeben.
