{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos homeManager; in {
    # Workstation bootloader and laptop tuning stay out of the headless base.
    nixos.system.imports = with nixos; [
      base
      boot-systemd
      performance
      bluetooth
      disko
      impermanence
      geolocation
      network
      network-wifi
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
