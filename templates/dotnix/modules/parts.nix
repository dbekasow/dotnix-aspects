# Native Den entry: the Den flake module plus the dotnix namespace export.
# `den.default.includes` activates the batteries every aspect relies on:
# flake-scope exposes the consumer flake's inputs to class modules, hostname
# names hosts from their Den entity.
{ inputs, den, ... }: {
  imports = [
    inputs.den.flakeModule
    (inputs.den.namespace "dotnix" [ inputs.dotnix true ])
    inputs.dotnix.flakeModules.devTools # devshell, pre-commit, treefmt, agenix-rekey
  ];

  den.quirks.popup-launcher = {
    description = "Enabled popup launcher records shared by selected user-scope aspects";
  };

  den.default.includes = [
    den.batteries.flake-scope
    den.batteries.hostname
  ];
}
