# Accounts, mail, and a coherent Niri/Noctalia desktop

## Purpose and approval boundary

Capture the behavior agreed during the design interview. Configuration quality
means satisfying desired behavior, not maximizing explicitly configured options.
Suitable upstream defaults are acceptable.

The user approved documenting these requirements, not implementation, activation,
dependency updates, or authentication changes. Technical feasibility remains open
where called out below. This document is not evidence of successful runtime tests.

## Ownership and current baseline

Use the existing [domain vocabulary](../../GLOSSARY.md). The aspect library owns
reusable features and optional profiles; the consumer owns occupants, concrete
accounts, configuration targets, and selections. Preserve the role catalogs from
[ADR 0001](../../docs/adr/0001-split-aspects-into-role-catalogs.md), consumer-owned
composition from [ADR 0002](../../docs/adr/0002-occupant-composition-stays-consumer-owned.md),
and primary-account identity defaults from
[ADR 0003](../../docs/adr/0003-identity-defaults-from-primary-mail-account.md).

The repository changed during the interview. The final baseline inspected was
commit `5d98a33`. [ADR 0005](../../docs/adr/0005-keep-machine-and-personal-selections-explicit.md)
now records integrated implementation: application-specific Niri launch bindings
belong to the consumer, and `host.power` no longer prescribes machine-specific
sleep, lid, or resume policy. Earlier interview observations about fixed shared
application bindings and shared sleep policy are historical, not current defects.
Recheck the source before implementation.

The schedules and authentication choices below describe an explicitly selected
consumer setup. Do not silently impose them on every library consumer or reverse
ADR 0005. Prefer existing native configuration surfaces; this document does not
authorize a new abstraction, profile, or option API.

## Scope

- A coherent consumer path from OS account selection to Home Manager selection
  and shared identity data.
- Thunderbird and aerc using common consumer-owned IMAP/SMTP account definitions.
- Niri with Noctalia: session lifecycle, app integration, desktop services,
  authentication, idle behavior, and a coordinated visual treatment with Ghostty.
- Evaluation/build checks and focused runtime/manual acceptance scenarios.

### Exclusions and deferred work

- Proton Mail and Proton Mail Bridge are explicitly deferred. The user requires
  a free Proton plan; Bridge requires a paid plan. Do not add Bridge dependencies,
  services, credentials, or certificate exceptions for this effort.
- OAuth is not required for the first mail workflow; use password/app-password
  IMAP/SMTP accounts with runtime secret retrieval.
- Monitor layouts, docking, and external-display behavior are not part of this
  iteration. Do not infer dock-specific exceptions from the lid policy below.
- No unattended remote access, general app-session restoration, additional
  clipboard history, SSH authentication changes, or disk-encryption redesign.
- No new theme engine, automatic graphics degradation, or battery-specific blur
  switching without an additional decision.

## Agreed requirements

### 1. Accounts and shared identity

1. Concrete OS/login accounts and email accounts remain separate concepts, both
   owned by the consumer. Home selection must remain explicit for the intended
   account and configuration target.
2. Show a coherent account/home/identity path in the consumer reference material.
   The reference template should demonstrate a primary email account as the
   common source of name and address for Git and rbw, instead of unnecessarily
   repeating those values. Use the existing ADR 0003 behavior.
3. Explicit native overrides for genuinely different Git or vault identities
   remain supported. A primary email account used only as an identity registry
   must not require operating a mail stack.
4. Do not encode occupants or personal selections in the reusable library.

### 2. Mail without Proton

1. Thunderbird and aerc must be usable from common consumer-owned account data,
   without separately entering the same server and identity configuration in
   each client. Do not infer that every configured account must be selected for
   both clients when the consumer explicitly selects otherwise.
2. Separate local caches/mail stores are acceptable. Shared local offline state
   between clients is not required; their view of server-side state must converge
   after synchronization.
3. Provide automatic background retrieval every **15 minutes** while the user
   is logged in, independently of whether either client is open. The precise
   service/session binding is an implementation proof point; this does not
   establish a pre-login or headless boot-time retrieval requirement.
4. Reuse the existing Maildir/mbsync/notmuch workflow where appropriate. The
   current `notmuch new` pre-hook invokes `mbsync --all`; do not schedule a second
   overlapping synchronization path accidentally.
5. With no network or a locked/unavailable password vault, skip or fail the
   attempt without an interactive unlock dialog, then retry on the next interval.
   Failures must remain diagnosable. No notification cadence was agreed.
