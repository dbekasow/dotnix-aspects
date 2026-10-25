# 20: Accept the integrated consumer and actual project gates

**What to build:** Complete acceptance of the integrated consumer composition with host-only and multiuser selections. Evidence must distinguish actual evaluation, build, and runtime boundaries; public feature and profile selections remain usable without private consumer changes or live activation.

**Blocked by:** [15: Run DMS and Noctalia for different users](15-per-user-desktop-shells.md), [16: Configure greeters without deriving a user home](16-explicit-greeter-resources.md), [19: Offer existing profiles as optional role-pure compositions](19-role-pure-profiles.md).
**Status:** ready-for-agent
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [ ] Integrated checks cover host-only use without Home Manager, individual feature/optional profile selections, and a multiuser composition with explicitly selected DMS, Noctalia, and greeter cases.
- [ ] Actually run existing manual broad, headless, and Niri/DMS evaluations and the affected template build; add Formatter and root `flake check` as appropriate. Root `flake check` alone does not prove these manual evaluations or standalone VM checks.
- [ ] Reuse the generator lifecycle from ticket 03; do not duplicate it as a second job. Connect each necessary regression once to an appropriate existing check path.
- [ ] Distinguish evaluation, build, and runtime results; make no runtime claims from evaluation and perform no live activation.
- [ ] Cover the full existing capability set; leave private consumer files untouched and preserve source inputs/lock pins.
- [ ] Update only necessary current child-facing documentation during this implementation. Do not close or rewrite the canonical spec or parent ticket.
