# term/monitoring group as its own HM tier; nix-search-tv moved to term-nix —
# it indexes nix references, not system health.
{ self, ... }: {
  flake.modules = let inherit (self.modules) homeManager; in {
    homeManager.term-monitoring.imports = with homeManager; [
      bandwhich
      bottom
      fastfetch
      hyperfine
      procs
      rustscan
      tealdeer
      television
      tokei
    ];
  };
}
