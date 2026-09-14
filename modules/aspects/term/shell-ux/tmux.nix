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
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '15'
          '';
        }
      ];

      extraConfig = ''
        # Truecolor + undercurl; ghostty and alacritty both advertise RGB.
        set -as terminal-features ',*:RGB,*:usstyle,*:clipboard'

        # Inherit the current pane's directory on split/new-window.
        bind c new-window -c "#{pane_current_path}"
        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        # Memorable aliases for the same splits.
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"

        # Ctrl+Alt, not plain Alt: A-j/A-k belong to Helix, A-h/A-l to fish.
        bind -n C-M-h select-pane -L
        bind -n C-M-j select-pane -D
        bind -n C-M-k select-pane -U
        bind -n C-M-l select-pane -R
        bind -n C-M-Left select-pane -L
        bind -n C-M-Down select-pane -D
        bind -n C-M-Up select-pane -U
        bind -n C-M-Right select-pane -R

        # Double-tap prefix jumps to the last-used window.
        bind C-Space last-window

        # -r: prefix stays active for repeat-time, so n-n-n instead of
        bind -r n next-window
        bind -r p previous-window
        bind -r '<' swap-pane -U
        bind -r '>' swap-pane -D

        # Don't fall back to the shell when a session is killed — switch to
        # the last one instead. Makes `bind L` (sesh last) actually useful.
        set -g detach-on-destroy off

        # vi-style selection in copy-mode
        bind -T copy-mode-vi v send -X begin-selection
        bind -T copy-mode-vi C-v send -X rectangle-toggle

        bind R source-file ${config.xdg.configHome}/tmux/tmux.conf \; display "tmux.conf reloaded"

        set -g renumber-windows on
        set -g set-clipboard on

        # ── Status line (catppuccin v2 modules) ───────────────────
        set -g status-position bottom
        set -g status-left-length 100
        set -g status-right-length 100
        set -g status-left ""
        set -g status-right "#{E:@catppuccin_status_session}"
        set -agF status-right "#{E:@catppuccin_status_date_time}"
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
