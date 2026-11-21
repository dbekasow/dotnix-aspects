# 03: Use repository tools without vault tooling

**What to build:** Offer formatting, hooks and a development shell independently of vault and hardware-token tooling.

**Blocked by:** [01: Run an SSH-only VPS through public imports](01-public-system-import.md)

**Status:** ready-for-agent

- [ ] Adapt the existing DevTools generation case: the tooling outputs evaluate without vault setup, and the development shell does not supply vault commands or YubiKey tools by default.
- [ ] Consumers explicitly selecting vault tooling retain the existing generation and rekey flows. Do not test upstream formatter or hook behavior.

[Review decisions and test budget](../map.md)
