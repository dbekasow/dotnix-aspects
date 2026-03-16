{
  flake.modules.homeManager.terminal = {
    home.shell.enableFishIntegration = true;

    programs.fish = {
      enable = true;
    };
  };
}

