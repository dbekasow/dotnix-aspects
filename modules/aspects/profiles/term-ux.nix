# term/shell-ux group as its own HM tier: prompt, navigation and multiplexer
# ergonomics — the things that make a shell livable; `terminal` composes it.
{ self, ... }: {
  flake.modules = let inherit (self.modules) homeManager; in {
    homeManager.term-ux.imports = with homeManager; [
      atuin
      carapace
      direnv
      fzf
      sesh
      skim
      starship
      tmux
      yazi
      zellij
      zoxide
    ];
  };
}
