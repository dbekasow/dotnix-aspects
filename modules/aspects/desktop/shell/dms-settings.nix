# Only real deltas against the pinned DMS rev a609b5f — DMS manages all
# other defaults itself. Writing upstream defaults or a configVersion here
# made DMS re-migrate settings.json (v5 → v33) on every start and home-manager
# roll the file back on every switch.
{
  flake.modules.homeManager.dms = { lib, ... }: {
    # mkDefault so hosts can override individual leaves without mkForce.
    programs.dank-material-shell.settings = lib.mkDefault {
      widgetBackgroundColor = "sch";
      blurLayerOutlineOpacity = 0.12;

      # power/idle timeouts are 0 (= disabled) upstream
      acMonitorTimeout = 300; # 5 min → monitor off
      acLockTimeout = 300; # 5 min → lock (simultaneous with monitor)
      acSuspendTimeout = 1800; # 30 min → suspend
      acSuspendBehavior = 2; # suspend then hibernate
      acProfileName = "performance";
      batteryMonitorTimeout = 120; # 2 min → monitor off
      batteryLockTimeout = 120; # 2 min → lock (simultaneous with monitor)
      batterySuspendTimeout = 600; # 10 min → suspend
      # "balanced" instead of "power-saver": PPD power-saver selects the
      # most energy-saving EPP/governor and made the desktop noticeably
      # sluggish on battery; balanced is the responsive compromise.
      batteryProfileName = "balanced";
      lockBeforeSuspend = true; # always lock before suspend

      lockScreenShowPowerActions = true;
      lockScreenPowerOffMonitorsOnLock = true; # monitor off when manually locked
      enableU2f = true; # yubikey auth on lockscreen
      u2fMode = "and"; # password AND key, upstream default is "or"

      # DMS's bar list bootstrap has no fallback for missing widget lists,
      # so the upstream-default lists must be spelled out next to the deltas
      barConfigs = [{
        id = "default";
        leftWidgets = [ "launcherButton" "workspaceSwitcher" "focusedWindow" ];
        centerWidgets = [ "music" "clock" "weather" ];
        rightWidgets = [ "systemTray" "clipboard" "cpuUsage" "memUsage" "notificationButton" "battery" "controlCenterButton" ];
        transparency = 0.1; # upstream default is fully opaque
        widgetTransparency = 0.2;
      }];
    };
  };
}
