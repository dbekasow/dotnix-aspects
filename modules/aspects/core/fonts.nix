{
  flake.modules.nixos.fonts = { pkgs, ... }: {
    fonts = {
      enableDefaultPackages = false;

      packages = with pkgs; [
        material-symbols
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        nerd-fonts.jetbrains-mono
      ];

      fontconfig = {
        enable = true;
        antialias = true;
        hinting = {
          enable = true;
          autohint = false;
          style = "full";
        };
        subpixel.lcdfilter = "default";
        subpixel.rgba = "rgb";
      };

      fontDir.enable = true;
      fontDir.decompressFonts = true;
    };
  };
}
