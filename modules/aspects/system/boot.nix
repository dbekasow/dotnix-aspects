{
  flake.modules.nixos.boot = { lib, pkgs, ... }: {
    boot = {
      initrd.systemd.enable = true;
      initrd.verbose = false;

      # VMs and nixos-anywhere dry-runs need this off.
      loader.efi.canTouchEfiVariables = lib.mkDefault true;
      loader.timeout = lib.mkDefault 3;

      # iwlwifi firmware regressions on linuxPackages_latest are a real
      # WLAN-drop cause on this fleet; pkgs.linuxPackages (LTS) is the first
      # A/B lever whenever WLAN misbehaves.
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      kernelParams = [
        "rd.udev.log_level=3"
        "udev.log_priority=3"
        "quiet"
      ];

      consoleLogLevel = 3;

      # Only hosts without an impermanence-style rollback gain anything
      # from a wiped /tmp; kept as the fleet default.
      tmp.cleanOnBoot = true;
    };

    # Fleet timeout policy; hosts stay free to tighten or loosen.
    systemd = let sec = lib.mkDefault "20s"; in {
      settings.Manager.DefaultTimeoutStartSec = sec;
      settings.Manager.DefaultTimeoutStopSec = sec;
      user.settings.Manager.DefaultTimeoutStopSec = sec;
    };
  };
}
