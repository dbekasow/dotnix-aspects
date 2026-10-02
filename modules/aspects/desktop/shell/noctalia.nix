{ inputs, ... }: {
  # Noctalia — the niri-first-class alternative to DMS. One shell per
  # session: import dms OR noctalia, never both. Its built-in palette
  # engine is a second theming authority: app templates stay off (stylix
  # owns app themes) and custom palettes can be fed from matugen through
  # programs.noctalia.customPalettes when the bridge is wanted.
  flake.modules.homeManager.noctalia = {
    imports = [ inputs.noctalia.homeModules.default ];

    programs.noctalia = {
      enable = true;
      systemd.enable = true;
    };
  };
}
