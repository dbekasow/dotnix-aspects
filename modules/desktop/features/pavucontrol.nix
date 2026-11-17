{
  dotnix.host.pavucontrol.nixos = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.pavucontrol ];
  };
}
