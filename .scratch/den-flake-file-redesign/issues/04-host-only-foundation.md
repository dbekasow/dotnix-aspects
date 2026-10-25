# 04: Host-Basis ohne Home Manager verwenden

**What to build:** Host-seitige Systemfähigkeiten als einzeln wählbare Consumer-Auswahl bereitstellen, einschließlich Boot, Disko, Netzwerk, Bluetooth, Energie, Performance, Geolocation, Journald, Locale, Security, Systempaketen und der bestehenden Nix-LD-Hostfähigkeit. Host-only-Konfiguration muss ohne Home Manager gültig bleiben; vorhandene Home-Seiten gemeinsamer Nix-Werkzeuge bleiben ausdrücklich verfügbar.

**Blocked by:** [02: Feature-Discovery und Ablage nach bestätigtem Ordnungskriterium umstellen](02-feature-ownership-discovery.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] `boot`, `boot-systemd`, `disko`, `network`, `network-wifi`, `bluetooth`, `power`, `performance`, `geolocation`, `journald` und `nix-ld` sind als explizite Host-Fähigkeiten auswählbar.
- [ ] `locale`, `security`, `system-packages`, `nix`, `nur` und `nh` bleiben einzeln konsumierbar; native Substituter- und Key-Defaults gehören zur Nix-Fähigkeit, und existierende Home-Facetten der Nix-Werkzeuge gehen nicht verloren.
- [ ] Ein Host kann die ausgewählten Host-Fähigkeiten ohne integrierten Home Manager evaluieren; Home-Konfiguration wird nicht als versteckte Voraussetzung aktiviert.
- [ ] Native Optionen überschreiben Bibliotheksdefaults. Ein unbeteiligter Host bleibt von einer zielgerichteten Host-Auswahl unverändert.
- [ ] Disko bleibt eine deklarative Fähigkeit; keine Disk-Operationen, Boot-Neugestaltung oder implizite persönliche Systeminventare werden eingeführt. Graphische Basis bleibt bei Ticket 14, Styling bei Ticket 17 und Secrets/Auth bei Ticket 06.
