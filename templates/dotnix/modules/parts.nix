# Consumer integration comes from the library's default adapter; development
# tooling remains an explicit optional import.
{ inputs, ... }: {
  flake-file.outputs = ''
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
      (inputs.import-tree ./modules)
  '';

  flake-file.inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    import-tree.url = "github:vic/import-tree";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    den = {
      url = "github:denful/den/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotnix = {
      url = "github:dbekasow/dotnix-aspects";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        den.follows = "den";
        home-manager.follows = "home-manager";
      };
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  imports = [
    inputs.dotnix.flakeModules.default
    inputs.dotnix.flakeModules.devTools # devshell, pre-commit, treefmt, agenix-rekey
  ];
}
