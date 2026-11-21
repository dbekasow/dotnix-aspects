# Named imports for independent consumers

Status: ready-for-agent

## Problem statement

A consumer currently imports internal library directories. Base registers Home Manager and YubiKey modules, and the development shell expects vault tools. As a result, a consumer cannot express “system and SSH only” or “Home Manager and repository tooling, but no hardware token” without knowing library internals or accepting unwanted dependencies.

## Solution

Keep a source-only library input. `import inputs.dotnix` returns named modules; the consumer lists the capabilities it needs in its flake-parts imports. Internal directory names are not part of the interface. Importing a capability makes features available in that consumer, not active for every target. See [ADR 0011](../../docs/adr/0011-import-public-modules-from-the-source-input.md).

## User stories

- As a VPS operator, I can configure a system account with an SSH public key without importing Home Manager, configuring a vault, or generating a login password.
- As a WSL user, I can configure programs, mail accounts, and tool identities in integrated Home Manager without loading Desktop or YubiKey. WSL startup and the choice of mail authentication method are mine.
- As a contributor to the work consumer, I can use a formatter, hooks, and a development shell without vault commands or YubiKey tooling being added for me.
- As the owner of a private consumer, I can opt back into the capabilities my machines use. Registering Desktop once must not enable it on a second, headless host.
- As a template user, I can discover the supported names from the public entry point and examples. I need not reproduce the library's directory layout or maintain a parallel dependency list.

## Implementation decisions

Keep one flake and lockfile per consumer, not per host. Preserve the source-only pin and the existing flake generation process. Define and document the export names once at the public entry point; this spec does not prescribe a directory per export. The interface must support system-only, integrated Home Manager, optional Desktop and YubiKey support, and repository tooling independent of vault tooling. Account for indirect input edges, not just direct imports. Preserve existing explicitly selected private capabilities. Migrate the shipped template and show the equivalent migration for the private consumer; do not require compatibility aliases for internal paths.

## Testing decisions

Use the existing disposable consumer-generation approach. Fixtures consume only the published import interface. Generate and lock each consumer and evaluate its effective configuration; do not use the standalone library flake's full input set as a substitute.

| Consumer                 | Positive evidence                                                                                                                                                                                              | Negative evidence                                                                                                                                                                     |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| VPS, own lockfile        | System evaluates with a test system account and an authorized SSH public key.                                                                                                                                  | No Home Manager modules registered or Home Manager dependency reachable in its lockfile; no managed vault or generated account password required.                                     |
| Work, own lockfile       | A NixOS configuration with integrated Home Manager evaluates a representative program, mail account and tool identity. Repository formatter, hooks and development shell remain available without vault setup. | No Desktop or YubiKey feature modules registered, no Desktop-only inputs reachable, and no library-provided vault commands or hardware-token tools in the selected development shell. |
| Private, shared lockfile | Desktop and explicitly requested optional features are available; a representative desktop target still evaluates.                                                                                             | An unselected second host does not acquire the desktop settings. Its consumer-wide lockfile may legitimately contain Desktop inputs.                                                  |

The absence of a runtime package alone does not prove that modules or inputs were omitted. Test catalog registration, reachable lock nodes, or evaluated settings according to the promise being checked. Use synthetic account data and public-key fixtures; no real credentials, WSL runtime, or private work repo required.

## Out of scope

Changing desktop-shell inheritance, Git or vault identity defaults, secret provisioning, login policy, WSL boot integration, storage layout, or the contents of personal profiles. Do not rotate keys, activate hosts, or deploy configurations. This spec authorizes no implementation by itself.
