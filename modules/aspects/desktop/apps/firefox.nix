{
  flake.modules.homeManager.firefox = {
    programs.firefox = {
      enable = true;
    };

    stylix.targets.firefox.profileNames = [ "default" ];
  };
}

