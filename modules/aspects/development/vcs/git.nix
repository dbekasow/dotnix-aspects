{
  flake.modules.homeManager.git = { config, lib, ... }:
    let
      # profile.* is data held by the users-profile aspect; the existence
      # checks keep standalone imports (flat homeManagerModules.git output,
      # no users-profile) evaluating — reading an undeclared option fails
      # with "attribute missing".
      fullname = if config ? profile && config.profile ? fullname then config.profile.fullname else null;
      email = if config ? profile && config.profile ? email then config.profile.email else null;
    in
    {
      programs.git = {
        enable = true;
        lfs.enable = true;

        ignores = [ ".direnv" ".devenv" ];

        # Identity keys only when the profile supplied them — a null value
        # would render invalid gitconfig.
        settings = {
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
        } // lib.optionalAttrs (fullname != null) {
          user.name = fullname;
        } // lib.optionalAttrs (email != null) {
          user.email = email;
        };
      };
    };

  flake.modules.nixos.git = {
    programs.git.enable = true;
    programs.git.lfs.enable = true;
  };
}
