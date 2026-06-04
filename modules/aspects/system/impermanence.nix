{ inputs, ... }: {
  flake.modules.nixos.impermanence = {
    imports = [ inputs.impermanence.nixosModules.impermanence ];

    boot.initrd.supportedFilesystems.btrfs = true;
    boot.initrd.systemd.services.rollback-root = {
      description = "Roll @root back to @root-blank";
      wantedBy = [ "initrd.target" ];
      before = [ "sysroot.mount" ];
      requires = [ "systemd-cryptsetup@cryptroot.service" ];
      after = [ "systemd-cryptsetup@cryptroot.service" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /mnt
        mount -o subvol=/ /dev/disk/by-label/nixos /mnt

        btrfs subvolume list -o /mnt/@root | cut -f9- -d' ' | while read sv; do
          btrfs subvolume delete "/mnt/$sv"
        done
        btrfs subvolume delete /mnt/@root
        btrfs subvolume snapshot /mnt/@root-blank /mnt/@root

        umount /mnt
      '';
    };

    environment.persistence."/persist" = {
      hideMounts = true;

      directories = [
        # Core system state
        "/var/lib/nixos"
        "/var/lib/systemd"

        # Network
        "/var/lib/bluetooth"
        "/var/lib/NetworkManager"
        "/etc/NetworkManager/system-connections"

        # Virtualisation
        "/var/lib/docker"

        # Nix
        "/etc/nixos"
      ];

      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
    };

    home-manager.sharedModules = [{
      home.persistence."/persist".hideMounts = true;
    }];
  };
}
