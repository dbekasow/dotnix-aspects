{
  flake.modules.homeManager.tmux = { config, lib, pkgs, ... }:
    let
      inherit (lib) getExe mkEnableOption mkOption types;

      # Case-insensitive; the appended original key breaks ties so B lands right
      # before b instead of in a separate ASCII block at the top.
      popups = lib.sortOn (p: lib.toLower p.key + p.key)
        (lib.filter (p: p.enable) config.dotnix.tmux.popups);

      keys = map (p: p.key) popups;

      # -EE closes the popup whatever the exit status. A single -E keeps it
      # open on failure, which means an aborted picker (Esc, exit 130) leaves
      # an empty box you have to dismiss a second time.
      popupCmd = p: lib.concatStringsSep " " (
        [ "display-popup -EE" "-w ${p.width}" "-h ${p.height}" ''-T " ${p.name} "'' ]
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
              description = "Command line to run inside the popup";
            };
            directory = mkOption {
              type = types.nullOr types.str;
              default = "#{pane_current_path}";
              description = "Start directory as a tmux format; null keeps tmux's default.";
            };
            width = mkOption {
              type = types.str;
              default = "90%";
              description = "Popup width as a tmux size (percentage or columns).";
            };
            height = mkOption {
              type = types.str;
              default = "85%";
              description = "Popup height as a tmux size (percentage or rows).";
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
          # Sizes follow the shape of the UI: dashboards and anything with a
          # diff or a preview pane need width, plain lists don't.
          { key = "B"; name = "bluetui"; command = getExe pkgs.bluetui; width = "60%"; height = "55%"; }
          { key = "b"; name = "bottom"; command = getExe pkgs.bottom; width = "95%"; height = "90%"; inherit (bottom) enable; }
          { key = "d"; name = "lazydocker"; command = getExe pkgs.lazydocker; width = "90%"; height = "85%"; inherit (lazydocker) enable; }
          { key = "f"; name = "shell"; command = getExe pkgs.fish; width = "80%"; height = "70%"; }
          { key = "g"; name = "lazygit"; command = getExe pkgs.lazygit; width = "95%"; height = "90%"; inherit (lazygit) enable; }
          { key = "k"; name = "k9s"; command = getExe pkgs.k9s; width = "95%"; height = "90%"; inherit (k9s) enable; }
          { key = "m"; name = "aerc"; command = getExe pkgs.aerc; width = "90%"; height = "85%"; inherit (aerc) enable; }
          { key = "n"; name = "nix-tree"; command = getExe pkgs.nix-tree; width = "90%"; height = "80%"; }
          { key = "p"; name = "gh-dash"; command = getExe pkgs.gh-dash; width = "90%"; height = "80%"; inherit (gh-dash) enable; }
          { key = "u"; name = "dua"; command = "${getExe pkgs.dua} i"; width = "75%"; height = "75%"; }
          { key = "w"; name = "wifitui"; command = getExe pkgs.wifitui; width = "60%"; height = "55%"; }
          { key = "y"; name = "yazi"; command = getExe pkgs.yazi; width = "95%"; height = "90%"; inherit (yazi) enable; }
          { key = "t"; name = "tv"; command = getExe pkgs.television; width = "70%"; height = "60%"; inherit (television) enable; }
          # Scratch session outlives the popup, so no start directory. TMUX is cleared because tmux refuses to nest a session otherwise.
          { key = "S"; name = "scratch"; command = "env TMUX= tmux new-session -A -s scratch"; directory = null; width = "90%"; height = "85%"; }
        ];

        programs.tmux.extraConfig = lib.optionalString (popups != [ ]) ''
          # ── Popup appearance ──────────────────────────────────────
          # Match the rounded window tabs; no popup-style, the TUIs paint
          # their own background and a second one shows through unevenly.
          set -g popup-border-lines rounded
          set -gF popup-border-style "fg=#{@them_surface_2}"

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
