{
  flake.modules.homeManager.helix-keys = { pkgs, lib, ... }:
    let
      # ── hx-float: floating pane for tools that need buffer context ──
      # Only yazi and lazygit live here now; everything context-free moved to
      # the tmux popup table (prefix o). Outside tmux there is nothing to pop
      # up over, so fall back to running inline.
      hx-float = pkgs.writeShellScriptBin "hx-float" ''
        title="$1"
        shift
        if [ -n "''${TMUX:-}" ]; then
          tmux display-popup -E -w 80% -h 80% -T " $title " "$(printf '%q ' "$@")"
        else
          exec "$@"
        fi
      '';

      # Helix :sh shorthand for a named floating TUI
      popup' = name: pkg: arg: ":sh hx-float ${name} ${lib.getExe pkg} ${arg}";
      git = cmd: ":sh git ${cmd}";

    in
    {
      programs.helix.extraPackages = [ hx-float ];
      programs.helix.settings.keys.normal = {
        # ── Git inline queries ─────────────────────────────────
        "A-g" = {
          b = git "blame -L %{cursor_line},+1 %{buffer_name}";
          d = git "diff %{buffer_name}";
          l = git "log --oneline -10 %{buffer_name}";
          s = git "status --porcelain";
        };

        # ── Navigation ─────────────────────────────────────────
        "{" = "goto_prev_paragraph";
        "}" = "goto_next_paragraph";
        "X" = "extend_line_up";

        # ── Line move operations ───────────────────────────────
        "C-k" = [ "extend_to_line_bounds" "delete_selection" "move_line_up" "paste_before" ];
        "C-j" = [ "extend_to_line_bounds" "delete_selection" "paste_after" ];

        # ── Reload config + buffer ─────────────────────────────
        "C-r" = [ ":config-reload" ":reload" ];

        # ── Leader namespace (backspace) ───────────────────────
        backspace = {
          # Needs the open buffer's path — tmux only knows pane_current_path.
          e = popup' "yazi" pkgs.yazi "%{buffer_name}";
          # Chained :reload picks up commits made in the popup.
          g = [ (popup' "lazygit" pkgs.lazygit "") ":reload-all" ];

          # Helix config access
          l = ":o ~/.config/helix/languages.toml";
          c = ":config-open";

          # File picker toggles
          h = ":toggle-option file-picker.hidden";
          i = ":toggle-option file-picker.git-ignore";

          # Yank diagnostic
          y = ":yank-diagnostic";
        };
      };
    };
}
