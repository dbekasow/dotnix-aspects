# Terminal profile with Herdr instead of the Tmux and Sesh multiplexers:
# it reuses home.terminal and excludes the multiplexer-coupled tools its
# subtree pulls in (workmux spawns agents in tmux panes).
{ dotnix, ... }: {
  dotnix.home.terminal-herdr = {
    includes = with dotnix.home; [ terminal herdr ];
    excludes = with dotnix.home; [ tmux sesh workmux ];
  };
}
