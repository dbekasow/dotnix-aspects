{ inputs, ... }: {
  imports = [ inputs.treefmt.flakeModule ];

  perSystem = { config, ... }: {
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
