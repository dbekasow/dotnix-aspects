{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos homeManager; in {
    # base carries the shared boot socket — boot, journald and performance
    # need no individual lines here anymore.
    nixos.system.imports = with nixos; [
      base
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
