{
  flake.modules.homeManager.helix-keys = { pkgs, lib, ... }:
    let
      # ── hx-float: shared floating-pane launcher ─────────────
      hx-float = pkgs.writeShellScriptBin "hx-float" ''
        zellij run -fc -x 10% -y 10% --width=80% --height=80% --name "$1" -- "''${@:2}" >/dev/null 2>&1
      '';

      # Helix :sh shorthand for a named floating TUI
      popup = name: pkg: ":sh hx-float ${name} ${lib.getExe pkg}";
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
          # Yazi file picker → selected file opens in helix buffer
          e = popup "yazi" pkgs.yazi;

          # TUI popups
          g = popup "lazygit" pkgs.lazygit;
          b = popup "bottom" pkgs.bottom;
          d = popup "lazydocker" pkgs.lazydocker;
          k = popup "k9s" pkgs.k9s;

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
