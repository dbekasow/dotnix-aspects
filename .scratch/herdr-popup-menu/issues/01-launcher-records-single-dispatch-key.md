# 01: Launcher records carry a single dispatch key

**What to build:** Every popup-launcher record declares one dispatch key (a
single character) instead of the per-multiplexer key map's tmux entry. The
tmux consumer binds each launcher as `prefix+<dispatch key>` from that field,
and its duplicate-key assertion keeps guarding it. The herdr side is untouched
in this ticket: its per-tool chords keep working off the old herdr key entry,
which survives until ticket 02. End state: the record schema is simplified,
behavior is identical everywhere, the composition suite is green.

**Blocked by:** None (can start immediately).

**Status:** ready-for-agent

- [x] Every launcher record carries the single dispatch-key field; the
      per-multiplexer map's tmux entry is gone; its herdr entry remains for now
- [x] The tmux consumer binds `prefix+<dispatch key>` and its duplicate-key
      assertion reads the new field
- [x] Moot (2026-11-13): the composition suite was deleted by consumer
      decision during ticket 02; it ran green over this rename first
- [x] `nix flake check` green and `nix fmt` produces no diff
