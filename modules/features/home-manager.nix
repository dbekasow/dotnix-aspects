{ inputs, ... }: {
  flake-file.inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  # Neutral wiring only — the core→HM-core sharedModules coupling lives in
  # the core tier now (aspects/core.nix), not hidden in this aspect.
  dotnix.host.home-manager.nixos = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
