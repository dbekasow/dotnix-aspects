{
  flake.modules.homeManager.terminal = {
    programs.nushell = {
      enable = true;

      plugins = [ ];
      settings = { };
    };
  };
}

