{
  dotnix.host.yubioath-flutter.nixos = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.yubioath-flutter ];
  };
}
