{ inputs, lib, ... }:
let
  consumerAdapter = import ./integration/default.nix [ inputs.self true ];
in
{
  imports = [
    ./base.nix
    ./desktop.nix
    ./parts/consumer-contract-checks.nix
    ./devtools.nix
  ];

  config = {
    flake-file.outputs = ''
      inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
        imports = [ ./modules/expose.nix ];
      }
    '';

    flake.flakeModules.default = consumerAdapter;
    flake.flakeModules.devTools.imports = [
      inputs.flake-file.flakeModules.default
      ./parts/flake-parts.nix
      (import ./parts/devtools.nix { inherit inputs lib; })
    ];
    flake.templates.default = {
      description = "Dendritic NixOS configuration using dotnix";
      path = ./templates/dotnix;
    };
  };
}
