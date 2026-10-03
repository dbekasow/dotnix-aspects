# term/shell group as its own HM tier: shells stay separable from their UX
# tooling; `terminal` composes the term-* bundles.
{ self, ... }: {
  flake.modules = let inherit (self.modules) homeManager; in {
    homeManager.term-shell.imports = with homeManager; [
      fish
      nushell
    ];
  };
}
