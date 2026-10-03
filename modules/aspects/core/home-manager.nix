{ inputs, ... }: {
  # Neutral wiring only — the core→HM-core sharedModules coupling lives in
  # the core tier now (aspects/core.nix), not hidden in this aspect.
  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
  };
}
