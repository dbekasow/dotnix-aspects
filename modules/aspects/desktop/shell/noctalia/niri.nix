{ lib, ... }:
{
  flake.modules.homeManager.noctalia =
    { config, options, ... }:
    {
      config = lib.optionalAttrs (options.programs ? niri && options.programs.niri ? settings) {
        programs.niri.settings =
          with config.lib.niri.actions;
          {
            binds = {
              "Mod+Space".action = spawn "noctalia" "msg" "panel-toggle" "launcher";
              "Mod+S".action = spawn "noctalia" "msg" "panel-toggle" "control-center";
              "Mod+Comma".action = spawn "noctalia" "msg" "settings-toggle";
              "Alt+Tab" = {
                repeat = false;
                action = spawn "noctalia" "msg" "window-switcher" "hold";
              };
              "XF86AudioRaiseVolume".action = spawn "noctalia" "msg" "volume-up";
              "XF86AudioLowerVolume".action = spawn "noctalia" "msg" "volume-down";
              "XF86AudioMute".action = spawn "noctalia" "msg" "volume-mute";
              "XF86MonBrightnessUp".action = spawn "noctalia" "msg" "brightness-up";
              "XF86MonBrightnessDown".action = spawn "noctalia" "msg" "brightness-down";
            };
            window-rules = [
              {
                matches = [{ app-id = "dev.noctalia.Noctalia"; }];
                open-floating = true;
              }
            ];
          };
      };
    };
}
