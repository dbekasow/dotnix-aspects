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

  flake.modules.homeManager.dms = { config, lib, ... }: {
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

    # Override the DMS-generated config.kdl: keep the includes, but make the
    # dms/*.kdl ones optional. niri-unstable (>= 26.04) treats a missing
    # optional include as a warning, not a hard parse error
    xdg.configFile.niri-config-dms.text =
      let
        cfg = config.programs.dank-material-shell.niri.includes;
        # niri-flake's own config, renamed by the DMS HACK (default: "hm")
        original = ''include "${cfg.originalFileName}.kdl"'';
        # dms runtime-generated fragments — now optional
        dmsIncludes = map
          (f: ''include optional=true "dms/${f}.kdl"'')
          cfg.filesToInclude;
        # preserve DMS ordering: override=true => dms overrides hm => hm first
        ordered =
          if cfg.override
          then [ original ] ++ dmsIncludes
          else dmsIncludes ++ [ original ];
        # border special case: `border {}` inside an include is a no-op,
        borderFix = lib.optional
          config.programs.niri.settings.layout.border.enable ''
          layout { border { on; }; }
        '';
      in
      lib.mkForce (builtins.concatStringsSep "\n" (ordered ++ borderFix));
  };

  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".config/niri/dms" ];
  };
}
