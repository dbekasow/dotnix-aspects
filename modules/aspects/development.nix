{ self, ... }: {
  flake.modules = let inherit (self.modules) homeManager; in {
    nixos.development.imports = [
      # Derzeit keine reinen NixOS-Module für Development
    ];

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
