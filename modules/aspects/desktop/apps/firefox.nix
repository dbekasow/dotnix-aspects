{
  flake.modules.homeManager.desktop = {
    programs.firefox = {
      enable = true;
    };

    stylix.targets.firefox.profileNames = [ "default" ];
  };
}

