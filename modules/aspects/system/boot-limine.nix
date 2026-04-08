{
  flake.modules.nixos.boot-limine = { pkgs, lib, ... }: {
    boot.loader = {
      limine = {
        efiSupport = true;
        enable = true;
        maxGenerations = 10;
        secureBoot.enable = true;
        style.wallpapers = [ pkgs.nixos-artwork.wallpapers.simple-dark-gray-bootloader.gnomeFilePath ];
      };
      systemd-boot.enable = lib.mkForce false;
    };
  };
}
