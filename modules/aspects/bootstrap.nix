{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos; in {
    nixos.bootstrap.imports = with nixos; [
      fish
      git
      locale
      network
      network-wifi
      nh
      nix
    ];
  };
}
