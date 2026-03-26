{
  flake.modules.homeManager.development = { config, lib, ... }: {
    services.git-sync = {
      enable = lib.mkDefault (config.dotnix.user.repositories != [ ]);

      repositories =
        let home = config.home.homeDirectory;
        in lib.foldl'
          (acc: group:
            acc // lib.listToAttrs (map
              (project: {
                name = project;
                value = {
                  url = "${group.url}/${project}";
                  path = "${home}/${group.destination}/${project}";
                  inherit (group) branch;
                };
              })
              group.projects)
          )
          { }
          config.dotnix.user.repositories;
    };
  };
}
