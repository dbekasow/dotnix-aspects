{ inputs, lib, config, ... }:
let
  modules = ./.;

  aspects = lib.pipe inputs.import-tree [
    (i: i.addPath "${modules}/aspects")
    (i: i.withLib lib)
    (i: i.files)
  ];

  devParts = map (name: "${modules}/parts/${name}") [
    "flake-parts.nix"
    "age.nix"
    "devshell.nix"
    "pre-commit.nix"
    "treefmt.nix"
  ];
in
{
  imports = [
    inputs.flake-file.flakeModules.flake
    inputs.den.flakeModule
    inputs.den.flakeOutputs.flake
    (inputs.den.namespace "dotnix" true)
  ] ++ aspects;

  config = {
    flake-file.outputs = ''
      inputs: (inputs.nixpkgs.lib.evalModules {
        specialArgs = { inherit inputs; inherit (inputs) self; };
        modules = [ ./modules/expose.nix ];
      }).config.flake
    '';

    flake-file.inputs = {
      den.url = "github:denful/den/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f";
      devshell = {
        url = "github:numtide/devshell";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      flake-file.url = "github:vic/flake-file";
      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs";
      };
      git-hooks = {
        url = "github:cachix/git-hooks.nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      import-tree.url = "github:vic/import-tree";
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      treefmt = {
        url = "github:numtide/treefmt-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

    flake.flakeModules.devTools.imports = map import devParts;
    flake.templates.default = {
      description = "Dendritic NixOS configuration using dotnix";
      path = ../templates/dotnix;
    };
    flake.apps = lib.genAttrs inputs.nixpkgs.lib.systems.flakeExposed (system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };
      in
      {
        write-flake = {
          type = "app";
          program = lib.getExe (config.flake-file.apps.write-flake pkgs);
        };
      });
  };
}
