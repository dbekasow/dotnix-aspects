{ inputs, lib, ... }:
let
  # Use pinned import-tree defaults for entry-point discovery.
  discoverModules = root: lib.pipe inputs.import-tree [
    (i: i.addPath "${root}")
    (i: i.withLib lib)
    (i: i.files)
  ];

  featureModules = discoverModules ./features;
  profileModules = discoverModules ./profiles;

  consumerAdapter = (import ./integration/default.nix) inputs.self;

  # Keep imports within the flake source instead of copying the whole modules tree.
  devParts = map (name: ./parts + "/${name}") [
    "flake-parts.nix"
    "age.nix"
    "devshell.nix"
    "pre-commit.nix"
    "treefmt.nix"
  ];
in
{
  imports = featureModules ++ profileModules ++ devParts ++ [ ./parts/consumer-contract-checks.nix ];

  config = {
    flake-file.outputs = ''
      inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
        imports = [
          inputs.flake-file.flakeModules.default
          inputs.den.flakeModule
          (inputs.den.namespace "dotnix" true)
          ./modules/expose.nix
        ];
      }
    '';

    flake-file.inputs = {
      den.url = "github:denful/den/7594405b45e0ce2d5a418fe104a26e17f6b1dd8f";
      flake-file.url = "github:vic/flake-file";
      import-tree.url = "github:vic/import-tree";
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    flake.flakeModules.default = consumerAdapter;
    flake.flakeModules.devTools.imports = [ inputs.flake-file.flakeModules.default ]
      ++ map (f: f { inherit inputs lib; }) (map import devParts);
    flake.templates.default = {
      description = "Dendritic NixOS configuration using dotnix";
      path = ./templates/dotnix;
    };
  };
}
