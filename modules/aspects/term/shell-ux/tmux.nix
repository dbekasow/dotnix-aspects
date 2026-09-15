{
  flake.modules.homeManager.tmux = { config, lib, pkgs, ... }: {
    # catppuccin/tmux and stylix both drive the status line. Two writers means
    # whichever runs last wins — let the plugin own it, the palette is the same.
    stylix.targets.tmux.enable = false;

    programs.tmux = {
      enable = true;

      # fish is users.defaultUserShell — pin it instead of inheriting whatever
      # $SHELL the greeter happened to export.
      shell = lib.getExe pkgs.fish;

      # Load tmux-sensible first so everything below can still override it.
      sensibleOnTop = true;

      aggressiveResize = true;
      baseIndex = 1;
      clock24 = true;
      customPaneNavigationAndResize = true; # hjkl / HJKL, like helix
      disableConfirmationPrompt = true;
      escapeTime = 0; # otherwise Esc lags in helix inside a pane
      focusEvents = true; # helix auto-save.focus-lost needs these
      historyLimit = 20000; # same as zellij's scroll_buffer_size
      keyMode = "vi";
      mouse = true;
      prefix = "C-Space";
      terminal = "tmux-256color";

      # Order matters: home-manager emits each plugin's extraConfig directly
      # above its own run-shell line, so these blocks are "before load".
      plugins = with pkgs.tmuxPlugins; [
        {
          plugin = catppuccin;
          extraConfig = ''
            set -g @catppuccin_flavor 'mocha'
            set -g @catppuccin_window_status_style 'rounded'
            set -g @catppuccin_window_text ' #{?automatic-rename,#{b:pane_current_path},#W}'
            set -g @catppuccin_window_current_text ' #{?automatic-rename,#{b:pane_current_path},#W}'
          '';
        }
        {
          plugin = tmux-thumbs;
          extraConfig = ''
            set -g @thumbs-key F
            set -g @thumbs-command 'printf %s {} | wl-copy'
            set -g @thumbs-upcase-command 'printf %s {} | wl-copy && tmux paste-buffer'
            set -g @thumbs-unique enabled
            set -g @thumbs-reverse enabled

            set -g @thumbs-regexp-1 '[~.]?/[\w.\-/]+'  # paths
            set -g @thumbs-regexp-2 '[\w.\-]+\.\w+'    # filenames with an extension
            set -g @thumbs-regexp-3 '\w+(?:\.\w+){2,}' # nix attribute paths
            set -g @thumbs-regexp-4 '\S{12,}'          # anything long without spaces
          '';
        }
        {
          plugin = better-mouse-mode;
          extraConfig = ''
            set -g @scroll-without-changing-pane 'on'
            set -g @emulate-scroll-for-no-mouse-alternate-buffer 'on'
          '';
        }
        {
          plugin = yank;
          extraConfig = ''
            set -g @override_copy_command 'wl-copy'
            set -g @yank_action 'copy-pipe'
          '';
        }
        {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-capture-pane-contents 'on'
            set -g @resurrect-processes 'hx lazygit k9s btm yazi'
          '';
        }
        {
          plugin = continuum;
          extraConfig =
            let
              modes = [
                { flag = "client_prefix"; color = "red"; }
                { flag = "pane_in_mode"; color = "yellow"; }
                { flag = "window_zoomed_flag"; color = "blue"; }
              ];
              modeIndicator = lib.foldr
                (m: fallback: "#{?${m.flag},#[fg=#{@thm_${m.color}}]●,${fallback}}")
                "#[fg=#{@thm_surface_1}]●"
                modes;
            in
            ''
              set -g @continuum-restore 'on'
              set -g @continuum-save-interval '15'

              # ── Status line (catppuccin v2 modules) ───────────────────
              set -g status-position bottom
              set -g status-left-length 100
              set -g status-right-length 100
              set -g status-left ""

              # Plain -g here: -F would expand client_prefix once at load time and
              # freeze the dot. The modules below need -F for the palette.
              set -g status-right "${modeIndicator}#[default] "
              set -agF status-right "#{E:@catppuccin_status_application}"
              set -agF status-right "#{E:@catppuccin_status_session}"
              set -agF status-right "#{E:@catppuccin_status_date_time}"
            '';
        }
      ];

      extraConfig = ''
        # ── Terminal ──────────────────────────────────────────────
        # Truecolor + undercurl; ghostty and alacritty both advertise RGB.
        set -as terminal-features ',*:RGB,*:usstyle,*:clipboard'

        # Let the Kitty graphics protocol through, otherwise yazi's image
        # previews stay blank inside a pane or popup.
        set -g allow-passthrough on
        set -ga update-environment TERM
        set -ga update-environment TERM_PROGRAM

        set -g renumber-windows on
        set -g set-clipboard on

        # Repeatable bindings chain within this window; 500ms is too tight.
        set -g repeat-time 1000

        # Don't fall back to the shell when a session is killed — switch to
        # the last one instead. Makes `bind S` (sesh last) actually useful.
        set -g detach-on-destroy off

        # ── Prompts and messages ──────────────────────────────────
        # tmux draws these from column 0 over the status modules without
        # clearing first, so give them a background that stays readable.
        set -gF message-style "fg=#{@thm_crust},bg=#{@thm_yellow}"
        set -gF message-command-style "fg=#{@thm_crust},bg=#{@thm_peach}"
      '';
    };

    programs.fish.shellAbbrs.tm = "tmux new-session -A -s main";

    # Fallback for when tmux is imported without sesh — otherwise sesh.nix owns the autostart.
    programs.fish.interactiveShellInit = lib.mkIf (!config.programs.sesh.enable) ''
      if not set -q TMUX
        if tmux has-session -t main 2>/dev/null
          set -l sid (tmux new-session -dt main -P -F '#{session_id}')
          tmux set-option -t $sid destroy-unattached on
          tmux attach-session -t $sid
        else
          tmux new-session -s main
        end
      end
    '';
  };

  # tmux-resurrect state lives in $XDG_DATA_HOME/tmux/resurrect —
  # @continuum-restore is a no-op without this.
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".local/share/tmux" ];
  };
}
