{ inputs, ... }: {
  flake.modules.nixos.age-rekey = { config, lib, ... }: {
    imports = [ inputs.agenix-rekey.nixosModules.default ];

    age.rekey = rec {
      secretsDir = "${inputs.self}/modules/hosts/${config.dotnix.hostname}/secrets";
      generatedSecretsDir = secretsDir + "/generated";
      localStorageDir = secretsDir + "/local";
      hostPubkey = lib.readFile (secretsDir + "/host-key.pub");
      masterIdentities = [
        {
          identity = inputs.self + "/yubikey.pub";
          pubkey = "age1yubikey1qwj6qjwhqe8zpnnh7799ntnuah7npttr55gzqer3r3ex5hjq4gnmyh2k6tk";
        }
        {
          identity = inputs.self + "/masterkey.age";
          pubkey = "age1kalxvlmjjydtdps5n27qyf5cf6eqwzuaesemj4enp8ulyw3mcsls3rkpd6";
        }
      ];
      storageMode = "local";
    };
  };

  flake.modules.homeManager.age-rekey = { config, lib, osConfig, ... }: {
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
