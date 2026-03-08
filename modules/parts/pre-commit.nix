{ inputs, ... }: {
  imports = [ inputs.git-hooks.flakeModule ];

  perSystem = { config, ... }: {
    pre-commit.settings = {
      excludes = [ "flake.lock" ];
      hooks = {
        treefmt.enable = true;
        treefmt.package = config.treefmt.build.wrapper;
        detect-private-keys.enable = true;
        typos.enable = true;
        commitizen.enable = true;
      };
    };
  };
}
