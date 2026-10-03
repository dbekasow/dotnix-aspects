{ inputs, lib, ... }:
# Noctalia — the niri-first-class alternative to DMS. One shell per
# session: import dms OR noctalia, never both. Its built-in palette
# engine is a second theming authority: app templates stay off (stylix
# owns app themes) and custom palettes can be fed from matugen through
# programs.noctalia.customPalettes when the bridge is wanted.
{
  flake.modules.homeManager.noctalia = {
    # The pinned Home Manager ships its own programs.noctalia; disable it so the
    # flake module (pinned config schema + package) stays the single owner.
    # Importing both declares every option twice and fails evaluation.
    disabledModules = [ "programs/noctalia" ];
    imports = [ inputs.noctalia.homeModules.default ];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;

      # Upstream keeps the lockscreen and lock_before_suspend on but ships every
      # idle.behavior.* disabled, so an idle session never locks. Mirror the DMS
      # timeouts (noctalia cannot split AC/battery); mkDefault lets hosts retune.
      # Only real deltas against upstream defaults — rewriting defaults makes
      # noctalia re-serialize its config on every start.
      settings = lib.mkDefault {
        # Enables the backdrop layer that the niri layer-rule places in the
        # overview; see noctalia/niri.nix.
        backdrop.enabled = true;

        # Single source for weather/night-light/theme scheduling. IP-based, so
        # no personal data lands in the shared aspect; hosts can pin an address
        # or latitude/longitude instead (mkDefault is overridable).
        location.auto_locate = true;
        weather.enabled = true;

        # Upstream default is 10; matches power.nix's upower percentageCritical.
        battery.warning_threshold = 20;

        idle.behavior = {
          lock = { enabled = true; timeout = 300; action = "lock"; };
          screen-off = { enabled = true; timeout = 600; action = "screen_off"; };
          lock-and-suspend = { enabled = true; timeout = 1800; action = "lock_and_suspend"; };
        };
      };
    };
  };

  flake.modules.nixos.noctalia = {
    nix.settings = {
      extra-substituters = [ "https://noctalia.cachix.org" ];
      extra-trusted-public-keys = [ "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4=" ];
    };
  };
}
