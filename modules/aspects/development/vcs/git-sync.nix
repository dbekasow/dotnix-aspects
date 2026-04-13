{ lib, ... }:
let
  repoModule = with lib.types; submodule ({ config, ... }: {
    options = {
      url = lib.mkOption { type = str; };
      interval = lib.mkOption { type = int; default = 3600; };
      alias = lib.mkOption { type = nullOr str; default = baseNameOf config.url; };
    };
  });
  encodeURI = builtins.replaceStrings [ " " ] [ "%%20" ];
  decodeURI = builtins.replaceStrings [ "%%20" ] [ " " ];
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
            (repo: {
              ${repo.alias} = {
                uri = encodeURI repo.url;
                path = "${config.home.homeDirectory}${dir}/${repo.alias}";
                inherit (repo) interval;
              };
            })
            repos)
        )
        config.dotnix.git.repositories;

      home.packages = [
        (pkgs.writeShellScriptBin "git-sync-bootstrap" (
          lib.concatStrings (lib.mapAttrsToList
            (name: repo: ''
              if [ ! -d "${repo.path}/.git" ]; then
                echo "Cloning ${name} into ${repo.path}..."
                mkdir -p "$(dirname "${repo.path}")"
                ${lib.getExe pkgs.git} clone "${decodeURI repo.uri}" "${repo.path}"
              fi
            '')
            config.services.git-sync.repositories)
        ))
      ];
    };
  };
}
