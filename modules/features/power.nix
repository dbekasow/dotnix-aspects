{
  dotnix.host.power.nixos = { config, ... }: {
    services = {
      upower.enable = true;
      power-profiles-daemon.enable = true;
    };

    environment.systemPackages = [ config.boot.kernelPackages.cpupower ];
  };
}
