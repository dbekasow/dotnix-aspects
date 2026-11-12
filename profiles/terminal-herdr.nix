# Terminal profile with Herdr instead of the Tmux and Sesh multiplexers:
# it reuses home.terminal and excludes the multiplexers its subtree pulls in.
{ dotnix, ... }: {
  dotnix.home.terminal-herdr = {
    includes = with dotnix.home; [ terminal herdr ];
    excludes = with dotnix.home; [ tmux sesh ];
  };
}
