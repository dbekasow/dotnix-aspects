{ inputs, ... }: {
  imports = [ inputs.treefmt.flakeModule ];

  perSystem = { config, ... }: {
    # The research archive is German prose — typos/prettier would churn it
    # forever and flag German words as misspellings.
    treefmt.settings.excludes = [ "docs/recherche-*/**" ];

    treefmt.programs = {
      nixpkgs-fmt.enable = true;
      deadnix.enable = true;
      statix.enable = true;
      just.enable = true;
      shfmt.enable = true;
      shellcheck.enable = true;
      typos.enable = true;
      prettier.enable = true;
    };

    formatter = config.treefmt.build.wrapper;

    devshells.default.packages = [ config.treefmt.build.wrapper ];
  };
}
