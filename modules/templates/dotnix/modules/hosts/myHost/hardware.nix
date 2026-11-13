# Hardware support for this host. Replace the imported machine module with the
# actual hardware profile; the aspect name is included by the host aspect.
{ inputs, ... }: {
  dotnix.dell-precision-5570.nixos = {
    imports = [ inputs.nixos-hardware.nixosModules.dell-precision-5570 ];
  };
}
