let
  cursorShaders = pkgs: pkgs.fetchFromGitHub {
    owner = "sahaj-b";
    repo = "ghostty-cursor-shaders";
    rev = "4faa83e4b9306750fc8de64b38c6f53c57862db8";
    hash = "sha256-ruhEqXnWRCYdX5mRczpY3rj1DTdxyY3BoN9pdlDOKrE=";
  };
in
{
  flake.modules.homeManager.ghostty = { pkgs, ... }: {
    programs.ghostty = {
      enable = true;

      settings = {
        background-opacity = 0.9;
        background-opacity-cells = true;
        background-blur = 20;
        custom-shader = "${cursorShaders pkgs}/cursor_warp.glsl";
        custom-shader-animation = true;
        cursor-opacity = 0.75;
        shell-integration = "detect";
        shell-integration-features = "cursor,title,sudo";
        window-decoration = false;
        window-inherit-working-directory = true;
        window-inherit-font-size = true;
      };
    };
  };
}
