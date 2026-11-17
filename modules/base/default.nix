{ den, inputs, lib, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.default
    inputs.den.flakeModule
    (inputs.den.namespace "dotnix" true)
    (inputs.import-tree [ ./features ./profiles ])
  ];

  den.default.includes = [
    den.batteries.flake-scope
    den.batteries.hostname
  ];

  den.quirks.popup-launcher = {
    description = "Enabled popup launcher records shared by selected user-scope aspects";
  };

  # Consumers lock these inputs directly and can declare their own refs.
  flake-file.inputs = {
    den.url = lib.mkDefault "github:denful/den/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f";
    flake-file.url = lib.mkDefault "github:vic/flake-file";
    flake-parts = {
      url = lib.mkDefault "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = lib.mkDefault "github:vic/import-tree";
    nixpkgs.url = lib.mkDefault "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  systems = lib.mkDefault [ "x86_64-linux" ];
  # debug stays off: the introspection mirror taxes every outputs walk of
  # every consumer. The helix-lsp nixd options exprs expect a `debug = true`
  # flake — opt in locally when you want editor completion for flake-parts options.
}
