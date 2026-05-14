{
  flake.modules.nixos.power = { config, ... }: {
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
    };

    systemd.sleep.settings.Sleep = {
      AllowSuspend = "yes";
      AllowHibernation = "yes";
      AllowSuspendThenHibernate = "yes";
      AllowHybridSleep = "yes";
      HibernateDelaySec = "30min";
    };

    boot.resumeDevice = "/dev/mapper/cryptroot";
    boot.kernelParams = [ "mem_sleep_default=deep" ];
    environment.systemPackages = [ config.boot.kernelPackages.cpupower ];
  };
}
