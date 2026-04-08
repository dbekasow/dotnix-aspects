{
  flake.modules.homeManager.fish = {
    home.shell.enableFishIntegration = true;

    programs.fish = {
      enable = true;
    };
  };
}

