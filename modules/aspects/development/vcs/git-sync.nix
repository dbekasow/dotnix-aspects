{ lib, ... }:
let
  repoModule = with lib.types; submodule ({ config, ... }: {
    options = {
      url = lib.mkOption { type = str; };
      interval = lib.mkOption { type = int; default = 3600; };
      alias = lib.mkOption { type = nullOr str; default = baseNameOf config.url; };
      sync = lib.mkOption { type = bool; default = false; };
    };
  });
  encode = builtins.replaceStrings [ " " ] [ "%%20" ];
  normalize = builtins.replaceStrings [ "%%" ] [ "%" ];
in
{
  flake.modules.homeManager.git-sync = { config, lib, pkgs, ... }: {
    options.dotnix.git.repositories = lib.mkOption {
      type = with lib.types; attrsOf (listOf repoModule);
      default = { };
    };

    config = lib.mkIf (config.dotnix.git.repositories != { }) {
      services.git-sync.enable = true;
      services.git-sync.repositories = lib.concatMapAttrs
        (dir: repos:
          lib.mergeAttrsList (map
            (repo: lib.optionalAttrs repo.sync {
              ${repo.alias} = {
                uri = encode repo.url;
                path = "${config.home.homeDirectory}${dir}/${repo.alias}";
                extraPackages = [ pkgs.git-lfs ];
                inherit (repo) interval;
              };
            })
            repos)
        )
        config.dotnix.git.repositories;

      home.packages =

        let
          mkCloneSnippet = dir: repo:
            let
              repoPath = "${config.home.homeDirectory}${dir}/${repo.alias}";
              repoUrl = normalize (encode repo.url);
            in
            ''
              if [ ! -d "${repoPath}/.git" ]; then
                echo "Cloning ${repo.alias} into ${repoPath}..."
                mkdir -p "$(dirname "${repoPath}")"
                ${lib.getExe pkgs.git} clone "${repoUrl}" "${repoPath}"
              fi
            '';

          allSnippets = lib.concatStrings (lib.concatLists
            (lib.mapAttrsToList
              (dir: repos: map (mkCloneSnippet dir) repos)
              config.dotnix.git.repositories));
        in
        [ (pkgs.writeShellScriptBin "git-sync-bootstrap" allSnippets) ];
    };
  };
}
