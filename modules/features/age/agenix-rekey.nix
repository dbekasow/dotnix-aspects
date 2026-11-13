{ inputs, ... }:
let
  # Keep the agenix-rekey dependency closed over the library flake.
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

  # Conventional resource layout: modules/hosts/<host>/secrets. The include
  # exposes the consumer tree to the class module; consumers deviate by
  # setting the native age.rekey options, and the derived directories
  # follow the merged secretsDir so overrides relocate them too.
  dotnix.host.age-rekey = {
    includes = [
      ({ inputs, ... }: {
        name = "age-rekey/consumer-self";
        nixos._module.args.consumerSelf = inputs.self;
      })
    ];

    nixos =
      { config, consumerSelf, host, lib, ... }:
      {
        imports = [
          {
            key = "dotnix:agenix-rekey:nixos";
            imports = [ libraryInputs.agenix-rekey.nixosModules.default ];
          }
        ];

        age.rekey = {
          secretsDir = lib.mkDefault "${consumerSelf}/modules/hosts/${host.hostName}/secrets";
          generatedSecretsDir = lib.mkDefault (config.age.rekey.secretsDir + "/generated");
          localStorageDir = lib.mkDefault (config.age.rekey.secretsDir + "/local");
          hostPubkey = let pub = "${config.age.rekey.secretsDir}/ssh_host_ed25519_key.pub"; in
            lib.mkDefault (lib.optionalString (config.age.rekey.secretsDir != null && lib.pathExists pub) (lib.readFile pub));
          storageMode = lib.mkDefault "local";
        };
      };
  };

  # Conventional resource layout: modules/users/<user>/secrets, without
  # requiring host-side age-rekey to be selected on the same target.
  dotnix.home.age-rekey = {
    includes = [
      ({ inputs, ... }: {
        name = "age-rekey/consumer-self-home";
        homeManager._module.args.consumerSelf = inputs.self;
      })
    ];

    homeManager =
      { config, consumerSelf, lib, ... }:
      {
        imports = [
          {
            key = "dotnix:agenix-rekey:homeManager";
            imports = [ libraryInputs.agenix-rekey.homeManagerModules.default ];
          }
        ];

        age.rekey = {
          secretsDir = lib.mkDefault "${consumerSelf}/modules/users/${config.home.username}/secrets";
          generatedSecretsDir = lib.mkDefault (config.age.rekey.secretsDir + "/generated");
          localStorageDir = lib.mkDefault (config.age.rekey.secretsDir + "/local");
          hostPubkey = let pub = "${config.age.rekey.secretsDir}/home-key.pub"; in
            lib.mkDefault (lib.optionalString (config.age.rekey.secretsDir != null && lib.pathExists pub) (lib.readFile pub));
          storageMode = lib.mkDefault "local";
        };
      };
  };
}
