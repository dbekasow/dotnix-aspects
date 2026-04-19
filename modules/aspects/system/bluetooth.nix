{
  flake.modules.nixos.bluetooth = { pkgs, ... }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;

      settings.General = {
        Experimental = true;
        FastConnectable = true;
        ControllerMode = "dual";
      };
    };

    environment.systemPackages = [ pkgs.bluetui ];
  };
}