6. Passwords and app passwords must not be embedded in Nix-store configuration.
   Runtime secret retrieval must not silently weaken TLS verification.
7. Shared account definitions do not prove automatic password delivery to
   Thunderbird. Its credential flow remains a technical proof point, not a
   promised feature. The manual Bridge setup discussed earlier applied to the
   now-deferred Proton case and does not settle generic mail credential handling.

### 3. Session startup, recovery, and app choices

1. A successful authenticated greeter login starts Niri with Noctalia as the
   default session, without another session-selection step. Do not enable
   automatic login.
2. Start one coherent shell and its required desktop services. Do not run DMS
   and Noctalia as competing shells in the same session.
3. Start a fresh session, not a general reconstruction of the previous apps,
   windows, and workspaces. App-specific restoration is a separate concern.
4. After a Noctalia crash, attempt bounded automatic recovery without killing
   Niri or existing applications. Repeated failures must be diagnosable rather
   than produce unlimited restart loops. Exact restart limits remain to be set.
5. A shell crash/restart must not expose a locked session. If this cannot be
   guaranteed by the selected lock architecture, treat that as a blocking issue.
6. Terminal, browser, file-manager, and other application actions must consistently
   use the consumer's selected programs across relevant shortcuts, launcher
   actions, and default handlers. Do not reintroduce hard-coded personal launch
   bindings into the reusable Niri feature.

### 4. Desktop integrations and privacy

1. Verify normal workflows for audio, network, Bluetooth, notifications, file
   dialogs, screenshots, clipboard operations, and privilege prompts. Existing
   configuration alone does not demonstrate that these workflows function.
2. Screen sharing must allow an explicit window or screen selection for each
   sharing start. Unattended access and remote control are not required.
3. Hide notification contents while locked. Whether to display an entirely
   neutral unread indicator is not specified; do not expose sender or message
   text as an assumed convenience.
4. Do not introduce a clipboard history. Reliable current-content copy/paste is
   sufficient. Removing an upstream component, if required to meet this target,
   needs source verification rather than assumptions about defaults.
5. Keep the login keyring available during ordinary screen lock so background
   services can continue operating. Screen lock does not promise revocation of
   credentials already available to running processes.

### 5. Authentication boundaries

These are desired policies, not verified PAM recipes.

| Boundary              | Desired policy                                                                                                        |
| --------------------- | --------------------------------------------------------------------------------------------------------------------- |
| Disk unlock           | Existing consumer-owned FIDO2 setup; no redesign in this effort                                                       |
| First desktop login   | User password, with login-keyring unlocking where correctly provisioned                                               |
| Screen unlock         | Prefer enrolled FIDO2 YubiKey with PIN or supported biometric user verification; user password remains an alternative |
| sudo reauthentication | Same alternative policy as screen unlock, not password plus key                                                       |
| SSH                   | Unchanged                                                                                                             |

1. Explicitly distinguish greeter, screen-lock, and sudo PAM services. A broad
   `security.pam.u2f` enablement is not proof of the required ordering or scope.
2. The hardware-key path must require the agreed user verification; mere key
   presence or touch is not an acceptable silent substitute. Confirm support in
   the actual key, PAM module, and authentication UI.
3. The password fallback is sufficient on its own. This is **not mandatory
   two-factor authentication**, and its security remains bounded by that path.
4. A successful sudo authentication may be reused within the same terminal for
   at most **five minutes**. Verify timestamp scope and expiration semantics.
5. Removing the specifically enrolled key triggers a one-time lock of the
   corresponding running desktop session. Unrelated USB-device removal must not
   lock arbitrary users. Afterward password unlock is still allowed without
   reinserting the key; continuous key presence is not required.
6. Normal password login should unlock the appropriately provisioned login
   keyring without repeated prompts. No empty-password keyring or stored plaintext
   login password is authorized. PIN/biometric authentication is not itself a
   demonstrated means of decrypting a password-protected login keyring.

### 6. Idle, power transitions, and lid behavior

| Idle action | Battery    | External power |
| ----------- | ---------- | -------------- |
| Lock        | 5 minutes  | 5 minutes      |
| Screen off  | 10 minutes | 15 minutes     |
| Suspend     | 20 minutes | 60 minutes     |

1. These are thresholds within an inactivity period, not sequential delays added
   after each previous action. Account for locked-state timers during design.
