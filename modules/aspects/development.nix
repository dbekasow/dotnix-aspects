{ self, ... }: {
  flake.modules = let inherit (self.modules) homeManager; in {
    homeManager.development.imports = with homeManager; [
      # Editor
      helix
      helix-keys
      helix-lsp

      # VCS
      delta
      gh
      lazygit

      # Automation & AI
      bacon
      just
      repomix
      watchexec
    ];
  };
}
