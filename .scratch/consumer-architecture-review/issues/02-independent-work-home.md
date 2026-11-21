# 02: Configure a work home without Desktop or YubiKey

**What to build:** Select integrated Home Manager for a NixOS-on-WSL consumer while leaving WSL startup consumer-owned.

**Blocked by:** [01: Run an SSH-only VPS through public imports](01-public-system-import.md)

**Status:** ready-for-agent

- [ ] One representative home evaluates its program, mail account and tool identity using an existing login method without a managed vault. No WSL boot or mail sync required.
- [ ] Adapt the existing generation case: neither Desktop nor YubiKey modules register and Desktop-only inputs are absent from the reachable graph.
- [ ] Preserve explicit headless YubiKey selection without requiring Desktop; reuse the existing headless example.

[Review decisions and test budget](../map.md)
