{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos homeManager; in {
    nixos.development.imports = with nixos; [
      # Devops
      docker

      # Dynamic binaries
      nix-ld

      # AI workflow
      llm-agents
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

      # AI workflow
      ai-tools
      workmux
      tuicr

      # Automation
      bacon
      just
      repomix
      watchexec

      # Devops
      docker
      kubernetes
    ];
  };
}
