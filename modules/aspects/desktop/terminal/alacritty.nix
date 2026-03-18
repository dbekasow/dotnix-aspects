{
  flake.modules.homeManager.desktop = {
    programs.alacritty = {
      enable = true;

      settings = {
        window = {
          decorations = "none";
          title = "Terminal";
          opacity = 0.95;
        };
      };
    };
  };
}
