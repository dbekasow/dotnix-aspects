# 03: Make desktop applications and launch bindings consumer-owned

**What to build:** Give consumers a clear graphical foundation and explicit application choices instead of a personal remainder bundle. Make the reference template supply the applications its own launch keys advertise.

**Blocked by:** [01: Restore executable consumer contract checks](01-restore-consumer-contract-checks.md).

**Status:** resolved

**Spec:** [Canonical specification](../spec.md).

**Spec coverage:** User stories 9, 10, 26, 28, 29, 36, and the application-selector migration part of 37.

**Authorization:** Publication is not implementation approval. Obtain a separate execution instruction before changing production code or tests.

**Test proportionality:** Acceptance criteria and user stories are contracts, not instructions to create one test each. Reuse existing fixtures and assertions; add only a minimal behavior check for a named regression risk that is not already covered, and state that gap briefly in the result. No duplicate coverage matrix, whole-configuration snapshots, source-text assertions, mocks of the Nix/Den module system, or additional UI/VM/runtime test layers. If those heavier techniques seem necessary, request separate approval rather than expanding this ticket. Preserve existing meaningful checks.

Extend existing Niri/template outputs with the few assertions needed for selection and launch-key coherence. Do not create per-application suites, desktop automation, or application/occupant cross-products.

- [x] Retire home.desktop-apps, host.desktop, and home.desktop with no compatibility aliases. Keep both graphical selectors, individual application features, and the office, browsers, and mail domain bundles.
- [x] Update every affected active library-owned composition, executable example, and test in this slice, so removing the selectors does not leave a broken intermediate consumer. Do not rewrite historical specs merely to eliminate old-name search matches.
- [x] Reusable Niri configuration retains general window, workspace, and session bindings but no fixed application launch choices. Consumer configuration owns the terminal, browser, mail, and any retained file-manager launch bindings.
- [x] The unmodified published template explicitly selects the individual Ghostty, Firefox, and Thunderbird home features and supplies matching launch keys. Any retained file-manager key launches an application its selections provide.
- [x] Do not select the whole office bundle or restore Alacritty, Anki, or Handy as an implicit remainder just to obtain those three applications.
- [x] Extend the regular consumer gate with final-output assertions for retired public selectors, retained graphical/application choices, general versus application-specific Niri bindings, and the template's actual program/package selections.
- [x] Demonstrate a graphical family-home composition without development or agent-tool selections. Preserve independent host/home Niri selection and existing per-user shell behavior.
- [x] Keep Firefox preferences, extensions, Bitwarden policy, other unrelated application settings, resource identities, and installed state versions unchanged.
- [x] Update the current profile inventory, composition examples, and template guidance to use graphical plus explicit applications.
- [x] Formatter, full flake checks, affected consumer/Niri checks, and real-template derivation evaluation pass. The complete integrated closure build is verified in ticket 06.

Do not migrate the separate live consumer or change its files. Do not add a new desktop framework, app integration framework, input, or lockfile change. Coordinate shared template edits with ticket 02, but do not treat that file overlap as an additional semantic blocker.

## Answer

Implemented in `2633606`, synchronized with the combined integration in `0d1f5e4` and `44d465e`, then integrated by the coordinator. Retired both desktop aliases and desktop-apps without aliases; graphical foundations and individual applications remain available. Application launch bindings are consumer-owned, and the template explicitly supplies Ghostty, Firefox and Thunderbird. Existing Niri fixtures cover catalog retirement, general/application binding separation, effective template packages and a graphical family home without development or agent selections.

Red/green commands and logs are under `/tmp/epc-03-evidence/`. After merging the other slices, formatter, full built flake check, headless, Niri/DMS (52/52 true, all original 48 names retained), terminal, review-access and conflict diagnostic checks exited 0. A fresh unchanged copied template with the real Dell hardware module evaluated its system derivation and confirmed package/launch-key coherence. The coordinator independently reran `nix fmt` and `nix flake check --no-write-lock-file --accept-flake-config` on all integrated slices (exit 0; `/tmp/epc-all-slices-format.log`, `/tmp/epc-all-slices-check.log`).

Inputs/locks, native identities, state versions and unrelated preferences are unchanged. No runtime/activation proof is claimed; the full actual template closure build remains ticket 06.
