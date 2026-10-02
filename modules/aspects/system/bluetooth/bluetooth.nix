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
}
