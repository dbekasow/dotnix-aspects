{
  flake.modules.nixos.power = { config, lib, ... }: {
    services = {
      logind.settings.Login = {
        HandlePowerKey = "suspend-then-hibernate";
        HandleLidSwitch = "suspend-then-hibernate";
        HandleLidSwitchExternalPower = "lock";
      };

      upower = {
        enable = true;
        percentageLow = 30;
        percentageCritical = 20;
        percentageAction = 10;
        criticalPowerAction = "Hibernate";
      };

      power-profiles-daemon.enable = true;

      # Alder Lake parts need active thermal management: without thermald
      # the clocks wedge under sustained load. mkDefault so AMD hosts can
      # turn this off (thermald is Intel DPTF only).
      thermald.enable = lib.mkDefault true;
    };

    systemd.sleep.settings.Sleep = {
      AllowSuspend = "yes";
      AllowHibernation = "yes";
      AllowSuspendThenHibernate = "yes";
      AllowHybridSleep = "yes";
      HibernateDelaySec = "30min";
    };

    # Swapfile hibernate needs the provisioned offset from
    # `btrfs inspect-internal map-swapfile -r /swap/swapfile`; see
    # docs/hibernate.md. Offset depends on the swapfile and page size, so
    # hosts supply it themselves. The resume device is separate; mkDefault
    # suits the encrypted layout without overriding host layouts.
    boot.resumeDevice = lib.mkDefault "/dev/mapper/cryptroot";

    # Most Alder Lake Dells are s2idle-only with a broken S3 path — forcing
    # "deep" kills WiFi after resume on them, so the forcing must stay soft.
    # The boot/network-wifi aspects define kernelParams with plain priority,
    # so this mkDefault definition is priority-dropped wherever they are
    # imported: mem_sleep_default=deep only applies on hosts that set it
    # themselves, after `cat /sys/power/mem_sleep` shows deep as supported.
    # A host adding its own kernelParams (e.g. resume_offset) must re-add
    # deep explicitly if wanted.
    boot.kernelParams = lib.mkDefault [ "mem_sleep_default=deep" ];
    environment.systemPackages = [ config.boot.kernelPackages.cpupower ];
  };
}
