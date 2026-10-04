{ dotnix, ... }: {
  dotnix.development = {
    includes = with dotnix; [
      docker
      nix-ld
      llm-agents
      helix
      helix-keys
      helix-lsp
      delta
      gh
      lazygit
      ai-tools
      workmux
      tuicr
      bacon
      just
      repomix
      watchexec
      kubernetes
    ];
  };
}
