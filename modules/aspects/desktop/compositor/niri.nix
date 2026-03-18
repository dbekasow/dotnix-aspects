{ inputs, ... }: {
  flake.modules.nixos.desktop = {
    imports = [ inputs.niri.nixosModules.niri ];

    programs.niri.enable = true;
  };

  flake.modules.homeManager.desktop = {
    programs.niri.settings = {
      spawn-at-startup = [ ];

      input = {
        keyboard.xkb.layout = "de";
        touchpad = {
          accel-profile = "adaptive";
        };
      };

      layout = {
        background-color = "transparent";
        border.width = 2;
        focus-ring.width = 2;
        gaps = 6;
      };
    };
  };
}
