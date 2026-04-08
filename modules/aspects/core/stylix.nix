{ inputs, ... }:
let
  defaultTheme = "catppuccin-mocha";
  schemeFor = pkgs: theme: "${pkgs.base16-schemes}/share/themes/${theme}.yaml";
in
{
  flake.modules.nixos.stylix = { pkgs, ... }: {
    imports = [ inputs.stylix.nixosModules.stylix ];

    stylix = {
      enable = true;
      enableReleaseChecks = false;
      # Disable auto-import: we manage HM module manually in homeManager.core
      # to keep HM wiring explicit and allow per-user theme overrides
      homeManagerIntegration.autoImport = false;
      base16Scheme = schemeFor pkgs defaultTheme;
    };
  };

  flake.modules.homeManager.stylix = { config, pkgs, ... }: {
    imports = [ inputs.stylix.homeModules.stylix ];

    stylix = let inherit (config.profile) theme; in {
      enable = true;
      base16Scheme = schemeFor pkgs theme;
      polarity = "dark";
    };
  };
}
