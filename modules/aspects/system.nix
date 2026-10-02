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
      # Workstation hardware pulled from the core tier: pcscd and
      # pam_u2f need physical presence; headless hosts skip this tier.
      yubikey
      yubikey-pam
    ];

    homeManager.system.imports = with homeManager; [
      impermanence
    ];
  };
}
