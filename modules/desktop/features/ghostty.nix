let
  cursorShaders = pkgs: pkgs.fetchFromGitHub {
    owner = "sahaj-b";
    repo = "ghostty-cursor-shaders";
    rev = "4faa83e4b9306750fc8de64b38c6f53c57862db8";
    hash = "sha256-ruhEqXnWRCYdX5mRczpY3rj1DTdxyY3BoN9pdlDOKrE=";
  };
in
{
  dotnix.home.ghostty.homeManager = { lib, pkgs, ... }: {
    imports = [
      (import ../lib/niri-launcher.nix {
        key = "Mod+T";
        command = "ghostty";
        enabled = { config, ... }: config.programs.ghostty.enable;
      })
    ];

    programs.ghostty = {
      enable = true;

      settings = {
        app-notifications = "no-clipboard-copy";
        # Keep blur off to limit compositing cost.
        background-blur = false;
        # Avoid emitting a second opacity from the Stylix terminal default.
        background-opacity = lib.mkOverride 90 0.94;
        background-opacity-cells = true;
        confirm-close-surface = false;
        cursor-opacity = 0.75;
        custom-shader = "${cursorShaders pkgs}/cursor_warp.glsl";
        custom-shader-animation = true;
        shell-integration = "detect";
        shell-integration-features = "cursor,title,sudo";
        window-decoration = false;
        window-inherit-font-size = true;
        window-inherit-working-directory = true;
      };
    };
  };
}
