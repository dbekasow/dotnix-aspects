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

  # The parts share options from these inputs. Pass the same input scope
  # through to each part so the legacy adapter can use the library's inputs.
  imports = lib.optionals
    (inputs ? agenix-rekey && inputs ? devshell && inputs ? git-hooks && inputs ? treefmt)
    (map (path: import path { inherit inputs lib; }) [
      ./age.nix
      ./devshell.nix
      ./pre-commit.nix
      ./treefmt.nix
    ]);
}
