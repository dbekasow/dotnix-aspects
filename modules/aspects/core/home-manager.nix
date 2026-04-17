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

  flake.modules.homeManager.home-manager = { osConfig, ... }: {
    home.stateVersion = osConfig.system.stateVersion;
  };
}
