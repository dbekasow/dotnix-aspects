{ dotnix, ... }: {
  dotnix.development = {
    includes = with dotnix; [
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
