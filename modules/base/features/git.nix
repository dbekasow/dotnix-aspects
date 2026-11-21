{
  dotnix.home.git.homeManager = { config, lib, ... }:
    let
      primary = lib.findFirst (account: account.primary) null (lib.attrValues config.accounts.email.accounts);
    in
    {
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
          user = lib.mkIf (primary != null) {
            name = lib.mkDefault primary.realName;
            email = lib.mkDefault primary.address;
          };
        };
      };
    };

  dotnix.host.git.nixos = {
    programs.git.enable = true;
    programs.git.lfs.enable = true;
  };
}
