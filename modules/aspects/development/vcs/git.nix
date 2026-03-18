{
  flake.modules.homeManager.development = { config, ... }: {
    programs.git = {
      enable = true;
      lfs.enable = true;

      ignores = [ ".direnv" ".devenv" ];

      settings = let inherit (config.dotnix) user; in {
        user.name = user.fullname;
        user.email = user.email;

        branch.sort = "-committerdate";
        commit.verbose = true;
        core.editor = "hx";
        diff.algorithm = "histogram";
        diff.colorMoved = "default";
        fetch.pruneTags = false;
        fetch.prune = true;
        init.defaultBranch = "main";
        log.abbrevCommit = true;
        log.date = "iso";
        merge.conflictStyle = "zdiff3";
        pull.rebase = true;
        push.autoSetupRemote = true;
        push.default = "simple";
        push.followTags = true;
        rebase.autoSquash = true;
        rebase.autoStash = true;
        status.showUntrackedFiles = "all";
        status.submoduleSummary = true;
        submodule.recurse = true;
      };
    };
  };
}
