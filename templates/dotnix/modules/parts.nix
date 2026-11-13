# Consumer integration comes from the library's default adapter; development
# tooling remains an explicit optional import.
{ inputs, ... }: {
  flake-file.outputs = ''
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
      (inputs.import-tree ./modules)
  '';

  flake-file.inputs = {
    # Ride the library's own locked universe instead of drifting with
    # nixpkgs-unstable: a fresh consumer evaluates and builds against the
    # exact pins the library tests. Re-pin freely once the skeleton runs.
    nixpkgs.follows = "dotnix/nixpkgs";
    den.follows = "dotnix/den";
    home-manager.follows = "dotnix/home-manager";

    import-tree.url = "github:vic/import-tree";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    dotnix.url = "github:dbekasow/dotnix-aspects";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  imports = [
    inputs.dotnix.flakeModules.default
    inputs.dotnix.flakeModules.devTools # devshell, pre-commit, treefmt, agenix-rekey
  ];
}
