{
  flake.modules.homeManager.alacritty = {
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
