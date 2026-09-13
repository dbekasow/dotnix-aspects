{
  flake.modules.homeManager.tmux = { config, lib, pkgs, ... }:
    let
      inherit (lib) getExe mkEnableOption mkOption types;

      size = "-w 90% -h 90%";

      # Sorted, so the menu order doesn't depend on the order in which the
      # contributing features happen to be merged.
      popups = lib.sort (a: b: a.key < b.key)
        (lib.filter (p: p.enable) config.dotnix.tmux.popups);

      keys = map (p: p.key) popups;

      popupCmd = p: lib.concatStringsSep " " (
        [ "display-popup -E" size ''-T " ${p.name} "'' ]
        ++ lib.optional (p.directory != null) ''-d "${p.directory}"''
        ++ [ ''"${p.command}"'' ]
      );

      # Regular quotes: '''  inside an indented string is an escape sequence.
      menuItem = p: "  \"${p.name}\" ${p.key} '${popupCmd p}'";
    in
    {
      options.dotnix.tmux.popups = mkOption {
        default = [ ];
        description = "TUI popups reachable via prefix + o.";
        type = types.listOf (types.submodule {
          options = {
            enable = mkEnableOption "tmux popups" // { default = true; };
            key = mkOption {
              type = types.str;
              description = "Key that selects this popup in the menu.";
            };
            name = mkOption {
              type = types.str;
              description = "Label in the menu and in the popup's title bar.";
            };
            command = mkOption {
              type = types.str;
              description = "Command line to run inside the popup.";
            };
            directory = mkOption {
              type = types.nullOr types.str;
              default = "#{pane_current_path}";
              description = "Start directory as a tmux format; null keeps tmux's default.";
            };
          };
        });
      };

      config = {
        # Two features quietly grabbing the same key would be invisible in the
        # generated menu — the later one just never fires.
        assertions = [{
          assertion = keys == lib.unique keys;
          message = "dotnix.tmux.popups: duplicate keys in: ${lib.concatStringsSep " " keys}";
        }];

        dotnix.tmux.popups = with config.programs; [
          { key = "B"; name = "bluetui"; command = getExe pkgs.bluetui; }
          { key = "b"; name = "bottom"; command = getExe pkgs.bottom; inherit (bottom) enable; }
          { key = "d"; name = "lazydocker"; command = getExe pkgs.lazydocker; inherit (lazydocker) enable; }
          { key = "f"; name = "shell"; command = getExe pkgs.fish; }
          { key = "g"; name = "lazygit"; command = getExe pkgs.lazygit; inherit (lazygit) enable; }
          { key = "k"; name = "k9s"; command = getExe pkgs.k9s; inherit (k9s) enable; }
          { key = "m"; name = "aerc"; command = getExe pkgs.aerc; inherit (aerc) enable; }
          { key = "n"; name = "nix-tree"; command = getExe pkgs.nix-tree; }
          { key = "p"; name = "gh-dash"; command = getExe pkgs.gh-dash; inherit (gh-dash) enable; }
          { key = "u"; name = "dua"; command = "${getExe pkgs.dua} i"; }
          { key = "w"; name = "wifitui"; command = getExe pkgs.wifitui; }
          { key = "y"; name = "yazi"; command = getExe pkgs.yazi; inherit (yazi) enable; }

          # Scratch session outlives the popup, so no start directory.
          { key = "S"; name = "scratch"; command = "tmux new-session -A -s scratch"; directory = null; }

          # television writes the pick into the tmux buffer (-w also puts it
          # on the system clipboard) — paste it into the pane with prefix ].
          {
            key = "t";
            name = "tv";
            command = "${getExe pkgs.television} | tmux load-buffer -w -";
            inherit (television) enable;
          }
        ];

        programs.tmux.extraConfig = lib.optionalString (popups != [ ]) ''
          # ── TUI popups: prefix o, then a letter ───────────────────
          # display-menu is tmux's built-in which-key: the item key stays
          # muscle memory, but the list is visible while you decide. Single
          # quotes keep #{...} from being expanded at parse time —
          # display-popup expands it itself.
          bind -N "TUI popups" o display-menu -T " popups " -x C -y C \
          ${lib.concatStringsSep " \\\n" (map menuItem popups)}
        '';
      };
    };
}
