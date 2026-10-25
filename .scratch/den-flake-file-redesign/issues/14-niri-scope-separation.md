# 14: Separate Niri support from user configuration

**What to build:** Separate Niri host support from per-user Niri selection and make shared graphical foundation capabilities explicitly consumable. This includes Niri bindings, fonts, GNOME services, XDG and portals, Thunar, and clipboard support, without requiring DMS or Noctalia.

**Blocked by:** [05: Configure accounts without hidden shell or vault choices](05-account-selection.md).
**Status:** claimed
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] Niri host prerequisites and per-user Niri configuration with its bindings are separately selectable; user selection does not silently activate host behavior.
- [ ] Graphical foundation capabilities such as fonts, GNOME services, XDG, XDG portals, Thunar, and clipboard support remain available without selecting a desktop shell.
- [ ] Upstream dependencies remain captured by the responsible feature; actual host prerequisites are explicit rather than activated by home selection.
- [ ] Add no global per-user Polkit runtime choice and require no DMS/Noctalia selection.
- [ ] Native options remain overridable; styling remains optional under ticket 17. Desktop shell runtime and greeter resources belong to tickets 15 and 16.
