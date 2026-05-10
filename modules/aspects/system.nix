{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos homeManager; in {
    nixos.system.imports = with nixos; [
      bluetooth
      boot
      boot-systemd
      disko
      impermanence
      geolocation
      network
      network-wifi
      pipewire
      power
    ];

    homeManager.system.imports = with homeManager; [
      impermanence
    ];
  };
}
