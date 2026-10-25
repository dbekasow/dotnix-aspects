library:
{ den, inputs, ... }:
let
  namespace = inputs.den.namespace "dotnix" [ library true ];
in
{
  imports = [
    inputs.den.flakeModule
    namespace
  ];

  den.default.includes = [
    den.batteries.flake-scope
    den.batteries.hostname
  ];

  den.quirks.popup-launcher = {
    description = "Enabled popup launcher records shared by selected user-scope aspects";
  };
}
