{
  flake.modules.homeManager.delta = {
    programs.delta = {
      enable = true;
      enableGitIntegration = true;

      options = {
        dark = true;
        line-numbers = true;
        merge-conflict-style = "zdiff3";
        navigate = true;
        side-by-side = false;
        word-diff-regex = "\\w+|[^\\w\\s]+";
      };
    };

    programs.lazygit.settings.git.pagers = [{
      colorArg = "always";
      pager = "delta --color-only --dark --paging=never";
    }];
  };
}
