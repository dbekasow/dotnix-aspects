# term/shell-ux group as its own HM tier: prompt, navigation and multiplexer
# ergonomics — the things that make a shell livable; `terminal` composes it.
{ self, ... }:
let
  inherit (self.modules) homeManager;
  shared = with homeManager; [
    atuin
    carapace
    direnv
    fzf
    skim
    starship
    yazi
    zoxide
  ];
in
{
  flake.modules = {
    homeManager.term-ux.imports = shared ++ (with homeManager; [
      sesh
      tmux
      zellij
    ]);
    homeManager.term-ux-herdr.imports = shared ++ (with homeManager; [ herdr ]);
  };
}
