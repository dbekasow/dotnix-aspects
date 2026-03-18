{
  flake.modules.nixos.system = { pkgs, ... }: {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    environment.systemPackages = [ pkgs.bluetui ];

    services.blueman.enable = true;
  };
}
