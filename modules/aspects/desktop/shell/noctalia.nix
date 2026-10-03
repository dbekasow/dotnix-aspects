{ inputs, lib, ... }:
let
  hasBuiltInNoctalia = lib.pathExists "${inputs.home-manager}/modules/programs/noctalia/default.nix";
in
# Noctalia — the niri-first-class alternative to DMS. One shell per
  # session: import dms OR noctalia, never both. Its built-in palette
  # engine is a second theming authority: app templates stay off (stylix
  # owns app themes) and custom palettes can be fed from matugen through
  # programs.noctalia.customPalettes when the bridge is wanted.
{
  flake.modules.homeManager.noctalia = { pkgs, ... }: {
    # Recent Home Manager pins include this module automatically; importing
    # Noctalia's copy as well would declare its options twice.
    imports = lib.optional (!hasBuiltInNoctalia) inputs.noctalia.homeModules.default;

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
      package = lib.mkIf hasBuiltInNoctalia (
        lib.mkDefault inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      );
    };
  };
}
