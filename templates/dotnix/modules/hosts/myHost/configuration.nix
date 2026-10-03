{
  # Register the host under the dotnix.hosts registry.
  dotnix.hosts.myHost = { nixos, ... }: {
    modules = with nixos; [
      dell-precision-5570 # from ./hardware.nix
      core # home-manager wiring (nixos.home-manager) — the factory does NOT inject it
      desktop-shell # graphical socket; shell and greeter are per-host choices
      dms # shell — swap for `noctalia` to run the alternative
      dms-greeter # greeter — swap for `noctalia-greeter`
      base # shared boot behavior
      boot-systemd # systemd-boot loader
      performance # workstation tuning
      bluetooth # laptop radio
      disko # starter Btrfs/LUKS layout; replace device below for this host
      impermanence # persistent state on the Btrfs layout
      geolocation # location service
      network # NetworkManager and Avahi
      network-wifi # Wi-Fi configuration
      pipewire # audio
      power # workstation power management and resume defaults
      yubikey # hardware-backed login tools
      yubikey-pam # PAM integration for YubiKey
      development
      { disko.devices.disk.main.device = "/dev/nvme0n1"; } # replace with this host's boot disk
      { system.stateVersion = "26.11"; }
      {
        # Throwaway master identity so a fresh clone evaluates and `agenix`
        # demos against a key nobody holds. Replace before going live.
        age.rekey.masterIdentities = [
          { identity = ./secrets/masterkey.age; pubkey = "age178wfu8598yp9vgcq3c5vwfmvtsqncypd0gkmal873yzl0y8zq5ls07q2cz"; }
        ];
      }
    ];
    # must match the user aspect name in modules/users/<user>/default.nix
    members = [ "myuser" ];
  };
}
