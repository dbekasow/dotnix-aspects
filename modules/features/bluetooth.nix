{
  dotnix.host.bluetooth.nixos = { pkgs, ... }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;

      package = pkgs.bluez5-experimental;

      settings.General = {
        Experimental = true;
        FastConnectable = true;
      };
    };

    environment.systemPackages = [ pkgs.bluetui ];
  };

  # Impermanence contribution for bluetooth.
  dotnix.host.bluetooth.systemPersistence = {
    environment.persistence."/persist".directories = [ "/var/lib/bluetooth" ];
  };
}
