# 18: Use desktop applications with explicitly selected integrations

**What to build:** Make existing desktop applications consumable as individually usable features with explicitly selected optional integrations. Firefox, Anki, Alacritty, Ghostty, OnlyOffice, Thunderbird, and other existing applications work without implicit desktop backend selection.

**Blocked by:** [14: Separate Niri support from user configuration](14-niri-scope-separation.md).
**Status:** ready-for-agent
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] Existing desktop applications, including Firefox, Anki, Alacritty, Ghostty, OnlyOffice, and Thunderbird, remain individually selectable; app state/Persistence contributions remain with the feature.
- [ ] Firefox-Niri integration is explicitly selectable locally to the feature and does not expand the Niri feature globally.
- [ ] Firefox remains usable without selected Niri support; no backend is activated silently.
- [ ] Handy remains owned by ticket 13 and is not implemented twice as an app integration; fonts and the graphical foundation remain under ticket 14.
- [ ] Ordinary native options remain overridable; add no global app/backend integration framework.
