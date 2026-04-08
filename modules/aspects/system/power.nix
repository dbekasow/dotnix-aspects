{
  flake.modules.nixos.power = { lib, ... }: {
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

    boot.kernelParams = lib.mkDefault [ "mem_sleep_default=deep" ];

    systemd.sleep.extraConfig = ''
      AllowSuspend=yes
      AllowHibernation=no
      AllowSuspendThenHibernate=no
      AllowHybridSleep=no
    '';
  };
}
