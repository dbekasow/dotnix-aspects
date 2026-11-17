{ inputs, lib, ... }:
let
  consumerAdapter = import ./integration/default.nix [ inputs.self true ];

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
  imports = [
    ./base.nix
    (inputs.import-tree ./desktop)
    ./parts/consumer-contract-checks.nix
  ] ++ devParts;

  config = {
    flake-file.outputs = ''
      inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
        imports = [ ./modules/expose.nix ];
      }
    '';

    # Standalone has these tooling inputs; Base Consumers need not.
    flake-file.inputs.agenix-rekey.inputs = {
      devshell.follows = "devshell";
      pre-commit-hooks.follows = "git-hooks";
      treefmt-nix.follows = "treefmt";
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
