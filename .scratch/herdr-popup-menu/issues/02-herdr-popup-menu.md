# 02: Herdr popup menu on prefix+o

**What to build:** `prefix+o` opens a generated herdr popup menu (90%×85%,
described as `popups`) listing the enabled launchers as `key → name`, sorted by
key. One case-sensitive keypress execs the matching launcher command inside
the same popup; Escape or an unknown key closes the menu. The herdr consumer
emits exactly this one command binding — the per-tool chords and the record
field that carried them are deleted (the contract step of the rename in
ticket 01). Enable gates keep evaluating consumer-side against the consuming
home-manager configuration. A duplicate-dispatch-key assertion guards the
menu. Existing composition assertions that referenced the replaced bindings
migrate minimally: the launcher-gating assertions retarget the generated menu
script's content, and the record-override test moves to the dispatch-key
field. The default `open_notification_target` binding displaced by
`prefix+o` is verified on first switch.

**Blocked by:** [01](./01-launcher-records-single-dispatch-key.md)

**Status:** ready-for-agent

- [ ] `prefix+o` opens the menu popup showing the enabled launchers with
      their dispatch keys, sorted by key (pending manual switch check)
- [ ] A single case-sensitive keypress launches the tool inside the popup;
      Escape or an unknown key closes the menu (pending manual switch check)
- [x] The herdr consumer emits exactly one command binding (the menu)
- [x] The old herdr key field and the per-tool chords are gone from records
      and consumer
- [x] Duplicate dispatch keys fail evaluation in the herdr consumer
- [x] The menu reflects the enable gates evaluated against the consuming
      home-manager configuration
- [x] Composition suite removed by consumer decision (2026-11-13):
      the consumer judged the eval-only composition checks not useful; no
      automated coverage replaces them. Verification is the manual switch
      check below.

## Comments

- 2026-11-13: Consumer overrode the spec's test-migration decision mid-ticket:
  `tests/broad-compositions.nix` is deleted wholesale instead of migrated.
  The suite had already run green over the finished menu change (109/109)
  before deletion, so the feature was verified once against it.
- [ ] Manual switch check recorded: dispatch works per tool, Escape/unknown
      closes, and the precedence over the displaced
      `open_notification_target` is confirmed
