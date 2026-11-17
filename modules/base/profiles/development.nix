{ dotnix, ... }: {
  dotnix.home.development = {
    includes = with dotnix.home; [
      helix
      helix-keys
      helix-lsp
      delta
      difftastic
      gh
      lazygit
      git
      git-alias
      hunk
      bacon
      just
      watchexec
    ];
  };
}
