{ inputs, ... }: {
  flake.modules.nixos.age-rekey = { config, lib, ... }: {
    imports = [ inputs.agenix-rekey.nixosModules.default ];

    age.rekey = rec {
      secretsDir = "${inputs.self}/modules/hosts/${config.dotnix.hostname}/secrets";
      generatedSecretsDir = secretsDir + "/generated";
      localStorageDir = secretsDir + "/local";
      # optionalString lets template/CI consumers evaluate before host keys exist
      hostPubkey = let pub = secretsDir + "/ssh_host_ed25519_key.pub"; in
        lib.optionalString (lib.pathExists pub) (lib.readFile pub);
      # masterIdentities are consumer-owned: set age.rekey.masterIdentities in
      # your host module (see templates/dotnix README for the layout).
      storageMode = "local";
    };
  };

  flake.modules.homeManager.age-rekey = { config, lib, osConfig, ... }: {
    imports = [ inputs.agenix-rekey.homeManagerModules.default ];

    age.rekey = rec {
      secretsDir = "${inputs.self}/modules/users/${config.home.username}/secrets";
      generatedSecretsDir = secretsDir + "/generated";
      localStorageDir = secretsDir + "/local";
      hostPubkey = let pub = secretsDir + "/home-key.pub"; in
        lib.optionalString (lib.pathExists pub) (lib.readFile pub);
      inherit (osConfig.age.rekey) masterIdentities storageMode;
    };
  };
}