2. Keep a single external owner of the idle timers; Noctalia remains the lock UI.
   Disable its overlapping built-in idle behaviors when external ownership is
   implemented. A small explicit power-status integration is accepted.
3. On AC/battery transition, restart only the power-dependent screen-off and
   suspend countdowns using the new source's policy. Do not reset the independent
   five-minute lock countdown or unlock an already locked session.
4. Avoid immediate suspend merely because unplugging selects a shorter threshold.
   Transition handling for an already powered-off display must be specified and
   tested; automatically waking the display was not agreed.
5. Respect applicable inhibitors from video playback, presentations, and screen
   sharing. Manual locking remains available.
6. Lock must be established before suspend, including relevant non-idle suspend
   paths. Sending an asynchronous lock request alone is not evidence of this.
7. Preserve the user's intended lid policy as explicit host configuration:
   battery uses suspend-then-hibernate; external power locks. Do not restore this
   as a universal `host.power` default. Hibernate/resume prerequisites must be
   demonstrated on the selected host before activation; no supported hardware or
   working resume path has been established by this interview.

### 7. Blur, transparency, and visual consistency

1. Aim for subtle coordinated frosted glass, not maximum transparency. Text and
   controls must remain clearly readable.
2. Use **0.94 Ghostty background opacity as the first visual test value**, not an
   already approved final value. The inspected baseline uses 0.98.
3. Prefer a calm blurred-wallpaper appearance behind Ghostty, without recognizable
   underlying window contents. Keep the same opacity when focus changes.
4. Use the existing Niri compositor-blur direction for Ghostty; do not additionally
   enable Ghostty's own background blur without a demonstrated technical reason.
   A compositor rule and a disabled client blur setting are not contradictory.
5. Coordinate Noctalia launcher, panels, and window switcher with Ghostty, but do
   not require identical opacity values. Keep the continuously visible bar more
   opaque for legibility. No final numerical Noctalia opacity was agreed.
6. Preserve the existing Stylix theme-ownership direction; do not add competing
   app-theme generation as a side effect of tuning transparency.
7. Initially keep the visual policy the same on battery and external power. Only
   reduce it for demonstrated energy/performance problems, with an explicit
   follow-up decision rather than speculative adaptive-effect machinery.

## Technical proof points before implementation or activation

- Confirm current effective module/package versions and option schemas; source
  inspection during the interview is not a complete generated-config evaluation.
- Verify account generators and runtime secret delivery for both mail clients,
  including Thunderbird, TLS trust, and noninteractive vault-failure behavior.
- Select the mail timer/service lifecycle and demonstrate that retrieval and
  indexing do not overlap or mark a failed sync as successful fresh mail.
- Verify the exact greeter, Noctalia, and sudo PAM stacks, FIDO PIN/UV handling,
  password fallback, keyring interaction, and terminal-scoped sudo timestamps.
- Determine safe enrolled-key identification and user/session routing for removal
  events. Do not infer enrollment from any attached YubiKey.
- Verify bounded Noctalia restart and fail-closed lock behavior, including failure
  during an existing lock and immediately before suspend.
- Noctalia v5.2.1 has no native per-power-source idle schema. The examined swayidle
  and hypridle versions likewise did not establish a native AC/battery policy.
  Hypridle offers generic condition hooks, but those alone do not prove the
  agreed timer-restart behavior. No external daemon/controller is selected yet.
- Demonstrate power-transition countdowns, inhibitors, and lock acknowledgment;
  do not replace missing proof with shell-condition sketches.
- Verify actual portal selection and behavior in Niri, not merely the presence
  of GNOME/GTK portal packages.
- Inspect effective Ghostty/Stylix opacity and Noctalia surface settings, Niri
  app/layer matching, and wallpaper-versus-live-window blur semantics. Existing
  comments are not sufficient evidence of rendered behavior or GPU cost.

## Acceptance scenarios

These are future checks, not reported passes. Use focused evaluation/build checks
for configuration contracts and live/manual checks for hardware, authentication,
rendering, and session behavior. Do not activate authentication changes without
an approved recovery and testing procedure.

