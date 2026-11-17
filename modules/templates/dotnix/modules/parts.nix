{ inputs, ... }: {
  imports = [
    (inputs.dotnix + "/modules/base.nix")
    (inputs.dotnix + "/modules/desktop.nix")
    (inputs.dotnix + "/modules/devtools.nix")
  ];

  flake-file.outputs = ''
    inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
      (inputs.import-tree ./modules)
  '';

  flake-file.inputs = {
    dotnix = {
      url = "github:dbekasow/dotnix-aspects";
      flake = false;
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };
}
