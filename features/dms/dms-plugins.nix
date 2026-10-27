{ inputs, ... }: {
  flake-file.inputs.dms-plugins = {
    url = "github:AvengeMedia/dms-plugin-registry";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  dotnix.dms-plugins.homeManager = {
    imports = [ inputs.dms-plugins.homeModules.default ];

    programs.dank-material-shell.plugins = {
      dankBatteryAlerts.enable = true;
      dankDesktopWeather.enable = true;
      displayManager.enable = true;
      powerOptions.enable = true;
      webSearch.enable = true;
    };
  };
}
