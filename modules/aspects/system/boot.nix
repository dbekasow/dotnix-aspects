{
  flake.modules.nixos.boot = { lib, pkgs, config, ... }: {
    boot = {
      bootspec.enable = true;
      initrd.systemd.enable = true;
      plymouth.enable = true;

      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      kernelParams = [
        "plymouth.use-simpledrm"
        "quiet"
        "rd.udev.log_level=3"
        "systemd.show_status=auto"
      ];

      loader = {
        systemd-boot.enable = lib.mkDefault true;
        efi.canTouchEfiVariables = true;
      };
    };

    environment.systemPackages = [ config.boot.kernelPackages.cpupower ];
  };
}
