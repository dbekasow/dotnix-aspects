{ inputs, ... }: {
  imports = [
    (inputs.dotnix + "/modules/base")
    (inputs.dotnix + "/modules/desktop")
    (inputs.dotnix + "/modules/devtools")
  ];

  flake-file.outputs = "dendritic";

  flake-file.inputs = {
    dotnix = {
      url = "github:dbekasow/dotnix-aspects";
      flake = false;
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };
}
