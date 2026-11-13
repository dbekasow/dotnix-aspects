# Herdr popup menu (prefix+o)

Status: ready-for-agent

## Problem Statement

The occupant launches TUI tools (lazygit, k9s, dua, bottom, …) through herdr
popup keybindings. Because herdr reserves the bare `prefix+letter` space for
its own actions, the library had to mangle every launcher into alt/shift
chords (`prefix+alt+b`, `prefix+alt+g`, `prefix+shift+s`, …). These chords are
hard to remember, hard to type, and grow with every launcher. The tmux feature
already solved this with a `prefix+o` display-menu; herdr has no native
equivalent (no key sequences, no which-key, no user-definable menu mode in
0.9.5).

## Solution

`prefix+o` opens a small herdr popup showing every available tool with its
dispatch key. One further keypress launches the chosen tool in that same
popup; Escape or an unknown key closes the menu. The per-tool chords
disappear — the menu is the single entry point, mirroring the tmux experience.

## User Stories

1. As an occupant, I want `prefix+o` to open a tool menu, so that I can reach
   every TUI tool from one memorable entry.
2. As an occupant, I want the menu to show each tool's dispatch key and name,
   so that I can discover what is available without memorizing chords.
3. As an occupant, I want a single keypress after the menu to launch the chosen
   tool, so that launching takes exactly two keystrokes.
4. As an occupant, I want the launched tool to run in a popup, so that my tab
   and pane layout stays untouched.
5. As an occupant, I want the popup to close when the tool exits, so that I
   return to my work automatically.
6. As an occupant, I want Escape to close the menu without launching anything,
   so that I can back out at any time.
7. As an occupant, I want an unknown keypress to close the menu, so that a
   typo never leaves me stuck.
8. As an occupant, I want dispatch keys to be case-sensitive, so that related
   tools can share a letter (b/B).
9. As an occupant, I want the menu sorted by dispatch key, so that tools sit
   in a stable, scannable order.
10. As an occupant, I want tools that are not available on the machine to be
    absent from the menu, so that the menu only offers what works.
11. As a consumer, I want the menu content to be exactly the enabled popup
    launchers, so that the menu and the enable gates never drift apart.
12. As a consumer, I want enable gates evaluated against my real home-manager
    configuration, so that conditional tools appear and disappear correctly
    per machine.
13. As a consumer, I want the same dispatch keys in the tmux menu and the
    herdr menu, so that muscle memory transfers between multiplexers.
14. As a consumer, I want the tmux feature unaffected apart from reading the
    shared dispatch key, so that tmux-based machines keep their behavior.
15. As a consumer, I want duplicate dispatch keys to fail evaluation, so that
    menu collisions surface at build time instead of at keypress time.
16. As a consumer, I want the old per-tool herdr chords removed, so that the
    keymap carries one entry instead of a dozen mangled chords.
17. As a library maintainer, I want a single dispatch-key field per launcher
    record, so that consumers don't maintain per-multiplexer key maps.
18. As a library maintainer, I want the geometry trade-off documented with its
    upgrade path, so that a future per-tool-geometry design doesn't
    re-research from zero.
19. As a library maintainer, I want the menu mechanism isolated in the herdr
    consumer, so that other multiplexer consumers stay untouched by menu
    logic.

## Implementation Decisions

- **Mechanism**: herdr 0.9.5 has no key sequences, no which-key, and no
  `popup.open` socket method. The menu is therefore one custom command
  keybinding of type `popup` at `prefix+o` (geometry 90%×85%, description
  `popups`) running a Nix-generated script. Verified against the herdr 0.9.5
  config reference, socket API, and installed binary.
- **Menu script**: generated from the launcher records at consumer evaluation
  time. It prints `key → name` lines sorted by key, reads one keypress
  case-sensitively, and execs the matching launcher command inside the same
  popup. Escape or an unknown key exits the script, which closes the popup.
- **Content**: the enable-gated popup launcher records — the same records and
  the same gates the direct bindings used. Gates stay closures evaluated in
  the herdr consumer, where `config` is the user's real home-manager
  configuration (the popup-seam lesson from 2026-11).
- **Record schema**: the per-multiplexer key map is replaced by a single
  dispatch-key field per launcher record. The tmux consumer binds
  `prefix+<key>`; the herdr menu dispatches on `<key>`.
- **Replacement**: the herdr consumer emits exactly one command binding (the
  menu). Per-tool herdr chords and the record field that carried them are
  removed.
- **Menu key**: `prefix+o` is fixed, not configurable (YAGNI).
- **Displaced default**: `prefix+o` is herdr's default
  `open_notification_target`. The custom command binding is expected to win;
  precedence is verified on first switch. Fallback: rebind the notification
  action or move the menu key.
- **Duplicate keys**: asserted at evaluation time in both consumers (the tmux
  consumer already has this assertion; the herdr consumer gains the same).
- **herdr-only**: menu logic lives in the herdr consumer; the tmux consumer
  only migrates to the renamed dispatch-key field.
- **Docs**: no glossary or ADR — implementation vocabulary, not domain model,
  and the decision is reversible. The research report records the why and
  the upgrade path.

## Testing Decisions

- **No new automated coverage** (explicit consumer decision). A good test here
  would only assert external behavior (which bindings exist, what the script
  dispatches); the consumer prefers a manual check instead.
- **Manual verification on switch**: menu opens at `prefix+o`; every enabled
  tool dispatches and runs in the popup; Escape and unknown keys close the
  menu; the displaced `open_notification_target` behavior is confirmed.
- **Existing suite stays green**: composition tests that reference replaced
  behavior migrate minimally — the per-tool `keys.command` assertions (k9s
  gating) retarget the generated menu script's content (same eval seam, same
  gating semantics, moved target), and the custom-record override test moves
  to the new dispatch-key field. No new assertions are added.
- **Prior art**: the existing herdr composition assertions and the tmux
  duplicate-key assertion in the composition test suite.

## Out of Scope

- Per-tool popup geometry. The plugin + raw-socket path exists (documented in
  the research report) but costs imperative plugin linking, a socket client
  dependency, and a dispatch race; revisit when herdr stable exposes popup
  placement and geometry on the plugin pane CLI.
- Any tmux menu change beyond reading the renamed dispatch-key field.
- Menu key configurability.
- herdr native key sequences (upstream; would replace the script wholesale).
- Preview-channel herdr features.
- New automated test infrastructure.

## Further Notes

- Research report: `docs/plans/herdr-menu-plugin-research.md` — marketplace
  scan (no reusable plugin), the plugin-path costs, the 0.9.5 CLI gap
  (`herdr plugin pane open` lacks popup placement), and the upgrade trigger.
- The `ui_busy` constraint (dispatch must happen after the menu popup closes)
  is irrelevant for the chosen path — the tool execs inside the menu popup —
  but binds the upgrade path.
- Muscle-memory break: the four live chords (shell, nix-graph, dua, scratch)
  disappear. The latent `prefix+shift+s` double-binding (scratch popup vs.
  herdr settings) dissolves with them.
- The menu binding rides the existing mutable-settings merge into herdr's
  writable config.toml.
