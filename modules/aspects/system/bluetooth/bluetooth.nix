{
  flake.modules.nixos.bluetooth = { pkgs, ... }: {
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
  flake.modules.nixos.impermanence = {
    environment.persistence."/persist".directories = [ "/var/lib/bluetooth" ];
  };
}
