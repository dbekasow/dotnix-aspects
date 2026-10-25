# 03: Generierten Consumer und optionales Tooling vollständig durchlaufen

**What to build:** Den Generator samt optionalem Entwicklungstooling so integrieren, dass Consumer einen generierten Flake reproduzierbar bootstrappen, evaluieren und erneut generieren können. Die ausdrücklich auswählbare Direnv-Fähigkeit nutzt die bibliotheksseitig erfasste `direnv-instant`-Abhängigkeit. Formatter, Hooks und Dev-Shell behalten klare Input- und Implementierungseigentümer und bleiben außerhalb von Feature-Export und normalem Consumer-Adapter.

**Blocked by:** [02: Feature-Discovery und Ablage nach bestätigtem Ordnungskriterium umstellen](02-feature-ownership-discovery.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] Optionale `devTools` sind separat vom normalen Adapter und vom Feature-Katalog auswählbar; Formatter, Hooks und Dev-Shell haben klar zuordenbare Inputs und Implementierungseigentümer.
- [ ] Ein explizit disposable Consumer-Fixture wählt Direnv und durchläuft Bootstrap, Generierung, Evaluation vor und nach der Generierung sowie wiederholte Generierung mit stabilen Selektionen und ohne Drift im erzeugten Flake-Text.
- [ ] Die Fixture beobachtet beabsichtigtes aktiviertes Direnv-Verhalten vor und nach der Generierung; `direnv-instant` stammt aus bibliotheksseitig erfasstem Input und nicht aus einem gleichnamigen Consumer-Root-Input. Input-Duplikatfreiheit allein ist kein Verhaltensbeleg.
- [ ] Der Lifecycle nutzt ein ausdrücklich angegebenes Wegwerfverzeichnis; Fixture-eigene Input- und Lock-Schreibvorgänge sind zulässig. Er nutzt niemals das derzeitige sibling-basierte Skript-Default oder einen echten privaten Consumer.
- [ ] Das bestehende Auto-follow-Verhalten bei bereits vorhandenem Zustand bleibt erhalten; es wird nicht aus Stilgründen geändert. Bibliotheks-Inputs und Lock-Pins bleiben unverändert.
- [ ] Evaluation und generierter Text werden als solche berichtet; aus Konstruktion einer Aktivierungsableitung wird kein Build- oder Laufzeitbeweis abgeleitet.
