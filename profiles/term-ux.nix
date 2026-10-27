# Prompt, navigation and multiplexer ergonomics.
{ dotnix, ... }:
let
  shared = with dotnix; [ atuin carapace direnv fzf skim starship yazi zoxide ];
in
{
  dotnix.home.term-ux.includes = shared ++ (with dotnix; [ sesh tmux ]);
  dotnix.home.term-ux-herdr.includes = shared ++ [ dotnix.herdr ];
}
