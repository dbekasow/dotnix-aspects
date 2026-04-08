{
  flake.modules.homeManager.rbw = { config, ... }: {
    programs.rbw = {
      enable = true;

      settings = {
        inherit (config.profile) email;
      };
    };
  };
}

