# Terminal profile with Herdr instead of Tmux and Sesh; reuse the shared
# terminal composition and subtract its Tmux-oriented multiplexer tools.
{ dotnix, ... }: {
  dotnix.home.terminal-herdr = {
    includes = with dotnix.home; [ terminal herdr ];
    excludes = with dotnix.home; [ tmux sesh ];
  };
}
