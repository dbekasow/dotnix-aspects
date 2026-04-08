{
  flake.modules.nixos.fonts = { pkgs, ... }: {
    fonts = {
      enableDefaultPackages = false;

      packages = with pkgs; [
        # icon fonts
        material-symbols

        # normal fonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji

        # nerdfonts
        nerd-fonts.symbols-only
        cozette
      ];

      fontconfig = {
        enable = true;
        antialias = true;
        hinting = {
          enable = true;
          autohint = false;
          style = "full";
        };
        subpixel = {
          lcdfilter = "default";
          rgba = "rgb";
        };
      };

      fontDir = {
        enable = true;
        decompressFonts = true;
      };
    };
  };
}
