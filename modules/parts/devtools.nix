{ inputs, lib, ... }:
{
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

  # Import the tooling only after all of its inputs have been locked.
  imports = lib.optionals
    (inputs ? agenix-rekey && inputs ? devshell && inputs ? git-hooks && inputs ? treefmt)
    [
      ./age.nix
      ./devshell.nix
      ./pre-commit.nix
      ./treefmt.nix
    ];
}
