{ inputs, ... }: {
  flake.modules.nixos.core = {
    imports = [ inputs.stylix.nixosModules.stylix ];

    stylix = {
      enable = true;
      enableReleaseChecks = false;
      # Disable auto-import: we manage HM module manually in homeManager.core
      # to keep HM wiring explicit and allow per-user theme overrides
      homeManagerIntegration.autoImport = false;
    };
  };

  flake.modules.homeManager.core = { config, pkgs, ... }: {
    imports = [ inputs.stylix.homeModules.stylix ];

    stylix = let inherit (config.dotnix.user) theme; in {
      enable = true;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/${theme}.yaml";
      polarity = "dark";
    };
  };
}
