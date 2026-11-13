{ dotnix, ... }: {
  dotnix.home.development = {
    includes = with dotnix.home; [
      llm-agents
      helix
      helix-keys
      helix-lsp
      delta
      difftastic
      gh
      lazygit
      git
      git-alias
      ai-tools
      tuicr
      bacon
      just
      repomix
      watchexec
    ];
  };
}
