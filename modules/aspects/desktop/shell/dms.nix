{ inputs, ... }: {
  flake.modules.nixos.dms = { pkgs, ... }: {
    imports = [ inputs.dms.nixosModules.dank-material-shell ];

    programs.dank-material-shell = {
      enable = true;

      systemd.enable = true;
      systemd.restartIfChanged = true;
    };

    programs.dsearch.enable = true;

    environment.systemPackages = with pkgs; [
      cups-pk-helper # printer management
      fprintd # fingerprint authentication
    ];
  };

  flake.modules.homeManager.dms = {
    imports = with inputs; [
      dms.homeModules.dank-material-shell
      dms.homeModules.niri
    ];

    programs.dank-material-shell = {
      enable = true;

      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;
      enableDynamicTheming = true;
      enableSystemMonitoring = true;

      clipboardSettings.clearAtStartup = true;
      clipboardSettings.maxHistory = 25;

      session.isLightMode = false;
    };
  };
}
