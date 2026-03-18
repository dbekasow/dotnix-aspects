{
  flake.modules.homeManager.development-sync = { config, lib, ... }: {
    services.git-sync = let inherit (config.dotnix.user) repositories; in {
      enable = repositories != { };
      repositories = lib.mapAttrs
        (name: repo: repo // { path = "${config.home.homeDirectory}/repositories/${name}"; })
        repositories;
    };
  };
}
