# Impermanence contribution for tmux — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
# tmux-resurrect state lives in $XDG_DATA_HOME/tmux/resurrect —
# @continuum-restore is a no-op without this.
{
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".local/share/tmux" ];
  };
}
