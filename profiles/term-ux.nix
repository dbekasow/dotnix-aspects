# Prompt, navigation and multiplexer ergonomics.
{ dotnix, ... }: {
  dotnix.home.term-ux.includes = with dotnix.home; [ atuin carapace clipboard direnv fzf skim starship yazi zoxide sesh tmux ];
}
