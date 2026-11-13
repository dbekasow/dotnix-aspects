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
      home.graphical # graphical foundation for this user's home
      home.niri # per-user Niri configuration and bindings
      home.dms # Home Manager DMS launcher and settings; use home.noctalia here too to select it instead
      home.gpg-agent-gui # explicit graphical pinentry integration for this user
      home.pipewire # WirePlumber state persistence for this user's home
    ];

    includes = with dotnix; [
      dell-precision-5570 # from ./hardware.nix
      host.core # universal host baseline: locale, nix, security, certificates, ssh, age, home-manager, system-packages
      host.age-rekey # agenix-rekey wiring for the age.rekey resources below
      host.graphical # graphical foundation
      host.niri # NixOS Niri support, separate from per-user configuration
      host.dms # host shell — use host.noctalia instead for that host
      host.dms-greeter # greeter — swap for `host.noctalia-greeter`
      host.boot-baseline # shared boot behavior
      host.boot-systemd # systemd-boot loader
      host.performance # workstation tuning
      host.bluetooth # laptop radio
      host.disko # starter Btrfs/LUKS layout; replace device below for this host
      host.persistence # selected persistence classes and /persist defaults
      host.btrfs-root-reset # reset @root from @root-blank on this Btrfs layout
      host.geolocation # location service
      host.network # NetworkManager and Avahi
      host.network-wifi # Wi-Fi configuration
      host.pipewire # audio
      host.power # workstation power management and resume defaults
      host.yubikey # hardware-backed login tools
      # Select host.yubikey-pam separately after providing its native authfile.
    ];

    nixos = {
      programs.dms-greeter.configHome = builtins.toString ./greeter/home; # DMS-only; remove when switching to Noctalia
      disko.devices.disk.main.device = "/dev/nvme0n1"; # replace with this host's boot disk
      system.stateVersion = "26.11";
      age.rekey = {
        # Resource paths come from the conventional layout
        # (modules/hosts/<host>/secrets); override the native options to
        # deviate. Throwaway master pubkey so a fresh clone evaluates and
        # demos against a key nobody holds; replace before going live.
        extraEncryptionPubkeys = [ "age178wfu8598yp9vgcq3c5vwfmvtsqncypd0gkmal873yzl0y8zq5ls07q2cz" ];
      };
      # Extra CAs: drop *.crt files into ./certificates (collected via
      # host.certificates, included by host.core). Set
      # security.pki.certificateFiles to deviate.
      # security.pam.u2f.settings.authfile = ./secrets/u2f-mappings;
    };
  };
}
