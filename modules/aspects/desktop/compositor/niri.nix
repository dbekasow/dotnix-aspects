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

  flake.modules.homeManager.niri = {
    programs.niri.settings = {
      input = {
        keyboard.xkb.options = "caps:escape";
        keyboard.xkb.layout = "de";
        touchpad = {
          accel-profile = "adaptive";
          dwt = true;
          tap = true;
          natural-scroll = true;
          middle-emulation = true;
        };
      };
    };
  };
}
