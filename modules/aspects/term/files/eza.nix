{
  flake.modules.homeManager.terminal = {
    programs.eza = {
      enable = true;

      colors = "always";
      icons = "auto";

      git = true;

      extraOptions = [ ];
    };
  };
}

