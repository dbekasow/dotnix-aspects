{ inputs, lib, ... }:
{
  imports = [
    inputs.flake-file.flakeModules.default
    (import ./integration/default.nix true)
    (inputs.import-tree ./features)
    (inputs.import-tree ./profiles)
    ./parts/flake-parts.nix
  ];

  # Consumers lock these inputs directly and can declare their own refs.
  flake-file.inputs = {
    den.url = lib.mkDefault "github:denful/den/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f";
    flake-file.url = lib.mkDefault "github:vic/flake-file";
    import-tree.url = lib.mkDefault "github:vic/import-tree";
    nixpkgs.url = lib.mkDefault "github:NixOS/nixpkgs/nixpkgs-unstable";
  };
}
