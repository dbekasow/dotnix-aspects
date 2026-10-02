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

  flake.modules.homeManager.home-manager = { lib, osConfig, ... }: {
    home.stateVersion =
      let
        hmVersions = [ "26.05" "26.11" ];
        sys = osConfig.system.stateVersion;
      in
      if lib.elem sys hmVersions then sys else lib.last hmVersions;
  };
}
