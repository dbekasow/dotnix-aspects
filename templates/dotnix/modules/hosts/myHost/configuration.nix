# Native Den entity: the host and its user are registered here, their behavior
# is composed from the dotnix namespace aspects below.
{ dotnix, ... }: {
  # Register this host and its members. `homeManager` selects the HM class for
  # the user; the host aspect below provides the user aspect to it.
  den.hosts.x86_64-linux.myHost.users.myuser.classes = [ "homeManager" ];

  den.aspects.myHost = {
    # must match the user aspect name in modules/users/<user>/default.nix
    provides.myuser.includes = [ dotnix.myuser ];

    includes = with dotnix; [
      dell-precision-5570 # from ./hardware.nix
      core # Home Manager NixOS integration is explicitly selected
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
    ];

    nixos = {
      disko.devices.disk.main.device = "/dev/nvme0n1"; # replace with this host's boot disk
      system.stateVersion = "26.11";
      # Throwaway master identity so a fresh clone evaluates and `agenix`
      # demos against a key nobody holds. Replace before going live.
      age.rekey.masterIdentities = [
        { identity = ./secrets/masterkey.age; pubkey = "age178wfu8598yp9vgcq3c5vwfmvtsqncypd0gkmal873yzl0y8zq5ls07q2cz"; }
      ];
    };
  };
}
