{
  dotnix.host.yubikey.nixos = { pkgs, ... }: {
    services.pcscd.enable = true;
    services.udev.packages = [ pkgs.yubikey-personalization ];
  };
}
