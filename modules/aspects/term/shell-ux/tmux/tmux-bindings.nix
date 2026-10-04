{
  dotnix.tmux.homeManager = { config, lib, ... }: {
    programs.tmux.extraConfig = ''
      bind -N "New window" c new-window -c "#{pane_current_path}"
      bind -N "Split right" | split-window -h -c "#{pane_current_path}"
      bind -N "Split down" - split-window -v -c "#{pane_current_path}"
      bind -N "Last window" C-Space last-window
      bind -N "Send prefix" C-b send-prefix
      bind -r -N "Next window" n next-window
      bind -r -N "Previous window" p previous-window
      bind -r -N "Move window left" M-< swap-window -d -t -1
      bind -r -N "Move window right" M-> swap-window -d -t +1
      bind -N "Reload config" R source-file ${config.xdg.configHome}/tmux/tmux.conf \; display "tmux.conf reloaded"
      bind -T copy-mode-vi -N "Begin selection" v send -X begin-selection
      bind -T copy-mode-vi -N "Block selection" C-v send -X begin-selection \; send -X rectangle-toggle
      bind -T copy-mode-vi -N "Cancel" Escape send -X cancel
      ${lib.concatMapStringsSep "\n" (n: "bind -n -N \"Window ${n}\" M-${n} select-window -t ${n}") (map toString (lib.range 1 9))}
    '';
  };
}
