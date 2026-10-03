_: {
  flake.modules.nixos.dms =
    { config
    , lib
    , options
    , ...
    }:
    {
      config = lib.mkIf (options ? programs && options.programs ? niri && config.programs.niri.enable) {
        # DMS provides its own Polkit agent when both shells are selected.
        systemd.user.services.niri-flake-polkit.enable = false;
      };
    };

  flake.modules.homeManager.dms = { config, ... }: {
    programs.niri.settings.binds =
      with config.lib.niri.actions;
      let
        dms-ipc = spawn "dms" "ipc";
      in
      {
        "Mod+Space".action = dms-ipc "call" "spotlight" "toggle";
        "Super+Alt+L".action = dms-ipc "call" "lock" "lock";

        # DMS UI
        "Mod+N".action = dms-ipc "call" "notifications" "toggle";
        "Mod+Comma".action = dms-ipc "call" "settings" "toggle";
        "Mod+X".action = dms-ipc "call" "powermenu" "toggle";
        "Mod+P".action = dms-ipc "call" "notepad" "toggle";
        "Mod+V".action = dms-ipc "call" "clipboard" "toggle";
        "Mod+M".action = dms-ipc "call" "processlist" "toggle";
        "Mod+Alt+N" = {
          allow-when-locked = true;
          action = dms-ipc "call" "night" "toggle";
        };

        # DMS's upstream binds allow these while locked for lockscreen control.
        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action = dms-ipc "call" "audio" "increment" "3";
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action = dms-ipc "call" "audio" "decrement" "3";
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action = dms-ipc "call" "audio" "mute";
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action = dms-ipc "call" "audio" "micmute";
        };

        "XF86MonBrightnessUp" = {
          allow-when-locked = true;
          action = dms-ipc "call" "brightness" "increment" "5" "";
        };
        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action = dms-ipc "call" "brightness" "decrement" "5" "";
        };
      };
  };
}
