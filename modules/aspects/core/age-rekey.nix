{ inputs, ... }:
let
  # Library dependency inputs (the agenix-rekey modules) must stay closed over
  # the library's own flake. Consumer resources (secretsDir, hostPubkey) resolve
  # from the aspect `inputs` argument instead — that is the consumer flake
  # exposed by den.batteries.flake-scope, not this library source tree.
  libraryInputs = inputs;
in
{
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
  dotnix.age-rekey = { inputs, ... }: {
    nixos = { host, lib, ... }: {
      # Stable key so the external module is loaded once when this aspect is
      # selected at both host and policy-routed user scope; without it the
      # module system sees two keyless copies and rejects age.rekey.secrets.
      imports = [
        {
          key = "dotnix:agenix-rekey:nixos";
          imports = [ libraryInputs.agenix-rekey.nixosModules.default ];
        }
      ];

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

    homeManager = { config, lib, osConfig, ... }: {
      imports = [
        {
          key = "dotnix:agenix-rekey:homeManager";
          imports = [ libraryInputs.agenix-rekey.homeManagerModules.default ];
        }
      ];

      age.rekey = rec {
        secretsDir = "${inputs.self}/modules/users/${config.home.username}/secrets";
        generatedSecretsDir = secretsDir + "/generated";
        localStorageDir = secretsDir + "/local";
        hostPubkey = let pub = secretsDir + "/home-key.pub"; in
          lib.optionalString (lib.pathExists pub) (lib.readFile pub);
        inherit (osConfig.age.rekey) masterIdentities storageMode;
      };
    };
  };
}
