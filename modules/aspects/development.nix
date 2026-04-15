{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos homeManager; in {
    nixos.development.imports = with nixos; [
      # Editor (master)
      helix
    ];

    homeManager.development.imports = with homeManager; [
      # Editor
      helix
      helix-keys
      helix-lsp

      # VCS
      delta
      difftastic
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
