{
  flake.modules.homeManager.development = { config, lib, pkgs, ... }: {
    services.git-sync = {
      enable = lib.mkDefault (config.dotnix.user.repositories != [ ]);
      extraPackages = with pkgs; [ git-lfs ];

      repositories =
        let home = config.home.homeDirectory;
        in lib.foldl'
          (acc: group:
            acc // lib.listToAttrs (map
              (project: {
                name = project;
                value = {
                  uri = "${group.url}/${project}";
                  path = "${home}/${group.destination}/${project}";
                  inherit (group) interval;
                };
              })
              group.projects)
          )
          { }
          config.dotnix.user.repositories;
    };
  };
}
