{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos homeManager; in {
    nixos.system.imports = with nixos; [
      bluetooth
      boot
      boot-systemd
      disko
      impermanence
      geolocation
      journald
      network
      network-wifi
      performance
      pipewire
      power
    ];

    homeManager.system.imports = with homeManager; [
      impermanence
    ];
  };
}
