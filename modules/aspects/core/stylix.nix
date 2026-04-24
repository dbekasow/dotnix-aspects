{ inputs, ... }:
let
  sharedConfig = { pkgs, ... }: {
    stylix = {
      enable = true;
      autoEnable = true;

      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      polarity = "dark";

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 20;
      };

      fonts = with pkgs; {
        serif = { package = noto-fonts; name = "Noto Serif"; };
        sansSerif = { package = noto-fonts; name = "Noto Sans"; };
        emoji = { package = noto-fonts-color-emoji; name = "Noto Color Emoji"; };
        monospace = { package = nerd-fonts.jetbrains-mono; name = "JetBrainsMono Nerd Font Mono"; };

        sizes = {
          terminal = 11;
          applications = 11;
          desktop = 10;
        };
      };

      icons = {
        enable = true;
        package = pkgs.papirus-icon-theme;
        light = "Papirus-Light";
        dark = "Papirus-Dark";
      };
    };
  };
in
{
  flake.modules.nixos.stylix = {
    imports = [ inputs.stylix.nixosModules.stylix sharedConfig ];
    stylix.homeManagerIntegration.autoImport = false;
  };

  flake.modules.homeManager.stylix = {
    imports = [ inputs.stylix.homeModules.stylix sharedConfig ];
  };
}