| ID  | Scenario and expected result                                                                                                                                                                          |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| A1  | Configure an OS account and explicitly selected home; only that target receives the intended configuration.                                                                                           |
| A2  | Change the primary email identity once; Git and rbw follow unless explicitly overridden. An identity-only account does not force mail setup.                                                          |
| M1  | One consumer IMAP/SMTP definition produces usable Thunderbird and aerc account settings without credentials in the Nix store.                                                                         |
| M2  | Close both clients; a new server message is retrieved by the next successful 15-minute cycle and indexed. No duplicate sync runs occur.                                                               |
| M3  | Disconnect the network or lock the vault; retrieval does not prompt, failures are diagnosable, and later cycles recover when prerequisites return.                                                    |
| M4  | Change message state using one client; the other converges through server synchronization. Immediate shared offline state is not required.                                                            |
| D1  | Password login starts one Niri/Noctalia session with required services and an appropriately provisioned unlocked keyring; it does not generally restore old apps.                                     |
| D2  | Crash Noctalia while unlocked and while locked; recovery is bounded, apps survive, and protected content is never exposed by loss of the lock UI.                                                     |
| D3  | Consumer-selected apps are used by the relevant shortcuts, launcher actions, and file/URL opening paths.                                                                                              |
| D4  | Audio, network, Bluetooth, file dialogs, privilege prompts, screenshots, and current-content clipboard operations work in the selected session.                                                       |
| D5  | Start and stop screen sharing; explicit source selection is required and no unattended remote-control path is introduced.                                                                             |
| D6  | Lock while notifications arrive; contents are hidden, no additional clipboard history is introduced, and permitted background services continue.                                                      |
| S1  | First desktop login requires the user password; screen unlock accepts the enrolled verified FIDO path or password fallback. Touch-only verification cannot silently satisfy the FIDO requirement.     |
| S2  | Test sudo with both alternative methods; authorization is terminal-scoped and expires within the agreed five-minute window. SSH and disk unlock are unchanged.                                        |
| S3  | Remove the enrolled key; its user's desktop locks once. An unrelated device does not trigger it, and password unlock without the key remains possible.                                                |
| P1  | Exercise battery and AC inactivity thresholds, including a locked session; actions follow the agreed table and do not run through competing timer owners.                                             |
| P2  | Switch AC/battery during inactivity; screen/suspend countdowns restart, the lock countdown does not, and an active lock is preserved.                                                                 |
| P3  | Exercise applicable inhibitors and manual locking; automatic idle behavior respects inhibitors, and suspend never precedes established locking.                                                       |
| P4  | Verify explicit lid behavior and hibernate/resume on supported provisioned hardware; do not claim a working resume path from evaluation alone.                                                        |
| V1  | Compare Ghostty at the 0.94 test value using light/dark wallpapers, ordinary text, colored TUIs, selection, overlapping windows, and focus changes. Text stays legible and the background stays calm. |
| V2  | Check Noctalia bar, panels, launcher, and switcher together with Ghostty; the bar is more opaque, surfaces feel coordinated, and rendering remains smooth.                                            |
| V3  | Compare representative battery/AC operation for visual correctness and measurable performance/energy regressions. Record conditions and observations rather than assuming blur is free or expensive.  |

## Evidence and wayfinding

Repository entry points, relative to the repository root:

- `modules/templates/dotnix/modules/users/myUser/default.nix`
- `modules/templates/dotnix/modules/hosts/myHost/configuration.nix`
- `modules/features/{git,rbw,aerc,thunderbird,maildir,power,ghostty,stylix}.nix`
- `modules/features/niri/` and `modules/features/noctalia/`
- `modules/features/noctalia-greeter.nix`, `modules/features/yubikey/`
- `modules/features/{gnome-services,xdg-portals,clipboard}.nix`

Primary-source references used during the interview:

- [Noctalia v5.2.1 idle schema](https://github.com/noctalia-dev/noctalia/blob/v5.2.1/src/config/schema/config_schema.cpp#L959-L1023)
- [Noctalia v5.2.1 idle documentation](https://github.com/noctalia-dev/noctalia/blob/v5.2.1/docs/user/services/idle.mdx)
- [hypridle v0.1.8](https://github.com/hyprwm/hypridle/blob/v0.1.8/README.md)
- [swayidle v1.9.1 manual](https://github.com/swaywm/swayidle/blob/v1.9.1/swayidle.1.scd)
- [Proton Bridge plan requirement](https://proton.me/support/imap-smtp-and-pop3-setup)

No implementation tickets, new glossary terms, or architecture decisions are
created by this specification. Follow-up implementation requires separate
approval and must preserve unresolved limitations rather than claiming success
from configuration text alone.
