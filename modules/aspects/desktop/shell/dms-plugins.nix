{ inputs, ... }: {
  flake.modules.homeManager.dms-plugins = { ... }: {
    imports = [ inputs.dms-plugins.modules.default ];

    programs.dank-material-shell.plugins = {
      dankBatteryAlerts.enable = true;
      dankBitwarden.enable = true;
      dankDesktopWeather.enable = true;
      displayManager.enable = true;
      nixMonitor.enable = true;
      powerOptions.enable = true;
      webSearch.enable = true;
    };
  };
}
