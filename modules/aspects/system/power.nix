{
  flake.modules.nixos.power = {
    services = {
      logind.settings.Login = {
        HandlePowerKey = "suspend";
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "lock";
      };

      power-profiles-daemon.enable = true;

      upower = {
        enable = true;
        percentageLow = 30;
        percentageCritical = 20;
        percentageAction = 10;
        criticalPowerAction = "PowerOff";
      };
    };

    boot.kernelParams = [ "mem_sleep_default=deep" ];

    systemd.sleep.settings.Sleep = {
      AllowSuspend = "yes";
      AllowHibernation = "no";
      AllowSuspendThenHibernate = "no";
      AllowHybridSleep = "no";
    };
  };
}
