{
  flake.modules.homeManager.eza = {
    programs.eza = {
      enable = true;

      colors = "always";
      icons = "auto";

      git = true;

      extraOptions = [ ];
    };
  };
}

