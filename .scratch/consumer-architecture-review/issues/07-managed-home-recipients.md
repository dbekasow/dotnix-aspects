# 07: Provision managed secrets only for the selected home

**What to build:** Provision a recipient for a specific host and system account when that home requests managed secrets. Separate first-time setup from normal use.

**Blocked by:** None (can start immediately)

**Status:** ready-for-agent

- [ ] A selected home receives its own secret identity; an unselected home receives none. A second device can be independently authorized without copying a private key.
- [ ] Bootstrap works without the final public key. Normal configuration with a missing required recipient stops and identifies the host, home and missing key.
- [ ] Document a migration preserving Luffy's existing encrypted identity, ownership, mode and recovery access before changing its wiring. Use disposable fixtures; no production key generation, rotation, deployment or claims of runtime decryption from evaluation alone.

[Review decisions and test budget](../map.md)
