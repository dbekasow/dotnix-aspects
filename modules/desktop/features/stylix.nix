{ inputs, ... }:
let
  # Library dependency inputs (stylix modules) stay closed over the library flake.
  libraryInputs = inputs;
  sharedConfig = { lib, pkgs, ... }: {
    stylix = {
      enable = lib.mkDefault true;
      autoEnable = lib.mkDefault true;

      base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      polarity = lib.mkDefault "dark";

      cursor = {
        package = lib.mkDefault pkgs.bibata-cursors;
        name = lib.mkDefault "Bibata-Modern-Ice";
        size = lib.mkDefault 20;
      };

      fonts = with pkgs; {
        serif = { package = lib.mkDefault lora; name = lib.mkDefault "Lora"; };
        sansSerif = { package = lib.mkDefault inter; name = lib.mkDefault "Inter"; };
        emoji = { package = lib.mkDefault noto-fonts-color-emoji; name = lib.mkDefault "Noto Color Emoji"; };
        monospace = { package = lib.mkDefault nerd-fonts.jetbrains-mono; name = lib.mkDefault "JetBrainsMono Nerd Font Mono"; };

        sizes = {
          terminal = lib.mkDefault 11;
          applications = lib.mkDefault 11;
          desktop = lib.mkDefault 10;
        };
      };

      icons = {
        enable = lib.mkDefault true;
        package = lib.mkDefault pkgs.papirus-icon-theme;
        light = lib.mkDefault "Papirus-Light";
        dark = lib.mkDefault "Papirus-Dark";
      };
    };
  };
in
{
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      nur.follows = "nur";
    };
  };

  dotnix.host.stylix.nixos = {
    imports = [
      {
        key = "dotnix:stylix:nixos";
        imports = [ libraryInputs.stylix.nixosModules.stylix sharedConfig ];
      }
    ];
    stylix.enableReleaseChecks = false;
    stylix.homeManagerIntegration.autoImport = false;
  };

  dotnix.home.stylix.homeManager = {
    imports = [
      {
        key = "dotnix:stylix:homeManager";
        imports = [ libraryInputs.stylix.homeModules.stylix sharedConfig ];
      }
    ];
    stylix.overlays.enable = false;
  };
}
