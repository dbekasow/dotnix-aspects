# Composition of the term-* sub-bundles (one per term/ directory). AI
# workflow moved to the development tier; mail lives in its own tier
# (mail.nix) so hosts that do not mail do not pull it.
{ self, ... }: {
  flake.modules = let inherit (self.modules) homeManager; in {
    homeManager.terminal.imports = with homeManager; [
      term-shell
      term-ux
      term-cli
      term-monitoring
      term-nix
      term-secrets
    ];
  };
}
