{
  flake.modules.homeManager.devops = {
    programs.k9s = {
      enable = true;

      plugins = { };
      settings = { };
      skins = { };
      views = { };
    };
  };
}

