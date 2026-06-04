{ inputs, config, ... }:
let inherit (config.flake) modules; in {
  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [ modules.homeManager.core ];
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
