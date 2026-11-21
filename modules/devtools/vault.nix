{ inputs, lib, ... }:
{
  imports = [ ./repo.nix ] ++ lib.optional
    (inputs ? agenix-rekey && inputs ? devshell && inputs ? git-hooks && inputs ? treefmt)
    ./age.nix;

  # Vault tooling also works without selecting the runtime Age/Rekey modules.
  flake-file.inputs.agenix-rekey = {
    url = "github:oddlama/agenix-rekey";
    inputs = {
      flake-parts.follows = "flake-parts";
      nixpkgs.follows = "nixpkgs";
      devshell.follows = "devshell";
      pre-commit-hooks.follows = "git-hooks";
      treefmt-nix.follows = "treefmt";
    };
  };
}
