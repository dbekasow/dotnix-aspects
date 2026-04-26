{
  flake.modules.nixos.power = { config, ... }: {
    services = {
      logind.settings.Login = {
        HandlePowerKey = "suspend";
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "lock";
      };

      upower = {
        enable = true;
        percentageLow = 30;
        percentageCritical = 20;
        percentageAction = 10;
        criticalPowerAction = "PowerOff";
      };
    };

    systemd.sleep.settings.Sleep = {
      AllowSuspend = "yes";
      AllowHibernation = "no";
      AllowSuspendThenHibernate = "no";
      AllowHybridSleep = "no";
    };

    boot.kernelParams = [ "mem_sleep_default=deep" ];
    environment.systemPackages = [ config.boot.kernelPackages.cpupower ];
  };
}
