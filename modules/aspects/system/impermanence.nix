{ inputs, ... }: {
  flake.modules.nixos.impermanence = { lib, config, ... }: {
    imports = [ inputs.impermanence.nixosModules.impermanence ];

    boot.initrd.supportedFilesystems.btrfs = true;
    boot.initrd.systemd.services.rollback-root =
      let
        dependencies =
          lib.optionals (config.boot.initrd.luks.devices ? cryptroot) [ "systemd-cryptsetup@cryptroot.service" ]
          ++ lib.optionals (config.boot.resumeDevice != null && config.boot.resumeDevice != "") [ "systemd-hibernate-resume.service" ];
      in
      {
        description = "Roll @root back to @root-blank";
        wantedBy = [ "initrd.target" ];
        before = [ "sysroot.mount" ];
        # Wait for configured LUKS/resume services, but keep cold boots without
        # Hibernate independent of the resume unit.
        requires = dependencies;
        after = dependencies;
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
