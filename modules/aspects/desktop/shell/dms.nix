{ inputs, ... }: {
  flake.modules.nixos.dms = {
    imports = [ inputs.dms.nixosModules.dank-material-shell ];

    programs.dank-material-shell = {
      enable = true;

      systemd.enable = true;
      systemd.restartIfChanged = true;
    };
  };

  flake.modules.homeManager.dms = {
    imports = with inputs; [
      dms.homeModules.dank-material-shell
      dms.homeModules.niri
    ];

    programs.dank-material-shell = {
      enable = true;

      enableCalendarEvents = true;
      enableClipboardPaste = true;
      enableSystemMonitoring = true;

      clipboardSettings.clearAtStartup = true;
      clipboardSettings.maxHistory = 25;

      settings.theme = "dark";
      settings.dynamicTheming = true;

      session.isLightMode = false;
    };
  };
}
