# Keep machine and personal selections explicit

Status: accepted target design; not implemented. Implementation requires separate approval.

Optional profiles remain domain-oriented conveniences as established in
[ADR 0002](0002-occupant-composition-stays-consumer-owned.md). Their convenience
must not hide a machine's boot and storage policy or an occupant's personal
application and agent selections.

- `host.workstation` must not select a bootloader, disk layout, generic
  persistence, or root reset. The consumer selects these independently for
  the concrete host. Performance tuning, geolocation, and YubiKey support
  also become explicit host selections rather than workstation members.
  The remaining bundle is `boot-baseline`, `bluetooth`, `network`,
  `network-wifi`, `pipewire`, and `power`.
- `host.power` must be reusable without assuming Intel thermald, a particular
  resume device, or a forced deep-sleep mode. Keep Upower, power-profiles-daemon,
  and the existing diagnostic tools; leave sleep, power-key, lid, and battery
  actions to platform defaults or explicit host settings. Do not introduce
  hardware detection, a new hibernation switch, or replacement universal
  thresholds. The feature must not prescribe automatic hibernation.
  The existing `host.performance` feature remains individually selectable
  without redesigning its tuning in this effort.
- The personal Alacritty, Ghostty, Anki, and Handy combination moves to the
  consumer instead of remaining a general `home.desktop-apps` bundle.
  Individual reusable application features remain available. Remove both
  `host.desktop` and `home.desktop` rather than retaining aliases for
  `graphical`.
- AI and agent tools become explicit selections rather than implicit members
  of general terminal or development profiles. Remove `llm-agents`, `ai-tools`,
  and `repomix` from `development`, and Workmux from `term-ux`. Hunk
  (`modem-dev/hunk`) replaces Tuicr as the general review tool in `development`
  using the existing `numtide/llm-agents.nix` package source, not a new input
  or a direct nixpkgs selection. Its shared popup-menu entry is `r`, reached
  through `Prefix+o` in both Tmux and Herdr, and exists only when `home.hunk`
  is selected. Keep `cr` as a direct Hunk invocation, remove the separate
  Tmux `Prefix+r` binding, and use Hunk defaults rather than attempting to
  port Tuicr-specific comment types and export settings.
- Workmux is a Tmux-specific selection, not part of a Herdr-only setup.
  Document its Tmux prerequisite; do not add an assertion or automatically
  enable Tmux. Once Workmux is no longer included transitively, remove its
  exclusion from `terminal-herdr` so an explicit selection is not silently
  discarded. The variant still excludes Tmux and Sesh.
- The consumer template is a small, concrete, coherent reference configuration.
  It explicitly selects Ghostty, Firefox, and Thunderbird. Its application
  launch bindings must match these selections; it is not merely a disconnected
  set of selection examples. It keeps an explicit Btrfs/LUKS, bootloader,
  and persistence example, but root reset becomes a documented opt-in rather
  than a default selection. Application-specific Niri launch bindings belong
  to the consumer; the reusable Niri feature retains general window,
  workspace, and session keys. Geolocation, YubiKey support, and performance
  tuning are documented optional additions, not template defaults.

This favors visible consumer choices over shorter include lists. In particular,
it revises the personal application remainder approved by the earlier
[profile namespace redesign](../../.scratch/profile-namespace-redesign/spec.md).
Other application settings, including Firefox homepages, extensions, and
Bitwarden policy, remain unchanged in this effort. Consumer migration is
separate: a host that needs the previous hibernation behavior must declare
its native device and power policy explicitly when adopting this design.

The design supports a workstation without storage assumptions, a graphical
family home without development or agent tools, separate Tmux and Herdr
workflows with the same selected review popup, and a headless server without
workstation features. These are target contracts, not claims of runtime
verification. The existing template-build and Btrfs-VM verification gaps remain
open; this decision does not authorize activation or implementation.
