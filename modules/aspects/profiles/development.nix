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

      # VCS — delta is the canonical pager renderer across the review
      # stack (the tuicr config mirrors its side-by-side look); difftastic
      # is not imported here: it stays available as a single import for
      # hosts that want a structural difftool.
      delta
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
