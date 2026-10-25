# 14: Separate Niri support from user configuration

**What to build:** Separate Niri host support from per-user Niri selection and make shared graphical foundation capabilities explicitly consumable. This includes Niri bindings, fonts, GNOME services, XDG and portals, Thunar, and clipboard support, without requiring DMS or Noctalia.

**Blocked by:** [05: Configure accounts without hidden shell or vault choices](05-account-selection.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] Niri host prerequisites and per-user Niri configuration with its bindings are separately selectable; user selection does not silently activate host behavior.
- [x] Graphical foundation capabilities such as fonts, GNOME services, XDG, XDG portals, Thunar, and clipboard support remain available without selecting a desktop shell.
- [x] Upstream dependencies remain captured by the responsible feature; actual host prerequisites are explicit rather than activated by home selection.
- [x] Add no global per-user Polkit runtime choice and require no DMS/Noctalia selection.
- [x] Native options remain overridable; styling remains optional under ticket 17. Desktop shell runtime and greeter resources belong to tickets 15 and 16.

## Integration evidence

Merged `impl/den-redesign-14-niri-scope` (tip `5a122c7`) into the integration
branch as `9538fd0` with `--no-ff`; no conflicts.

Host and home split. The single `niri` selector became two independent ones:

- `dotnix.host.niri` (`features/niri/niri.nix`, NixOS class) enables
  `programs.niri` with the Niri NixOS module and the `niri-unstable` package. No
  home effect.
- `dotnix.home.niri` (Home Manager class) owns Niri settings and bindings, the
  `homePersistence` contribution, and the window rules in
  `features/firefox/firefox.nix`. It imports Niri's Home Manager options provider
  only when the host has not already supplied it, and it does not enable NixOS
  Niri.

The `desktop-shell` profile now carries graphical foundation only: `fonts`,
`gnome-services`, `thunar`, `xdg-portals`, `clipboard`, `xdg`. Niri was removed
from its `includes`, so selecting the socket no longer pulls compositor support
or a desktop shell. The template host selects `host.niri` on the host entity and
`home.niri` in the user's includes.

Overlay-free home Niri. `programs.niri.settings.xwayland-satellite.path`
previously required the Niri overlay to define `pkgs.xwayland-satellite-unstable`,
which meant a public consumer selecting only `home.niri` failed without that
overlay. It now resolves
`pkgs.xwayland-satellite-unstable or inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.xwayland-satellite-unstable`,
the same fallback precedence pattern introduced in ticket 13: a consumer-provided
`pkgs` attribute wins, otherwise the package comes from the library-captured
`inputs.niri`. This is ordinary native override precedence, not an alias or a
second registry.

Graphical foundation without a shell. `graphicalBaseIsAvailableWithoutShell`
asserts that `fonts`, `gnome-services` (keyring), `xdg.portal`, and `thunar`
evaluate with Niri, DMS, and Noctalia all absent, while the clipboard capability
reaches the home. `socketDoesNotSelectShellOrGreeter` and
`desktopShellDoesNotSelectNiri` assert that the socket selects neither Niri nor a
shell nor a greeter.

Honest Polkit interim state. The previous host-wide suppression of
`niri-flake-polkit` inside the DMS NixOS contribution was removed, because it
switched Polkit behaviour for every user of a host as soon as Niri and DMS were
both selected. The replacement assertion is
`dmsDoesNotDisablePolkitForAllUsers`: Niri's agent stays enabled for DMS users
too. Consequently a DMS user may currently run both the Niri and DMS agents. That
coexistence is documented in `README.md` under "Polkit transition" and is
restored to conflict-free per-user agent ownership by ticket 15. No global
per-user Polkit runtime choice was added here, and nothing requires DMS or
Noctalia.

Commands and results, all run inside the integration worktree at the merge
result:

- `nix eval --impure --json --file tests/broad-compositions.nix` — 60 of 60
  `true`.
- `nix eval --impure --file tests/headless-composition.nix` —
  "headless and workstation composition checks passed".
- `nix eval --impure --json --file tests/niri-dms.nix` — 37 of 37 `true`,
  including `homeNiriWorksWithoutHostOverlay` with the Niri overlay disabled.
- `nix flake check --no-build --no-write-lock-file` — `all checks passed!`, exit 0.
- `typos --force-exclude --format brief --hidden .` — exit 0, no findings.
- `nix fmt -- --ci` — 0 files changed; `git status --porcelain` empty.
- `git diff ca6da9d..HEAD -- flake.nix flake.lock` — empty; the `flake.lock`
  sha256 equals the value in `source-lock.sha256`.

Caveat: this evidence is evaluation-only (`nix eval` plus flake-check
evaluation). No NixOS or Home Manager activation was run, so no runtime
compositor, XWayland, or Polkit behaviour is claimed.
