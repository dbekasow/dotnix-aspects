{ inputs, ... }: {
  flake.modules.nixos.dell-precision-5570 = {
    imports = [ inputs.nixos-hardware.nixosModules.dell-precision-5570 ];
  };
}
