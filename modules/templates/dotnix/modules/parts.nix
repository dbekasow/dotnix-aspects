{ inputs, ... }:
let
  modules = import inputs.dotnix;
in
{
  imports = with modules; [ home desktop managedSecrets yubikey devtools ];

  flake-file.outputs = "dendritic";

  flake-file.inputs = {
    dotnix = {
      url = "github:dbekasow/dotnix-aspects";
      flake = false;
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };
}
