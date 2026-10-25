# 14: Niri-Unterstützung und Benutzerkonfiguration trennen

**What to build:** Niri-Hostunterstützung von pro-User-Niri-Auswahl trennen und gemeinsam benötigte graphische Basisfähigkeiten explizit konsumierbar machen. Das umfasst Niri-Bindings, Fonts, GNOME-Dienste, XDG und Portals, Thunar sowie Clipboard-Unterstützung, ohne DMS oder Noctalia zur Voraussetzung zu machen.

**Blocked by:** [05: Accounts ohne versteckte Shell- oder Vault-Entscheidungen konfigurieren](05-account-selection.md).
**Status:** ready-for-agent
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] Niri-Hostvoraussetzungen und pro-User-Niri-Konfiguration samt zugehörigen Bindings sind getrennt auswählbar; User-Auswahl aktiviert nicht unbemerkt Hostverhalten.
- [ ] Graphische Basisfähigkeiten wie Fonts, GNOME-Dienste, XDG, XDG-Portals, Thunar und Clipboard bleiben verfügbar, ohne eine Desktop-Shell auszuwählen.
- [ ] Upstream-Abhängigkeiten bleiben durch das zuständige Feature erfasst; echte Hostvoraussetzungen sind explizit statt durch die Home-Auswahl eingeschaltet.
- [ ] Keine globale per-User-Polkit-Laufzeitentscheidung für alle User und keine verpflichtende DMS-/Noctalia-Auswahl.
- [ ] Native Optionen bleiben überschreibbar; Styling bleibt optional bei Ticket 17. Desktop-Shell-Runtime und Greeter-Ressourcen gehören zu Tickets 15 und 16.
