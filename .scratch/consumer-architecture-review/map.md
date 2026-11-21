# Consumer architecture review: decisions, gaps and delivery map

Planning scope: review the library through real consumer choices. This map is not a release, implementation approval or replacement for existing specs. Seven approved implementation tickets are published below. Their status does not authorize execution.

## Consumer contract

Personas are examples owned by consumers, not library presets (ADR 0002). Work is NixOS on WSL with integrated Home Manager, mail accounts and tool identities; WSL boot is consumer-owned. Private includes separate machines and a shared machine: occupants share its selected desktop shell, not each other's accounts, secrets or applications. A system-only VPS supports public-key SSH without a managed vault, generated password or HM dependency. Roger is a useful headless counterexample for YubiKey without Desktop. Distinguish one consumer's lockfile from one host's effective configuration.

## Decided: approved vertical slices

| ID | Observable result | Blocked by | Authority / smallest evidence |
| --- | --- | --- | --- |
| [01](issues/01-public-system-import.md) | A system-only VPS consumes named modules via `import inputs.dotnix`; no internal paths or Home Manager registration/dependency. | None | [Import spec](../public-consumer-imports/spec.md), [ADR 0011](../../docs/adr/0011-import-public-modules-from-the-source-input.md). Generate a real consumer lock and evaluate an SSH account without a managed vault or generated password. |
| [02](issues/02-independent-work-home.md) | Work registers Home Manager for programs, mail and tool identities using existing authentication without a managed vault; no Desktop inputs/modules or YubiKey modules. YubiKey remains independently usable on a headless system. | 01 | Adapt the existing headless consumer generation case; reuse catalog and lock assertions. |
| [03](issues/03-independent-repo-tools.md) | Repo formatter, hooks and shell work without vault/YubiKey tools; explicit vault tooling remains available. | 01 | Adapt existing DevTools generation case. No upstream tool behavior tests. |
| [04](issues/04-mixed-consumer-template.md) | Template uses named imports; show equivalent private migration. Register Desktop once without activating it on the second host. | 02, 03 | Reuse existing mixed-consumer check. Do not change authentication or shell selection in the import migration. |
| [05](issues/05-host-desktop-shell.md) | Selecting Noctalia or DMS on a host gives all integrated homes that shell; reject contradictions. No propagation to other hosts, standalone homes, personal apps or greeter. Remove repeated consumer selection. | None | [ADR 0008](../../docs/adr/0008-one-desktop-shell-per-host.md). Replace the conflicting existing Alice/Bob expectation, retain relevant runtime and conflict checks; no per-shell combination matrix. |
| [06](issues/06-independent-tool-identities.md) | Changing primary mail no longer changes Git author or vault identity unless the consumer explicitly links them. Preserve effective reference-consumer identities and correct stale template guidance. | None | [ADR 0009](../../docs/adr/0009-keep-tool-identities-independent-of-mail.md). Change primary mail in one representative home and check both tool identities. |
| [07](issues/07-managed-home-recipients.md) | Explicit home-secret selection provisions one recipient per host and system account; normal configuration diagnoses a missing recipient, bootstrap remains possible. Unselected homes get no key. | None | ADR 0010. Pair a managed and unmanaged home in a disposable fixture; distinguish the same occupant on another host. Preserve Luffy's existing encrypted identity and recovery path. No rotations or production rekey. |

Vault-free behavior is part of 01 and 02; do not create separate fixtures for it. Ticket 07 needs a migration design for the existing public key layout before touching the private consumer. Do not claim runtime decryptability from evaluating a public key or a secret path.

## Open findings: decisions before implementation tickets

- Extend host-to-home routing beyond desktop shells? Decide independently for the Niri baseline (including personal keyboard defaults and Polkit), graphical foundation (single Stylix import), WirePlumber state (only when persistence is active), and home.core (all integrated homes or explicit baseline?). Route full aspect contributions where needed, not namesake modules unconditionally. Standalone homes must not require a host.
- Place Luffy-specific user overrides on the host/user edge rather than extending the global Denis aspect. Decide which wallpaper, bindings and secret settings are truly host-specific. Existing template already demonstrates the edge.
- Accounts: separate per-user password hashing from host-wide `users.mutableUsers`; decide bootstrap and recovery before changing live access. Decide whether declaring a human login should replace separate `account.users` selection without treating service accounts as humans.
- Vault: decide the public host capability and shared readiness rules; avoid mistaking a present public key for deployed secrets. Decide how managed PAM references a genuinely enrolled U2F mapping rather than a generated placeholder. Keep PAM policy, hardware enrollment and sudo decisions independent.
- Profiles: positive selection of common terminal + chosen multiplexer instead of subtracting Tmux/Sesh from Herdr. Consider selecting rbw directly instead of inheriting it via terminal. ADR 0009 does not itself remove rbw from terminal.
- Storage: distinguish importing Disko, selecting Luffy's Btrfs/LUKS layout, FIDO2 enrollment and root reset. Align device/subvolume assumptions without treating this as approval to change disks. Decide optional storage and secret input groups against consumer needs, not folder count.
- Avoid accidental inheritance: Fish availability is not a login-shell decision; Docker tools, lingering, persistence and privileged group membership are separate; an LLM package cache is not a policy to retain everyone's Pi history. Consider an explicit persistence name for home.pipewire if it remains publicly selectable.

## Existing tracker and ADR reconciliation

[Consumer-scoped loading](../consumer-scoped-loading/spec.md) is the baseline for generation, mixed targets and group imports. Reuse its coverage, not its old direct-directory interface. [Accounts/mail/desktop](../accounts-mail-desktop/spec.md) includes unrelated desktop lifecycle, authentication and mail work: do not republish its backlog. Its shared-identity issue 01 and acceptance scenario A2 instruct Git/rbw to follow primary mail, contrary to ADR 0009. Its session issue 06 requires explicit host/home choices: keep the independent greeter and session lifecycle contract, but do not retain duplicated shell choices contrary to ADR 0008. Reconcile those passages when working the corresponding slice, before executing stale tickets. ADR 0001 remains the role-catalog baseline, not a mandate for duplicate desktop-shell selections. ADR 0005's personal/machine choices remain explicit.

## Test and execution budget

Prefer changing one existing behavioral fixture over creating a suite. Add an assertion only when it catches a distinct consumer-visible regression. A missing module and an absent reachable input are different promises; internal file locations, complete snapshots, and combinations of every persona and feature are not promises. No real work repo, credentials, hardware enrollment, deployment, lock refresh or production activation needed for planning.
