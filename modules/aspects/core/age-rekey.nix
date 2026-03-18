{ inputs, ... }: {
  flake.modules.nixos.core = {
    imports = [
      inputs.agenix.nixosModules.default
      inputs.agenix-rekey.nixosModules.default
    ];

    age.rekey = rec {
      secretsDir = "${inputs.self}/secrets";
      generatedSecretsDir = secretsDir + "/generated";
      localStorageDir = secretsDir + "/local";
      hostPubkey = secretsDir + "/host.pub";
      masterIdentities = [{
        identity = inputs.self + "/master-key.age";
        pubkey = "age1kalxvlmjjydtdps5n27qyf5cf6eqwzuaesemj4enp8ulyw3mcsls3rkpd6";
      }];
      storageMode = "local";
    };
  };

  flake.modules.homeManager.core = { osConfig, ... }: {
    imports = [
      inputs.agenix.homeManagerModules.default
      inputs.agenix-rekey.homeManagerModules.default
    ];

    age.rekey = rec {
      inherit (osConfig.age.rekey) masterIdentities storageMode hostPubkey;
      secretsDir = "${inputs.self}/secrets";
      generatedSecretsDir = secretsDir + "/generated";
      localStorageDir = secretsDir + "/local";
    };
  };
}
