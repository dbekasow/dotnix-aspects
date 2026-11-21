{ inputs, lib, ... }:
{
  # Import the tooling only after its inputs have been locked.
  imports = lib.optionals (inputs ? devshell && inputs ? git-hooks && inputs ? treefmt) [
    ./devshell.nix
    ./pre-commit.nix
    ./treefmt.nix
  ];

  # The writer must see these declarations before the inputs can be imported.
  flake-file.inputs = {
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
