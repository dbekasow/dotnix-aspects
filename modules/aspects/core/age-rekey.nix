{ inputs, ... }: {
  flake.modules.nixos.core = { config, lib, ... }: {
    imports = [ inputs.agenix-rekey.nixosModules.default ];

    age.rekey = rec {
      secretsDir = "${inputs.self}/modules/hosts//${config.dotnix.hostname}/secrets";
      generatedSecretsDir = secretsDir + "/generated";
      localStorageDir = secretsDir + "/local";
      hostPubkey = lib.readFile (secretsDir + "/host-key.pub");
      masterIdentities = [{
        identity = inputs.self + "/master-key.age";
        pubkey = "age1kalxvlmjjydtdps5n27qyf5cf6eqwzuaesemj4enp8ulyw3mcsls3rkpd6";
      }];
      storageMode = "local";
    };

  };

  flake.modules.homeManager.core = { config, lib, osConfig, ... }: {
    imports = [ inputs.agenix-rekey.homeManagerModules.default ];

    age.rekey = rec {
      secretsDir = "${inputs.self}/modules/users/${config.home.username}/secrets";
      generatedSecretsDir = secretsDir + "/generated";
      localStorageDir = secretsDir + "/local";
      hostPubkey = lib.readFile (secretsDir + "/home-key.pub");
      inherit (osConfig.age.rekey) masterIdentities storageMode;
    };
  };
}
