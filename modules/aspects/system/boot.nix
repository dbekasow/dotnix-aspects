{
  flake.modules.nixos.boot = { lib, pkgs, ... }: {
    boot = {
      bootspec.enable = true;

      initrd.systemd.enable = true;
      initrd.verbose = false;

      loader.efi.canTouchEfiVariables = true;
      loader.timeout = lib.mkDefault 3;

      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      kernelParams = [
        "rd.systemd.show_status=auto"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
        "quiet"
      ];

      consoleLogLevel = 3;
      supportedFilesystems.zfs = false;
    };
  };
}
