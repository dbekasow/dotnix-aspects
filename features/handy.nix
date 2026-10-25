{ inputs, ... }:
{
  dotnix.handy.homeManager =
    { config
    , lib
    , options
    , pkgs
    , ...
    }:
    let
      packages = pkgs.llm-agents or inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      config = lib.mkMerge [
        {
          home.packages = [
            packages.handy
            pkgs.wtype
          ];
        }
        (lib.optionalAttrs (options.programs ? niri) {
          # Wayland doesn't let apps grab global keys, so the binding belongs to niri.
          programs.niri.settings.binds = with config.lib.niri.actions; {
            "Mod+D".action = spawn "handy" "--toggle-transcription";
            "Mod+Shift+D".action = spawn "handy" "--cancel";
          };
        })
      ];
    };

  # Opt-in backend process; selecting the Handy desktop integration alone does not start it.
  dotnix.handy-service.homeManager =
    { lib, pkgs, ... }:
    let
      packages = pkgs.llm-agents or inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      systemd.user.services.handy = {
        Unit = {
          Description = "Handy speech-to-text";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          # Without a start limit, a crash loop restarts every RestartSec forever.
          StartLimitIntervalSec = 60;
          StartLimitBurst = 5;
        };
        Service = {
          # nixpkgs' handy drifts against llm-agents; the single-instance
          # socket requires one binary.
          ExecStart = "${lib.getExe packages.handy} --start-hidden";
          # Handy shells out to wtype/wl-copy for pasting — pin the path here
          # instead of relying on the imported session PATH.
          Environment = [
            "PATH=${
              lib.makeBinPath (
                with pkgs;
                [
                  wtype
                  wl-clipboard
                ]
              )
            }"
          ];
          Restart = "on-failure";
          RestartSec = 5;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };

  # Impermanence contribution for handy.
  # Handy keeps everything under its XDG config dir on Linux (upstream
  # README "App Data Directory"): models/, settings, transcript history.
  # The previous .local/share entry matched nothing — models re-downloaded
  # after every wipe.
  dotnix.handy.homePersistence = {
    home.persistence."/persist".directories = [ ".config/com.pais.handy" ];
  };
}
