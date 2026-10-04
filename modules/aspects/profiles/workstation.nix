# Workstation hardware and system stack: everything a laptop/desktop host
# needs below the user-facing composition — boot, laptop tuning, network,
# audio, power, smartcard, and the ephemeral root. The shell (dms | noctalia)
# and greeter stay per-host choices; hosts still supply the disko device,
# stateVersion and the rekey master identity themselves.
{ self, ... }: {
  flake.modules = let inherit (self.modules) nixos; in {
    nixos.workstation.imports = with nixos; [
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
      yubikey
      yubikey-pam
    ];
  };
}
