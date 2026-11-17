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

    flake.templates.default = {
      description = "Dendritic NixOS configuration using dotnix";
      path = ./templates/dotnix;
    };
  };
}
