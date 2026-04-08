{
  flake.modules.homeManager.ghostty = {
    programs.ghostty = {
      enable = true;

      settings = {
        cursor-opacity = 0.75;
        custom-shader-animation = true;
        font-size = 12;
        window-decoration = false;
      };
    };
  };
}
