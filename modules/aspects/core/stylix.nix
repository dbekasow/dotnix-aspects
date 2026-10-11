{ inputs, ... }:
let
  # Library dependency inputs (stylix modules) stay closed over the library
  # flake; the wallpaper path resolves from the aspect `inputs` argument
  # (consumer flake) exposed by den.batteries.flake-scope.
  libraryInputs = inputs;
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
        serif = { package = lora; name = "Lora"; };
        sansSerif = { package = inter; name = "Inter"; };
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
  flake-file.inputs.stylix = {
    url = "github:nix-community/stylix";
    inputs = {
      nixpkgs.follows = "nixpkgs";
      nur.follows = "nur";
    };
  };

  dotnix.stylix = { inputs, ... }: {
    nixos = {
      # Keyed so host- and user-scope copies collapse to one module tree; the
      # package-valued stylix settings reject duplicate (even equal) definitions.
      imports = [
        {
          key = "dotnix:stylix:nixos";
          imports = [ libraryInputs.stylix.nixosModules.stylix sharedConfig ];
        }
      ];
      stylix.enableReleaseChecks = false;
      stylix.homeManagerIntegration.autoImport = false;
    };

    homeManager = { config, lib, ... }: {
      imports = [
        {
          key = "dotnix:stylix:homeManager";
          imports = [ libraryInputs.stylix.homeModules.stylix sharedConfig ];
        }
      ];
      stylix.overlays.enable = false;
      stylix.image =
        let
          path = "${inputs.self}/modules/users/${config.home.username}/assets/wallpaper.png";
        in
        lib.mkIf (lib.pathExists path) path;
    };
  };
}
