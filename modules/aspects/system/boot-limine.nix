{
  flake.modules.nixos.boot-limine = { lib, pkgs, ... }: {
    boot.loader.limine = {
      enable = lib.mkDefault false;
      enableEditor = false;
      efiSupport = true;
      maxGenerations = 10;
      secureBoot.enable = false;
      style.wallpapers = [ pkgs.nixos-artwork.wallpapers.binary-black.gnomeFilePath ];
      style.wallpaperStyle = lib.mkForce "centered";
    };
  };
}
