# Native Den entity: the host and its user are registered here, their behavior
# is composed from the dotnix namespace aspects below.
{ dotnix, lib, ... }: {
  # Register this host and its account. `user` enables account-class settings;
  # `homeManager` opts into integrated Home Manager independently.
  den.hosts.x86_64-linux.myHost.users.myuser.classes = [ "user" "homeManager" ];

  den.aspects.myHost = {
    # must match the user aspect name in modules/users/<user>/default.nix
    provides.myuser.includes = with dotnix; [
      myuser
      home.desktop-shell # graphical foundation for this user's home
      home.niri # per-user Niri configuration and bindings
      dms # Home Manager DMS launcher and settings; use noctalia here too to select it instead
      home.gpg-agent-gui # explicit graphical pinentry integration for this user
      home.pipewire # WirePlumber state persistence for this user's home
    ];

    includes = with dotnix; [
      dell-precision-5570 # from ./hardware.nix
      host.core # Home Manager NixOS integration is explicitly selected
      host.desktop-shell # graphical foundation
      host.niri # NixOS Niri support, separate from per-user configuration
      dms # host shell — use noctalia instead for that host
      host.dms-greeter # greeter — swap for `host.noctalia-greeter`
      host.base # shared boot behavior
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
        # These are consumer-owned native options. Pick paths that fit this repo.
        secretsDir = ./secrets;
        generatedSecretsDir = ./secrets/generated;
        localStorageDir = ./secrets/local;
        hostPubkey = lib.optionalString
          (builtins.pathExists ./secrets/ssh_host_ed25519_key.pub)
          (builtins.readFile ./secrets/ssh_host_ed25519_key.pub);
        storageMode = "local";
        # Add consumer-owned master identities before running agenix-rekey.
        masterIdentities = [ ];
      };
      # Provide real resources through these native options when needed:
      # security.pki.certificateFiles = [ ./certificates/internal-ca.crt ];
      # security.pam.u2f.settings.authfile = ./secrets/u2f-mappings;
    };
  };
}
