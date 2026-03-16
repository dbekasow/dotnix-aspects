{
  flake.modules.homeManager.terminal = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;

      silent = true;

      config = { };
    };
  };
}

