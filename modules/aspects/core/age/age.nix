# The `generator` option is the agenix-rekey extension — age.nix must be
# imported alongside age-rekey (users.nix and yubikey-pam.nix depend on
# the same extension).
{ inputs, ... }: {
  flake.modules.nixos.age = { config, lib, ... }: {
    imports = [ inputs.agenix.nixosModules.default ];

    # Secrets follow the key material: dotnix.vaultReady is false until the
    # host key exists (fresh template, CI fixture) — no vault is declared
    # and evaluation stays green. `agenix generate` bootstraps the vault.
    age.secrets = lib.optionalAttrs config.dotnix.vaultReady (lib.mergeAttrsList (map
      (owner: {
        "home-identity-${owner}" = {
          generator.script = "ssh-ed25519";
          mode = "600";
          inherit owner;
        };
      })
      config.dotnix.members));
  };

  flake.modules.homeManager.age = { config, lib, osConfig, ... }: {
    imports = [ inputs.agenix.homeManagerModules.default ];

    # Only route decryption through the vault secret once it is declared
    # (dotnix.vaultReady gates the matching nixos.age declaration).
    age.identityPaths = lib.optional osConfig.dotnix.vaultReady
      osConfig.age.secrets."home-identity-${config.home.username}".path;
  };
}
