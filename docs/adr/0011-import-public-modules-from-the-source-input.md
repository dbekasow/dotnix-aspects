# Import public modules from the source input

Status: accepted and implemented. Revises the direct directory imports and group boundaries of [ADR 0007](0007-scope-imports-and-inputs-to-the-consumer.md), not its consumer-owned lockfile or source-only input.

Consumers use `modules = import inputs.dotnix` to obtain named flake-parts modules. They choose capabilities, not paths inside the library. This keeps the existing development flake independent of the consumer's dependency graph. See the source root's [`default.nix`](../../default.nix) for the public names.

- A system-only VPS can omit both the Home Manager modules and the Home Manager input from its reachable lock graph.
- A NixOS-on-WSL consumer can include Home Manager for programs, mail accounts, and tool identities without Desktop or YubiKey modules or Desktop inputs. WSL startup remains consumer-owned.
- Repository formatting, hooks, and a development shell are available without bringing in vault commands or YubiKey tooling. Importing a repository tool must not activate a host feature.

The import contract applies per consumer, not per host: a VPS sharing a flake with a desktop host need not have its own lockfile.
