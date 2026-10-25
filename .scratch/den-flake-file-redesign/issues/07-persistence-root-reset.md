# 07: Persistence unabhängig vom Btrfs-Root-Reset wählen

**What to build:** Generische Persistence-Klassen und -Weiterleitung getrennt von der expliziten Btrfs-Root-Reset-Maschinenpolitik konsumierbar machen. Beide Fähigkeiten und ihre bestehenden Beiträge bleiben verfügbar, aber keine wird durch die andere oder durch reine Vertragsregistrierung aktiviert.

**Blocked by:** [02: Feature-Discovery und Ablage nach bestätigtem Ordnungskriterium umstellen](02-feature-ownership-discovery.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] Generische Persistence ist für ausdrücklich ausgewählte Ziele ohne Home Manager und ohne angenommene Disk- oder Boot-Topologie nutzbar.
- [ ] Btrfs-Root-Reset bleibt separat wählbare Maschinenpolitik; keine generische Persistence-Auswahl aktiviert Reset, Disko, Boot- oder Rollback-Verhalten.
- [ ] Ein opt-in auf einem Ziel verändert weder nicht ausgewählte Ziele noch andere User; vorhandene Klassen-/Policy-Beiträge bleiben wirksam.
- [ ] Globale Klassenmetadaten dürfen durch den Adapter registriert werden, bleiben aber inert, bis Consumer Persistence ausdrücklich wählen.
- [ ] Bestehende Klassen-, Policy- und VM-Evidenz wird zielgerichtet wiederverwendet. Die eigenständige Btrfs-VM wird nicht als Teil des Root-`flake check` ausgegeben.
