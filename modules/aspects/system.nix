{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos; in {
    nixos.system.imports = with nixos; [
      bluetooth
      boot
      boot-limine
      disko
      geolocation
      network
      network-wifi
      pipewire
      power
    ];
  };
}
