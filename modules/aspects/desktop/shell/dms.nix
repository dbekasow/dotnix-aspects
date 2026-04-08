{ inputs, ... }: {
  flake.modules.nixos.dms = {
    imports = [ inputs.dms.nixosModules.dank-material-shell ];

    programs.dank-material-shell = {
      enable = true;

      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableClipboardPaste = true;
      enableDynamicTheming = true;
      enableSystemMonitoring = true;
      enableVPN = true;
    };

    systemd.user.services.niri-flake-polkit.enable = false;
  };

  flake.modules.homeManager.dms = {
    imports = [
      inputs.dms.homeModules.dank-material-shell
      inputs.dms.homeModules.niri
    ];

    programs.dank-material-shell = {
      enable = true;

      niri = {
        enableSpawn = true;
      };

      settings = {
        theme = "dark";
        dynamicTheming = true;
      };

      session = {
        isLightMode = false;
      };

      clipboardSettings = {
        clearAtStartup = true;
        maxHistory = 25;
      };
    };
  };
}
