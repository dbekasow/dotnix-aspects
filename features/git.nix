{
  # The committer identity defaults to the consumer's primary
  # `accounts.email` account: name from its `realName`, email from its
  # address. Explicit `programs.git.settings.user` settings still win; relying
  # on the defaults without a primary account fails evaluation.
  dotnix.home.git.homeManager = { config, lib, ... }:
    let
      primaryAccount = lib.head (lib.attrValues (lib.filterAttrs (_: account: account.primary) config.accounts.email.accounts));
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
          user = {
            name = lib.mkDefault primaryAccount.realName;
            email = lib.mkDefault primaryAccount.address;
          };
        };
      };
    };

  dotnix.host.git.nixos = {
    programs.git.enable = true;
    programs.git.lfs.enable = true;
  };
}
