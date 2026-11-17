{
  imports = [
    ../base
    ../desktop
    ../devtools
    ../templates
    ./consumer-checks.nix
  ];

  flake-file.outputs = ''
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ./modules/standalone ];
    }
  '';
}
