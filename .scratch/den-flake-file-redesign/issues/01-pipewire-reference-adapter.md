# 01: PipeWire als vollständige Referenz über den neuen Bibliotheks-Einstieg

**What to build:** Eine Consumer-Komposition, die PipeWire als erste vollständige Referenz durch den neuen nativen Rollen-Katalog und den normalen Adapter nutzbar macht. Der Adapter registriert Den, die eine `dotnix`-Namespace und Bibliotheksverträge wie Popup-Quirk und passende Persistence-Klassenmetadaten, aktiviert aber keine Programme, Dienste, Home-Manager-Konfiguration oder Persistence. Die Namespace allein registriert keine Quirks; optionale Entwicklungstools bleiben separat. Eine Host-only-Auswahl bleibt ohne Home Manager gültig.

**Blocked by:** None (can start immediately).
**Status:** claimed
**Spec/Autorisierung:** [Kanonische Spec](../spec.md); Veröffentlichung ist freigegeben, Umsetzung braucht separate Freigabe.

## Akzeptanzkriterien

- [ ] PipeWire ist über die öffentliche Host- und Home-Auswahl verwendbar; Home PipeWire zieht transitiv weder NixOS-, Account-Verhalten noch Host-Provider ein.
- [ ] Ein expliziter integrierter Home-Manager-Brückenschritt erhält getrennte Rollen. Eine reine Host-Konfiguration kann denselben Bibliothekseinstieg ohne Home Manager evaluieren.
- [ ] Namespace-Import allein bleibt inert und registriert keinen Quirk; der normale Adapter registriert benötigte globale Verträge, ohne Feature-Verhalten zu aktivieren.
- [ ] Der öffentliche Consumer-Einstieg schließt die bekannte user-only-Host-Aktivierung (#694): ausgewählte User- und Host-Ziele wirken nur auf ihre Auswahl; ein unbeteiligter User und Host bleiben unverändert.
- [ ] Ein gewöhnlicher nativer Consumer-Override funktioniert. Die Referenz belegt Input-Eigentum ohne dedizierten externen PipeWire-Input und mit Consumer-Fixture sowie bibliotheksseitig erfasster Impermanence-Abhängigkeit; bestehende Persistence-Beiträge bleiben verfügbar.
- [ ] Eine notwendige Regression wird einmal an einen passenden bestehenden Prüfpfad angeschlossen. Kein neues Varianten- oder Deklarationsspiegel-Matrix.

## Comments

### Implementation evidence

- RED: `nix eval --impure --json --file tests/broad-compositions.nix` failed with `Broad composition fixture failed: pipewireUserOnlySelectionDoesNotEnableHost` against the original flat PipeWire selection.
- GREEN: same command passed after switching consumer to `dotnix.home.pipewire`; returned all assertions true, including no host leak, isolated host/user selections, ordinary `mkForce` override, host-only use without Home Manager, and selected WirePlumber persistence.
- Consumer fixture imports exported `flakeModules.default`; it removes `impermanence` from consumer root inputs while selecting the library-owned persistence feature. No PipeWire input or lock change.
- `nix eval --impure --file tests/headless-composition.nix` passed. `nix eval --impure --json --file tests/niri-dms.nix` exited 0 with all assertions true.
- `nix eval --no-write-lock-file --json .#flakeModules --apply builtins.attrNames` returned `["default","devTools"]`.
- `nix flake check --no-build --no-write-lock-file` passed in assigned worktree; this evaluated checks but did not build.
- `nix fmt -- --ci <changed Nix paths>` passed. `flake.lock` hash remains `6f9c06db3f8a4211e10a99998c20c27c3307d8a4eedd9a69d3fed9b0af2f0e47`.
- No build/runtime/activation or disk-operation evidence. Coordinator reported integration-worktree baseline `path 'a3xx41wf72v2d0y2qcsgnszgh52zji1v-modules' is not valid`; same check passed in this assigned worktree, so issue was not reproduced or worked around here. Ticket remains claimed pending review/integration.

### Follow-up: capture library provider

- RED: supplied minimal consumer with `library = source` and no consumer `dotnix` failed with `attribute 'dotnix' missing` at `modules/integration/default.nix:3`; same expression with `dotnix = source` returned PipeWire/Home Manager false.
- GREEN: captured provider factory now returns the adapter with library source bound by producer `inputs.self`; same consumer-key fixture returns `{"homeManager":false,"pipewire":false}`. Existing `adapterOnly` regression removes `dotnix`, adds `library = source`, and broad-compositions assertions all pass.
- `nix eval --impure --file tests/headless-composition.nix`, `nix flake check --no-build --no-write-lock-file`, and `nix fmt -- --ci` on changed Nix files passed. No input or lock changes. Ticket stays claimed pending focused review/integration.
