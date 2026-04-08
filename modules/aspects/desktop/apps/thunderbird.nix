{
  flake.modules.homeManager.thunderbird = {
    programs.thunderbird = {
      enable = true;

      profiles = { };
      settings = { };
    };
  };
}

