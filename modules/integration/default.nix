namespaceSources:
{ den, inputs, ... }:
{
  imports = [
    inputs.den.flakeModule
    (inputs.den.namespace "dotnix" namespaceSources)
  ];

  den.default.includes = [
    den.batteries.flake-scope
    den.batteries.hostname
  ];

  den.quirks.popup-launcher = {
    description = "Enabled popup launcher records shared by selected user-scope aspects";
  };
}
