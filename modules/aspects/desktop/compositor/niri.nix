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

    # Disable broken polkit-kde-agent, use polkit-gnome instead
    systemd.user.services.niri-flake-polkit.enable = false;
  };

  flake.modules.homeManager.niri = { lib, pkgs, ... }: {
    programs.niri.settings = {
      hotkey-overlay.skip-at-startup = true;

      xwayland-satellite.enable = true;
      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite-unstable;

      input = {
        keyboard.xkb.options = "caps:escape";
        keyboard.xkb.layout = "de";

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
          geometry-corner-radius = lib.genAttrs
            [ "top-left" "top-right" "bottom-left" "bottom-right" ]
            (lib.const 10.0);
          clip-to-geometry = true;
          draw-border-with-background = false;
        }
        {
          matches = [{ app-id = "firefox$"; }];
          clip-to-geometry = false;
        }
        {
          matches = [{ app-id = "firefox$"; title = "^Picture-in-Picture$"; }];
          open-floating = true;
          default-floating-position = {
            x = 32;
            y = 32;
            relative-to = "top-right";
          };
        }
      ];
    };
  };
}
