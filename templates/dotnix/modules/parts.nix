{ inputs, ... }: {
  imports = [
    inputs.dotnix.flakeModule
    inputs.dotnix.flakeModules.devTools # devshell, pre-commit, treefmt
  ];
}
