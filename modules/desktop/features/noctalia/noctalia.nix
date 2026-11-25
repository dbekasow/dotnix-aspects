{ dotnix, inputs, lib, ... }:
# Noctalia — the niri-first-class alternative to DMS. Select one shell
# per host for its integrated homes. Its built-in palette
# engine is a second theming authority: app templates stay off (stylix
# owns app themes) and custom palettes can be fed from matugen through
# programs.noctalia.customPalettes when the bridge is wanted.
{
  flake-file.inputs.noctalia = {
    url = "github:noctalia-dev/noctalia/v5.2.1";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  dotnix.home.noctalia.homeManager = {
    # The pinned Home Manager ships its own programs.noctalia; disable it so the
    # flake module (pinned config schema + package) stays the single owner.
    # Importing both declares every option twice and fails evaluation.
    disabledModules = [ "programs/noctalia" ];
    imports = [ inputs.noctalia.homeModules.default ];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;

      settings = {
        bar.default = {
          background_opacity = 0.85;
          center = lib.mkDefault [ "clock" "clock-weather-gap" "weather" ];
          end = lib.mkDefault [ "tray" "notifications" "clipboard" "battery" "control-center" "session" ];
        };
        widget = {
          tray.drawer = true;
          weather.show_condition = false;
          clock-weather-gap = {
            type = "spacer";
            length = 4;
          };
          battery = {
            display_mode = "graphic";
            show_label = false;
          };
        };

        # IP-based; no personal data lands in the shared aspect.
        location.auto_locate = true;
        weather.enabled = true;
      };
    };
  };

  dotnix.host.noctalia.provides.to-users.includes = [ dotnix.home.noctalia ];
  dotnix.host.noctalia.nixos = { config, ... }: {
    assertions = [{
      assertion = !(config.programs.dank-material-shell.enable or false);
      message = "DMS and Noctalia cannot both be selected on the same host.";
    }];

    nix.settings = {
      extra-substituters = [ "https://noctalia.cachix.org" ];
      extra-trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
    };
  };
}
