# Select managed secrets only where needed

Status: accepted. Integrated-home selection and bootstrap are covered by a disposable configuration check. [Luffy's migration](../managed-home-secrets.md#luffy-migration--do-not-change-the-live-wiring-yet) remains blocked on recovery evidence.

Configuring a mail account does not select a managed vault: an integrated home on NixOS under WSL can configure its mail client and use an existing login method. On a shared host, enabling secret management makes it available but does not provision a decryption identity for a home that needs no managed secrets. Unlike the desktop shell, a private key is not a host-wide default for every occupant.

A VPS must support administrative SSH public-key access without Home Manager, a managed vault, or a generated system-account password. Privilege escalation and recovery access remain separate host decisions.

For managed home secrets, the recipient belongs to a specific occupant on a specific host. Grant a second device access as a second recipient; do not copy the first device's private key. Removing a recipient affects future encryption, not copies already decrypted.

Bootstrap is separate from normal configuration. If a home explicitly requests a managed secret and its public recipient key is missing, normal configuration must stop with a diagnostic identifying the host, home, and missing key. Bootstrap must remain possible before that key exists.
