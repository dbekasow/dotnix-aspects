{ lib, ... }:
let
  repoModule = with lib.types; submodule {
    options = {
      projects = lib.mkOption { type = listOf str; };
      path = lib.mkOption { type = str; };
      interval = lib.mkOption { type = int; default = 3600; };
    };
  };
in
{
  flake.modules.homeManager.git-sync = { config, lib, pkgs, ... }: {
    options.dotnix.repositories = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf repoModule);
      default = { };
    };

    config = lib.mkIf (config.dotnix.repositories != { }) {
      services.git-sync.enable = true;
      services.git-sync.repositories = lib.concatMapAttrs
        (base: orgs:
          lib.concatMapAttrs
            (org: repo:
              lib.listToAttrs (map
                (project: lib.nameValuePair project {
                  uri = "${base}/${org}/${project}";
                  path = "${config.home.homeDirectory}/${repo.path}/${project}";
                  inherit (repo) interval;
                })
                repo.projects)
            )
            orgs
        )
        config.dotnix.repositories;

      home.activation.cloneRepositories = lib.hm.dag.entryAfter [ "agenix" ] (
        lib.concatStrings (lib.mapAttrsToList
          (name: repo:
            let clone = "${lib.getExe pkgs.git} clone ${repo.uri} ${repo.path}";
            in ''
              if [ ! -d "${repo.path}/.git" ]; then
                echo "Cloning ${name} into ${repo.path}..."
                mkdir -p "$(dirname "${repo.path}")"
                ${clone} && echo "Done." || echo "Failed to clone ${name}."
              fi
            ''
          )
          config.services.git-sync.repositories)
      );
    };
  };
}
