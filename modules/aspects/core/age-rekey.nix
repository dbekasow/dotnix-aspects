{ inputs, ... }: {
  flake.modules.nixos.core = { config, lib, ... }: {
    imports = [
      inputs.agenix.nixosModules.default
      inputs.agenix-rekey.nixosModules.default
    ];

    age.rekey = rec {
      secretsDir = "${inputs.self}/secrets/hosts/${config.dotnix.hostname}";
      generatedSecretsDir = secretsDir + "/generated";
      localStorageDir = secretsDir + "/local";
      hostPubkey = lib.readFile (secretsDir + "/host.pub");
      masterIdentities = [{
        identity = inputs.self + "/master-key.age";
        pubkey = "age1kalxvlmjjydtdps5n27qyf5cf6eqwzuaesemj4enp8ulyw3mcsls3rkpd6";
      }];
      storageMode = "local";
    };
  };

  flake.modules.homeManager.core = { config, osConfig, ... }: {
    imports = [
      inputs.agenix.homeManagerModules.default
      inputs.agenix-rekey.homeManagerModules.default
    ];

    age.rekey = rec {
      secretsDir = "${inputs.self}/secrets/users/${config.dotnix.username}";
      generatedSecretsDir = secretsDir + "/generated";
      localStorageDir = secretsDir + "/local";
      inherit (osConfig.age.rekey) masterIdentities storageMode hostPubkey;
    };
  };
}
