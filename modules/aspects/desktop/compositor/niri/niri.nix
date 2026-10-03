{ inputs, ... }: {
  flake.modules.nixos.niri = { pkgs, ... }: {
    imports = [ inputs.niri.nixosModules.niri ];

    nix.settings = {
      substituters = [ "https://niri.cachix.org" ];
      trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=" ];
    };

    nixpkgs.overlays = [ inputs.niri.overlays.niri ];

    programs.niri.enable = true;
    programs.niri.package = pkgs.niri-unstable;
  };

  flake.modules.homeManager.niri = { lib, specialArgs, pkgs, ... }: {
    imports = lib.optional (!((specialArgs.osConfig or { }) ? niri-flake)) inputs.niri.homeModules.niri;

    programs.niri.settings = {
      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite-unstable;
      hotkey-overlay.skip-at-startup = true;

      # niri's default ~/Pictures (capital P) collides with the persisted
      # xdg spelling — see shell/xdg.
      screenshot-path = "~/pictures/screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      input = {
        keyboard.xkb.options = "caps:escape";
        keyboard.xkb.layout = "de";
        keyboard.numlock = true;

        mouse = {
          accel-profile = "adaptive";
          accel-speed = 0.1;
          scroll-factor = 2;
        };

        touchpad = {
          accel-profile = "adaptive";
          dwt = true;
          tap = true;
          natural-scroll = true;
          middle-emulation = true;
        };

        focus-follows-mouse.enable = true;
        focus-follows-mouse.max-scroll-amount = "0%";
      };

      window-rules = [
        {
          geometry-corner-radius = lib.genAttrs [ "top-left" "top-right" "bottom-left" "bottom-right" ] (
            lib.const 10.0
          );
          clip-to-geometry = true;
          draw-border-with-background = false;
        }
        # Background blur behind the semitransparent terminals — niri's
        # window-effects (since 26.04) instead of per-app client requests.
        # xray stays on (default with any effect): the blurred wallpaper is
        # computed once instead of per window. GPU cost is real, so only the
        # transparent apps in this stack get the rule.
        {
          matches = [{ app-id = "^(ghostty|Alacritty)$"; }];
          background-effect.blur = true;
        }
      ];
    };
  };
}
