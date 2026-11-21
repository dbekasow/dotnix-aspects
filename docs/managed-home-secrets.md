# Managed secrets for an integrated home

Select `dotnix.home.managed-secrets` on a NixOS host's `provides.<account>` edge, not as part of an occupant's defaults. Select `dotnix.host.age` and `dotnix.host.age-rekey` on that host and configure its vault. Registration of these host features does not provision anything for an unselected home.

The selection declares `age.secrets.home-identity-<account>` in the host vault with the `ssh-ed25519` generator, the system account as owner, and mode `600`. Home Manager uses that secret's runtime path. By default it reads the corresponding public key from `modules/hosts/<host>/secrets/homes/<account>/home-key.pub` and stores its local rekeyed files in the adjacent `local/` directory. As before, home secret sources and generated sources can be shared under `modules/users/<account>/secrets/`; the consumer sets the home vault's master identities or extra recipients explicitly. Native `age.rekey.hostPubkey` and `age.rekey.localStorageDir` overrides may be used for an existing vault but must remain scoped to that host and account. The managed selection never falls back to the old user-wide public key.

## Bootstrap and normal use

- For first-time setup before the home public key exists, use `dotnix.home.managed-secrets-bootstrap` instead. It declares the identity in the host vault but does not configure the home vault. The host public key and host vault setup still precede this step; defer the home vault's managed payload configuration. As with any host secret, provisioning the declaration does not produce the encrypted artifacts needed by an installation.
- Once the host-encrypted identity is available, record **only its public key** in the selected host/account's `home-key.pub`, then switch to `dotnix.home.managed-secrets` and configure the home payload. Normal system builds reject a missing public recipient with the host, account, and expected path. Neither the presence of a public key nor a successful evaluation proves that the corresponding private key can decrypt the payload.
- On a second device, use its own host vault and repeat the selection for that account. Authorize the additional public recipient rather than copying the first device's private key. Removing a recipient does not revoke data already decrypted.

## Migrate an existing managed identity

Do not change live wiring until the operator confirms that the existing encrypted identity matches the tracked public key and can be recovered through the existing recovery path. A matching host recipient in ciphertext metadata does not establish either fact. The bootstrap variant is for new identities, not for migrating an existing one.

Select `dotnix.home.managed-secrets` only on the existing host/account edge. Replace the duplicate host identity declaration and Home Manager `age.identityPaths` assignment together, and only if the new selection preserves the existing secret name, generator, owner, mode, and runtime path. Keep the host identity, host vault directories and ciphertexts unchanged. Copy the existing **public** home key unchanged to the scoped path or pin it with the native override. Preserve master identity references and existing home rekey artifacts, using a scoped storage override if needed. Do not change authentication, bootstrap, PAM, or recovery settings as part of this migration.
