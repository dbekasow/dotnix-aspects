# Consumer integration comes from the library's default adapter; development
# tooling remains an explicit optional import.
{ inputs, ... }: {
  imports = [
    inputs.dotnix.flakeModules.default
    inputs.dotnix.flakeModules.devTools # devshell, pre-commit, treefmt, agenix-rekey
  ];
}
