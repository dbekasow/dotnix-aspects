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
      jj
      hunk
      bacon
      just
      watchexec
    ];
  };
}
