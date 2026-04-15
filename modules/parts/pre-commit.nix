{ inputs, ... }: {
  imports = [ inputs.git-hooks.flakeModule ];

  perSystem = { config, pkgs, ... }: {
    pre-commit.settings.package = pkgs.prek;
    pre-commit.settings.hooks = {
      treefmt.enable = true;
      treefmt.package = config.treefmt.build.wrapper;
      detect-private-keys.enable = true;
      typos.enable = true;
      commitizen.enable = true;
    };

    devshells.default = let inherit (config) pre-commit; in {
      packages = pre-commit.settings.enabledPackages ++ [ pkgs.prek ];
      devshell.startup.pre-commit.text = pre-commit.installationScript;
    };
  };
}
