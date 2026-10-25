# Native Den entity: the host and its user are registered here, their behavior
# is composed from the dotnix namespace aspects below.
{ dotnix, ... }: {
  # Register this host and its account. `user` enables account-class settings;
  # `homeManager` opts into integrated Home Manager independently.
  den.hosts.x86_64-linux.myHost.users.myuser.classes = [ "user" "homeManager" ];

  den.aspects.myHost = {
    # must match the user aspect name in modules/users/<user>/default.nix
    provides.myuser.includes = with dotnix; [
      myuser
      desktop-shell # Home Manager shell integration for this user
      dms # Home Manager DMS launcher and settings; use noctalia here too to select it instead
      home.pipewire # WirePlumber state persistence for this user's home
    ];

    includes = with dotnix; [
      dell-precision-5570 # from ./hardware.nix
      core # Home Manager NixOS integration is explicitly selected
      desktop-shell # host graphical socket
      dms # host shell — use noctalia instead for that host
      dms-greeter # greeter — swap for `noctalia-greeter`
      base # shared boot behavior
      boot-systemd # systemd-boot loader
      performance # workstation tuning
      bluetooth # laptop radio
      disko # starter Btrfs/LUKS layout; replace device below for this host
      host.persistence # selected persistence classes and /persist defaults
      host.btrfs-root-reset # reset @root from @root-blank on this Btrfs layout
      geolocation # location service
      network # NetworkManager and Avahi
      network-wifi # Wi-Fi configuration
      host.pipewire # audio
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
