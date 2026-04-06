{ inputs, ... }: {
  flake.modules.nixos.desktop = {
    imports = [ inputs.niri.nixosModules.niri ];

    programs.niri.enable = true;

    nix.settings = {
      substituters = [ "https://niri.cachix.org" ];
      trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=" ];
    };
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
