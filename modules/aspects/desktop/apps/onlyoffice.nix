{
  flake.modules.homeManager.desktop = {
    programs.onlyoffice = {
      enable = true;

      settings = { };
    };
  };
}

