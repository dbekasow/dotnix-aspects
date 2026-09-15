{
  flake.modules.homeManager.tmux = { config, lib, ... }:
    let
      inherit (lib) mkEnableOption mkOption types;

      # Sorted so the generated block doesn't reorder itself when an
      # unrelated feature module is added or removed. Case-insensitive with
      # the original key as tiebreak, so A sits next to a.
      bindings = lib.sortOn (b: lib.toLower b.key + b.key)
        (lib.filter (b: b.enable) config.dotnix.tmux.bindings);

      # Every binding lives in exactly one key table: an explicit one via -T,
      # otherwise prefix or root. M-1 in root and M-1 after the prefix can
      # coexist, so keys only collide within the same table.
      tableOf = b:
        if b.table != null then b.table
        else if b.prefix then "prefix"
        else "root";

      byTable = lib.groupBy tableOf bindings;

      bindLine = b: lib.concatStringsSep " " (
        [ "bind" ]
        ++ lib.optionals (b.table != null) [ "-T" b.table ]
        ++ lib.optional (b.table == null && !b.prefix) "-n"
        ++ lib.optional b.repeat "-r"
        ++ [ ''-N "${b.name}"'' b.key b.command ]
      );
    in
    {
      options.dotnix.tmux.bindings = mkOption {
        default = [ ];
        description = ''
          Key bindings contributed by feature modules, collected here so two
          modules can't silently claim the same key. Bindings written straight
          into programs.tmux.extraConfig stay invisible to this check.
        '';
        type = types.listOf (types.submodule {
          options = {
            enable = mkEnableOption "binding" // { default = true; };
            key = mkOption {
              type = types.str;
              description = "Key, as tmux names it: a letter, or C-x / M-x.";
            };
            name = mkOption {
              type = types.str;
              description = "Description shown by prefix ? and list-keys -N.";
            };
            command = mkOption {
              type = types.str;
              description = "Tmux command line to run";
            };
            prefix = mkOption {
              type = types.bool;
              default = true;
              description = "Bind in the prefix table; false binds with -n.";
            };
            table = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = " Key table to bind in (-T).";
            };
            repeat = mkOption {
              type = types.bool;
              default = false;
              description = "Keep the prefix active for repeat-time (-r).";
            };
          };
        });
      };

      config = {
        # The loser of a collision just never fires, and nothing in the
        # generated config hints at why.
        assertions = lib.mapAttrsToList
          (table: bs:
            let keys = map (b: b.key) bs; in
            {
              assertion = keys == lib.unique keys;
              message = "dotnix.tmux.bindings: duplicate keys in table ${table}: ${lib.concatStringsSep " " keys}";
            })
          byTable;

        dotnix.tmux.bindings =
          let
            windowBindings = map
              (n: { prefix = false; key = "M-${n}"; name = "Window ${n}"; command = "select-window -t ${n}"; })
              (map toString (lib.range 1 9));
          in
          [
            # Always inherit the current pane's directory.
            { key = "c"; name = "New window"; command = ''new-window -c "#{pane_current_path}"''; }
            { key = "|"; name = "Split right"; command = ''split-window -h -c "#{pane_current_path}"''; }
            { key = "-"; name = "Split down"; command = ''split-window -v -c "#{pane_current_path}"''; }

            # Double-tap the prefix jumps to the last-used window. That
            # replaces home-manager's `bind C-Space send-prefix`, so the
            # pass-through moves to the freed-up former prefix key.
            { key = "C-Space"; name = "Last window"; command = "last-window"; }

            # repeat: the prefix stays active, so n-n-n instead of prefix-n-prefix-n.
            { key = "n"; name = "Next window"; command = "next-window"; repeat = true; }
            { key = "p"; name = "Previous window"; command = "previous-window"; repeat = true; }
            { key = "'<'"; name = "Move window left"; command = "swap-window -d -t -1"; repeat = true; }
            { key = "'>'"; name = "Move window right"; command = "swap-window -d -t +1"; repeat = true; }

            { key = "R"; name = "Reload config"; command = ''source-file ${config.xdg.configHome}/tmux/tmux.conf \; display "tmux.conf reloaded"''; }

            # v starts a selection, C-v a block selection, y copies (yank plugin), Escape backs out. Needs keyMode = "vi".
            { table = "copy-mode-vi"; key = "v"; name = "Begin selection"; command = "send -X begin-selection"; }
            { table = "copy-mode-vi"; key = "C-v"; name = "Block selection"; command = ''send -X begin-selection \; send -X rectangle-toggle''; }
            { table = "copy-mode-vi"; key = "Escape"; name = "Cancel"; command = "send -X cancel"; }
          ] ++ windowBindings;

        programs.tmux.extraConfig = lib.optionalString (bindings != [ ]) ''
          # ── Bindings from feature modules ─────────────────────────
          ${lib.concatMapStringsSep "\n" bindLine bindings}
        '';
      };
    };
}
