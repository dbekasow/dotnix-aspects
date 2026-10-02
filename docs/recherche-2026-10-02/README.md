# Recherche 2026-10-02: Struktur · Wartbarkeit · Performance

Vollständige Recherche zum Stand `ac7724c` (Branch `refactor/public-release`).
Method: 10 Researcher (je Dimension) → 10 Orakel (adversarial, mit
Widerlegungen) → 6 Querschnitts-Gutachten → 3 Strategiepapiere → Judge →
Synthese. Researcher-Thesen, die der Orakel-Prüfung nicht standhielten, sind
in BERICHT.md §9 dokumentiert.

**Einstieg: [`BERICHT.md`](BERICHT.md)** — Executive Summary, Struktur-Verdikt,
Wartbarkeits-Top-10, Trägheits-Root-Causes + 60-Min-Messplan, Eval-/Rebuild-Hebel,
priorisierter Maßnahmenplan (32 Maßnahmen, ~6–8 Personentage), Strategie-Urteil,
Anti-Empfehlungen, Widerlegtes, Quellenverzeichnis.

| Ordnerinhalt             | Rolle                                                                                 |
| ------------------------ | ------------------------------------------------------------------------------------- |
| `*.md` (10, ohne Präfix) | Researcher-Berichte je Dimension                                                      |
| `oracle-*.md`            | Orakel-Gutachten (adversarial geprüft)                                                |
| `cross-*.md`             | Querschnitts-Synthesen                                                                |
| `strategy-*.md`          | Strategiepapiere (konservativ / umbau / konsolidierung)                               |
| `judge.md`               | Duell-Urteil über die Strategien                                                      |
| `BERICHT.md`             | Endbericht (Hierarchy: Orakel > Researcher, Querschnitt > Orakel, Judge > Strategien) |

Kernurteile: Pattern unschuldig, Ausführung schuldig (Vertrags-/Template-/CI-Lücken).
Trägheit: Ghostty-Shader/Blur, Akku-Profil `power-saver` ohne thermald,
DMS-Polling-Bündel, dsearch-Indexer, fastfetch pro tmux-Pane. Phase 0 zuerst:
Laptop-Konsument + Pin klären — ohne ihn wirkt kein Desktop-Fix am gefahrenen System.
