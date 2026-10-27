{
  # The committer identity is consumer-owned: set `programs.git.settings.user`
  # in the consumer's own Home Manager module. This aspect only ships the
  # shared defaults.
  dotnix.git.homeManager = {
    programs.git = {
      enable = true;
      lfs.enable = true;

      ignores = [ ".direnv" ".devenv" ];

      settings = {
        branch.sort = "-committerdate";
        commit.verbose = true;
        core.editor = "hx";
        diff.algorithm = "histogram";
        diff.colorMoved = "default";
        fetch.prune = true;
        init.defaultBranch = "main";
        log.abbrevCommit = true;
        log.date = "iso";
        merge.conflictStyle = "zdiff3";
        pull.rebase = true;
        push.autoSetupRemote = true;
        push.followTags = true;
        rebase.autoSquash = true;
        rebase.autoStash = true;
        status.showUntrackedFiles = "all";
        status.submoduleSummary = true;
        submodule.recurse = true;
      };
    };
  };

  dotnix.host.git.nixos = {
    programs.git.enable = true;
    programs.git.lfs.enable = true;
  };
}
