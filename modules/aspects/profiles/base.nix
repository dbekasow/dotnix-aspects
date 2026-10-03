# Shared boot and journald behavior without choosing a bootloader or root disk.
{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos; in {
    nixos.base.imports = with nixos; [
      boot
      journald
    ];
  };
}
