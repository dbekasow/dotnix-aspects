{
  flake.modules.homeManager.ghostty = {
    programs.ghostty = {
      enable = true;

      settings = {
        cursor-opacity = 0.75;
        font-size = 12;
        window-decoration = false;
      };
    };
  };
}
