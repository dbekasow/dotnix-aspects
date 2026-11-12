# Prompt, navigation and multiplexer ergonomics.
{ dotnix, ... }: {
  dotnix.home.term-ux.includes = with dotnix.home; [ atuin carapace direnv fzf skim starship yazi zoxide sesh tmux ];
}
