{ inputs, ... }: {
  flake-file.inputs.agenix-rekey = {
    url = "github:oddlama/agenix-rekey";
    inputs = {
      devshell.follows = "devshell";
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
      pre-commit-hooks.follows = "git-hooks";
      treefmt-nix.follows = "treefmt";
    };
  };
  dotnix.age-rekey.nixos = { host, lib, ... }: {
    imports = [ inputs.agenix-rekey.nixosModules.default ];

    age.rekey = rec {
      secretsDir = "${inputs.self}/modules/hosts/${host.name}/secrets";
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

  dotnix.age-rekey.homeManager = { config, lib, osConfig, ... }: {
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
