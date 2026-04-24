{
  flake.modules.homeManager.niri = {
    programs.niri.settings.binds = {
      # ── Hotkey overlay ─────────────────────────────────────────
      "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

      # ── Spawn ──────────────────────────────────────────────────
      "Mod+T".action.spawn = "ghostty";
      "Mod+B".action.spawn = "firefox";
      "Mod+E".action.spawn = "thunderbird";
      "Mod+Space".action.spawn = [ "dms" "ipc" "call" "spotlight" "toggle" ];
      "Super+Alt+L".action.spawn = [ "dms" "ipc" "call" "lock" "lock" ];

      # ── DMS UI ─────────────────────────────────────────────────
      "Mod+N".action.spawn = [ "dms" "ipc" "call" "notifications" "toggle" ];
      "Mod+Comma".action.spawn = [ "dms" "ipc" "call" "settings" "toggle" ];
      "Mod+X".action.spawn = [ "dms" "ipc" "call" "powermenu" "toggle" ];
      "Mod+P".action.spawn = [ "dms" "ipc" "call" "notepad" "toggle" ];
      "Mod+V".action.spawn = [ "dms" "ipc" "call" "clipboard" "toggle" ];
      "Mod+M".action.spawn = [ "dms" "ipc" "call" "processlist" "toggle" ];
      "Mod+Alt+N".action.spawn = [ "dms" "ipc" "call" "night" "toggle" ];

      # ── Audio (DMS — replaces wpctl) ───────────────────────────
      "XF86AudioRaiseVolume".action.spawn = [ "dms" "ipc" "call" "audio" "increment" "3" ];
      "XF86AudioLowerVolume".action.spawn = [ "dms" "ipc" "call" "audio" "decrement" "3" ];
      "XF86AudioMute".action.spawn = [ "dms" "ipc" "call" "audio" "mute" ];
      "XF86AudioMicMute".action.spawn = [ "dms" "ipc" "call" "audio" "micmute" ];

      # ── Brightness (DMS — replaces brightnessctl) ──────────────
      "XF86MonBrightnessUp".action.spawn = [ "dms" "ipc" "call" "brightness" "increment" "5" "" ];
      "XF86MonBrightnessDown".action.spawn = [ "dms" "ipc" "call" "brightness" "decrement" "5" "" ];

      # ── Window management ──────────────────────────────────────
      "Mod+Q".action.close-window = [ ];
      "Mod+W".action.toggle-window-floating = [ ];
      "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];

      # ── Focus movement (arrows + hjkl) ─────────────────────────
      "Mod+Left".action.focus-column-left = [ ];
      "Mod+Down".action.focus-window-down = [ ];
      "Mod+Up".action.focus-window-up = [ ];
      "Mod+Right".action.focus-column-right = [ ];
      "Mod+H".action.focus-column-left = [ ];
      "Mod+J".action.focus-window-down = [ ];
      "Mod+K".action.focus-window-up = [ ];
      "Mod+L".action.focus-column-right = [ ];

      # ── Column/window movement ─────────────────────────────────
      "Mod+Ctrl+Left".action.move-column-left = [ ];
      "Mod+Ctrl+Down".action.move-window-down = [ ];
      "Mod+Ctrl+Up".action.move-window-up = [ ];
      "Mod+Ctrl+Right".action.move-column-right = [ ];
      "Mod+Ctrl+H".action.move-column-left = [ ];
      "Mod+Ctrl+J".action.move-window-down = [ ];
      "Mod+Ctrl+K".action.move-window-up = [ ];
      "Mod+Ctrl+L".action.move-column-right = [ ];

      # ── First / last column ────────────────────────────────────
      "Mod+Home".action.focus-column-first = [ ];
      "Mod+End".action.focus-column-last = [ ];
      "Mod+Ctrl+Home".action.move-column-to-first = [ ];
      "Mod+Ctrl+End".action.move-column-to-last = [ ];

      # ── Monitor focus / move ───────────────────────────────────
      "Mod+Shift+Left".action.focus-monitor-left = [ ];
      "Mod+Shift+Down".action.focus-monitor-down = [ ];
      "Mod+Shift+Up".action.focus-monitor-up = [ ];
      "Mod+Shift+Right".action.focus-monitor-right = [ ];
      "Mod+Shift+H".action.focus-monitor-left = [ ];
      "Mod+Shift+J".action.focus-monitor-down = [ ];
      "Mod+Shift+K".action.focus-monitor-up = [ ];
      "Mod+Shift+L".action.focus-monitor-right = [ ];
      "Mod+Ctrl+Shift+Left".action.move-column-to-monitor-left = [ ];
      "Mod+Ctrl+Shift+Down".action.move-column-to-monitor-down = [ ];
      "Mod+Ctrl+Shift+Up".action.move-column-to-monitor-up = [ ];
      "Mod+Ctrl+Shift+Right".action.move-column-to-monitor-right = [ ];
      "Mod+Ctrl+Shift+H".action.move-column-to-monitor-left = [ ];
      "Mod+Ctrl+Shift+J".action.move-column-to-monitor-down = [ ];
      "Mod+Ctrl+Shift+K".action.move-column-to-monitor-up = [ ];
      "Mod+Ctrl+Shift+L".action.move-column-to-monitor-right = [ ];

      # ── Workspace switching ────────────────────────────────────
      "Mod+U".action.focus-workspace-down = [ ];
      "Mod+I".action.focus-workspace-up = [ ];
      "Mod+Next".action.focus-workspace-down = [ ];
      "Mod+Prior".action.focus-workspace-up = [ ];
      "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];
      "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];
      "Mod+Ctrl+Next".action.move-column-to-workspace-down = [ ];
      "Mod+Ctrl+Prior".action.move-column-to-workspace-up = [ ];
      "Mod+Shift+U".action.move-workspace-down = [ ];
      "Mod+Shift+I".action.move-workspace-up = [ ];

      # ── Workspace 1–9 ──────────────────────────────────────────
      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;
      "Mod+Ctrl+1".action.move-column-to-workspace = 1;
      "Mod+Ctrl+2".action.move-column-to-workspace = 2;
      "Mod+Ctrl+3".action.move-column-to-workspace = 3;
      "Mod+Ctrl+4".action.move-column-to-workspace = 4;
      "Mod+Ctrl+5".action.move-column-to-workspace = 5;
      "Mod+Ctrl+6".action.move-column-to-workspace = 6;
      "Mod+Ctrl+7".action.move-column-to-workspace = 7;
      "Mod+Ctrl+8".action.move-column-to-workspace = 8;
      "Mod+Ctrl+9".action.move-column-to-workspace = 9;

      # ── Consume / expel window ─────────────────────────────────

      "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
      "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

      # ── Column / window sizing ─────────────────────────────────
      "Mod+R".action.switch-preset-column-width = [ ];
      "Mod+Shift+R".action.switch-preset-window-height = [ ];
      "Mod+Ctrl+R".action.reset-window-height = [ ];
      "Mod+F".action.maximize-column = [ ];
      "Mod+Shift+F".action.fullscreen-window = [ ];
      "Mod+C".action.center-column = [ ];
      "Mod+Minus".action.set-column-width = "-10%";
      "Mod+Equal".action.set-column-width = "+10%";
      "Mod+Shift+Minus".action.set-window-height = "-10%";
      "Mod+Shift+Equal".action.set-window-height = "+10%";

      # ── Screenshot ─────────────────────────────────────────────
      "Print".action.screenshot = [ ];
      "Alt+Print".action.screenshot-window = { };
      "Ctrl+Print".action.screenshot-screen = { };

      # ── Mouse wheel workspace switching ────────────────────────
      "Mod+WheelScrollDown" = { cooldown-ms = 150; action.focus-workspace-down = [ ]; };
      "Mod+WheelScrollUp" = { cooldown-ms = 150; action.focus-workspace-up = [ ]; };
      "Mod+WheelScrollRight".action.focus-column-right = [ ];
      "Mod+WheelScrollLeft".action.focus-column-left = [ ];

      # ── Session ────────────────────────────────────────────────
      "Mod+Shift+E".action.quit = { };
      "Ctrl+Alt+Delete".action.quit = { };
    };
  };
}
