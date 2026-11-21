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
      home.gpg-agent-gui # explicit graphical pinentry integration for this user
      home.pipewire # WirePlumber state persistence for this user's home
    ];

    includes = with dotnix; [
      dell-precision-5570 # from ./hardware.nix
      host.core # locale, nix, security, certificates, ssh, home-manager, system-packages
      host.age # host-side decryption
      host.age-rekey # agenix-rekey wiring for the age.rekey resources below
      host.graphical # graphical foundation
      host.niri # Niri and its integrated-home defaults
      host.dms # shell for this host and its integrated homes; or select host.noctalia
      host.dms-greeter # greeter — swap for `host.noctalia-greeter`
      host.boot-baseline # shared boot behavior
      host.boot-systemd # systemd-boot loader
      host.bluetooth # laptop radio
      host.disko # starter Btrfs/LUKS layout; replace device below for this host
      host.persistence # selected persistence classes and /persist defaults
      host.network # NetworkManager and Avahi
      host.network-wifi # Wi-Fi configuration
      host.pipewire # audio
      host.pavucontrol # graphical audio mixer
      host.power # general power services; sleep and resume remain host-owned
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
