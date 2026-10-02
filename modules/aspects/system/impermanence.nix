{ inputs, ... }: {
  flake.modules.nixos.impermanence = { lib, config, ... }: {
    imports = [ inputs.impermanence.nixosModules.impermanence ];

    boot.initrd.supportedFilesystems.btrfs = true;
    boot.initrd.systemd.services.rollback-root = {
      description = "Roll @root back to @root-blank";
      wantedBy = [ "initrd.target" ];
      before = [ "sysroot.mount" ];
      # Wait for LUKS only when the host actually uses the library's
      # cryptroot container; plain layouts (dotnix.disk.encrypt = false)
      # bind straight to the labelled btrfs. Hosts with their own
      # differently-named LUKS must override this unit's ordering.
      requires = lib.mkIf (config.boot.initrd.luks.devices ? cryptroot) [ "systemd-cryptsetup@cryptroot.service" ];
      after = lib.mkIf (config.boot.initrd.luks.devices ? cryptroot) [ "systemd-cryptsetup@cryptroot.service" ];
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
      files = [ "/etc/machine-id" ];
      directories = [
        # Post-mortem debugging across reboots; upstream example path.
        "/var/lib/systemd/coredump"
      ];
    };

    home-manager.sharedModules = [{
      home.persistence."/persist".hideMounts = true;
    }];
  };
}
