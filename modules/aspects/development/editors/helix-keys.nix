# helix-keys.nix
{
  flake.modules.homeManager.development = { pkgs, lib, ... }:
    let
      # -- Extracted shell scripts as proper derivations --

      yazi-picker = pkgs.writeShellScriptBin "hx-yazi-picker" ''
        # $1 = helix command (open/vsplit/hsplit), $2 = buffer path
        paths=$(yazi "$2" --chooser-file=/dev/stdout | while read -r; do printf "%q " "$REPLY"; done)
        if [[ -n "$paths" ]]; then
          zellij action toggle-floating-panes
          zellij action write 27                    # ESC to normal mode
          zellij action write-chars ":$1 $paths"
          zellij action write 13                    # Enter to confirm
        else
          zellij action toggle-floating-panes
        fi
      '';

      reveal-in-yazi = pkgs.writeShellScriptBin "hx-reveal-in-yazi" ''
        # $1 = buffer path — reveal in adjacent Yazi sidebar
        zellij action move-focus left
        ya emit-to 0 reveal --str "$1"
      '';

      # -- Zellij floating-pane launcher --
      # Returns a helix `:sh` command that opens a named floating TUI
      popup = name: pkg:
        ":sh zellij run -fc -x 10% -y 10% --width=80% --height=80% --name ${name} -- ${lib.getExe pkg}";

    in
    {
      programs.helix.extraPackages = [ yazi-picker reveal-in-yazi ];
      programs.helix.settings.keys.normal = {

        # -- Workspace integration (Yazelix patterns) --
        "A-r" = '':sh hx-reveal-in-yazi "%{buffer_name}"'';
        "A-t" = popup "Lazygit" pkgs.lazygit;

        # -- Git inline queries --
        "A-g" = {
          b = '':sh git blame -L %{cursor_line},+1 %{buffer_name}'';
          s = ":sh git status --porcelain";
          l = '':sh git log --oneline -10 %{buffer_name}'';
        };

        # -- Navigation --
        "{" = "goto_prev_paragraph";
        "}" = "goto_next_paragraph";
        "X" = "extend_line_up";

        # -- Line operations --
        "C-k" = [ "extend_to_line_bounds" "delete_selection" "move_line_up" "paste_before" ];
        "C-j" = [ "extend_to_line_bounds" "delete_selection" "paste_after" ];

        # -- System --
        "C-r" = [ ":config-reload" ":reload" ];

        # -- Leader namespace (backspace) --
        backspace = {
          # TUI popups (shell-based)
          e = '':sh hx-yazi-picker open "%{buffer_name}"'';
          g = popup "Lazygit" pkgs.lazygit;

          # Helix-native
          d = ":yank-diagnostic";
          h = ":toggle-option file-picker.hidden";
          i = ":toggle-option file-picker.git-ignore";
          l = ":o ~/.config/helix/languages.toml";
          c = ":config-open";
        };
      };
    };
}
