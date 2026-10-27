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

  dotnix.host.age-rekey.nixos = { lib, ... }: {
    imports = [
      {
        key = "dotnix:agenix-rekey:nixos";
        imports = [ libraryInputs.agenix-rekey.nixosModules.default ];
      }
    ];

    age.rekey.storageMode = lib.mkDefault "local";
  };

  dotnix.home.age-rekey.homeManager = { lib, ... }: {
    imports = [
      {
        key = "dotnix:agenix-rekey:homeManager";
        imports = [ libraryInputs.agenix-rekey.homeManagerModules.default ];
      }
    ];

    age.rekey.storageMode = lib.mkDefault "local";
  };
}
