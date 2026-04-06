{
  flake.modules.homeManager.terminal = { config, ... }: {
    programs.rbw = {
      enable = true;

      settings = {
        inherit (config.profile) email;
      };
    };
  };
}

