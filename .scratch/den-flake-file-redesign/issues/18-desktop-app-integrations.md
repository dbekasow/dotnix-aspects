# 18: Use desktop applications with explicitly selected integrations

**What to build:** Make existing desktop applications consumable as individually usable features with explicitly selected optional integrations. Firefox, Anki, Alacritty, Ghostty, OnlyOffice, Thunderbird, and other existing applications work without implicit desktop backend selection.

**Blocked by:** [14: Separate Niri support from user configuration](14-niri-scope-separation.md).
**Status:** resolved
**Spec/authorization:** [Canonical spec](../spec.md); publication is approved, implementation requires separate approval.

## Acceptance criteria

- [x] Existing desktop applications, including Firefox, Anki, Alacritty, Ghostty, OnlyOffice, and Thunderbird, remain individually selectable; app state/Persistence contributions remain with the feature.
- [x] Firefox-Niri integration is explicitly selectable locally to the feature and does not expand the Niri feature globally.
- [x] Firefox remains usable without selected Niri support; no backend is activated silently.
- [x] Handy remains owned by ticket 13 and is not implemented twice as an app integration; fonts and the graphical foundation remain under ticket 14.
- [x] Ordinary native options remain overridable; add no global app/backend integration framework.

## Resolution evidence

- Integrated reviewed tip `8acee44e037ca032549c0ac5c894137e09a06ac0` with conflict-free merge `2a7c0ea105247935846968e582673c3f5061d81c`. Fix `ca6c40f` was independently approved by review `aeb5e30d`; final README-only reconciliation was approved by `c1bfacac` with no findings.
- Firefox and Anki remain standalone selections without implicit Niri or styling. Firefox owns explicit `firefox.niri` and `firefox.stylix` integrations, used with the selected `home.niri` and `home.stylix` roles; host-only Niri does not generate home Niri configuration or Firefox rules.
- Consumer `pkgs.nur` takes priority; the captured library NUR input supplies the fallback without requiring a consumer overlay. Fixtures evaluate all six real extension derivation paths and Home Manager activation, preserve feature-owned persistence and unrelated homes, and retain native overrides. Other app selectors remain independent; Handy, fonts, and the graphical foundation keep their existing owners.
- Actual serial integration gates passed: broad compositions **92/92 true**; Niri/DMS **48/48 true**; headless composition; `tests/niri-dms-conflict.sh`; `nix flake check --no-build --no-write-lock-file`; `nix fmt`; `nix fmt -- --ci`; and `typos`. Logs: `/tmp/pi-ticket18-merge/`.
- Formatting left implementation unchanged. Source `flake.nix` and `flake.lock` match pre-merge contents; the lock SHA-256 matches the recorded source guard. Evidence is evaluation only, not a build or runtime claim. Merge and metadata commits bypass shared hooks command-locally; no devShell or hook setup was run.
