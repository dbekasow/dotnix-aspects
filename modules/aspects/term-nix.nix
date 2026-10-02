# term/nix group as its own HM tier; nix-search-tv moved here from
# monitoring — a nix tool belongs with the nix group, not with system health.
{ self, ... }: {
  flake.modules = let inherit (self.modules) homeManager; in {
    homeManager.term-nix.imports = with homeManager; [
      nix-index-database
      nix-tools
      nix-search-tv
    ];
  };
}
