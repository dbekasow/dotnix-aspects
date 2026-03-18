{
  flake.modules.homeManager.desktop = {
    programs.thunderbird = {
      enable = true;

      profiles = { };
      settings = { };
    };
  };
}

