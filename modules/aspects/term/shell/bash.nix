{
  flake.modules.homeManager.bash = { lib, ... }: {
    programs.bash = {
      enable = lib.mkDefault false;
    };
  };
}

