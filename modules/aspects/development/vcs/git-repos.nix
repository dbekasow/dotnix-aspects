{
  flake.modules.homeManager.git-repos = { config, lib, pkgs, ... }: {
    options.dotnix.git.repositories = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = { };
    };

    config.home.activation.cloneGitRepos = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      lib.concatStrings (lib.mapAttrsToList
        (dest: url: ''
          if [ ! -d "$HOME/${dest}/.git" ]; then
            $DRY_RUN_CMD ${lib.getExe pkgs.git} clone "${url}" "$HOME/${dest}"
          fi
        '')
        config.dotnix.git.repositories)
    );
  };
}
