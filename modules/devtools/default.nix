{ inputs, lib, ... }:
{
  # Import the tooling only after all of its inputs have been locked.
  imports = lib.optionals
    (inputs ? agenix-rekey && inputs ? devshell && inputs ? git-hooks && inputs ? treefmt)
    [
      ./age.nix
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

    # Base declares agenix-rekey for runtime configuration. Reuse the
    # Consumer's tooling inputs only when it also opts into DevTools.
    agenix-rekey.inputs = {
      devshell.follows = "devshell";
      pre-commit-hooks.follows = "git-hooks";
      treefmt-nix.follows = "treefmt";
    };
  };
}
