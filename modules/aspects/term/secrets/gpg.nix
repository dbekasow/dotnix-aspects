{
  flake.modules.homeManager.terminal = {
    programs.gpg = {
      enable = true;

      settings = { };
    };
  };
}

