{ inputs, ... }: {
  imports = [
    inputs.den.flakeModule
    (inputs.den.namespace "dotnix" [ inputs.dotnix true ])
    inputs.dotnix.flakeModules.devTools # devshell, pre-commit, treefmt, agenix-rekey
  ];
}
