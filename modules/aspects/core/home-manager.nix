{ inputs, ... }: {
  flake.modules.nixos.core = { lib, config, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users = lib.mapAttrs
      (_name: cfg: { dotnix.user = cfg; })
      config.dotnix.host.members;
  };

  flake.modules.homeManger.core = { config, osConfig, ... }: {
    imports = config.dotnix.user.modules;

    home.username = "abc";
    home.stateVersion = osConfig.system.stateVersion;
  };
}
