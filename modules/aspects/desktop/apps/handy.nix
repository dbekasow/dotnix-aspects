{
  flake.modules.homeManager.handy = { lib, pkgs, ... }: {
    home.packages = with pkgs; [
      llm-agents.handy
      wtype
    ];

    # Handy needs to be running so the compositor keybind below can reach
    # the instance via Handy's single-instance plugin.
    systemd.user.services.handy = {
      Unit = {
        Description = "Handy speech-to-text";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${lib.getExe pkgs.handy} --start-hidden";
        # Handy shells out to wtype/wl-copy for pasting — pin the path here
        # instead of relying on the imported session PATH.
        Environment = [ "PATH=${lib.makeBinPath (with pkgs; [ wtype wl-clipboard-rs ])}" ];
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };

  # Wayland doesn't let apps grab global keys, so the binding belongs to niri.
  flake.modules.homeManager.niri = { config, ... }: {
    programs.niri.settings.binds = with config.lib.niri.actions; {
      "Mod+D".action = spawn "handy" "--toggle-transcription";
      "Mod+Shift+D".action = spawn "handy" "--cancel";
    };
  };

  # models/, settings_store.json, history.db
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".local/share/com.pais.handy" ];
  };
}
