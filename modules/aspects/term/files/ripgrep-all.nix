{
  flake.modules.homeManager.terminal = {
    programs.ripgrep-all = {
      enable = true;

      custom_adapters = [ ];
    };
  };
}

