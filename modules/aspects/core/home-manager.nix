{ inputs, config, ... }:
let inherit (config.flake) modules; in {
  flake.modules.nixos.core = { lib, config, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users = lib.mapAttrs
        (username: user: {
          dotnix = { inherit username user; };
          imports = user.modules;
        })
        config.dotnix.host.members;
      sharedModules = [ modules.homeManager.core ];
    };
  };

  flake.modules.homeManager.core = { config, osConfig, ... }: {
    home.username = config.dotnix.username;
    home.stateVersion = osConfig.system.stateVersion;
  };
}
