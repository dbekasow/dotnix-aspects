{ inputs, config, ... }:
let inherit (config.flake) modules; in {
  flake.modules.nixos.core = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      sharedModules = [ modules.homeManager.core ];
    };
  };

  flake.modules.homeManager.core = { osConfig, ... }: {
    home.stateVersion = osConfig.system.stateVersion;
  };
}
