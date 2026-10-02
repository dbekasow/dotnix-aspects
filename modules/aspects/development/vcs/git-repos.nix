{
  flake.modules.homeManager.git-repos = { config, lib, pkgs, ... }:
    let
      cloneRepo = pkgs.writeShellApplication {
        name = "clone-repo";
        runtimeInputs = [ pkgs.git ];
        text = ''
          dest="$HOME/$1"
          url="$2"

          [ -d "$dest/.git" ] && exit 0
          git ls-remote "$url" HEAD >/dev/null 2>&1 || {
            echo "skip: $url unreachable" >&2
            exit 0
          }
          git clone "$url" "$dest"
        '';
      };
    in
    {
      # Clones land in $HOME, which the impermanence setup wipes at boot —
      # they are read-mostly mirrors, not working copies.
      options.dotnix.git.repositories = lib.mkOption {
        type = with lib.types; attrsOf str;
        default = { };
        description = ''
          Repository mirrors to clone at activation: dest path relative
          to $HOME mapped to its clone URL. Local work is lost on reboot —
          keep working repositories in the persistent directory instead.
        '';
      };

      config.home.activation.cloneGitRepos = lib.hm.dag.entryAfter [ "writeBoundary" ] (
        lib.concatLines (lib.mapAttrsToList
          (dest: url: "$DRY_RUN_CMD ${lib.getExe cloneRepo} ${dest} ${url}")
          config.dotnix.git.repositories)
      );
    };
}
