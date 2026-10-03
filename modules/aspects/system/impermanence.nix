{ inputs, ... }: {
  flake.modules.nixos.impermanence = { lib, config, utils, ... }: {
    imports = [ inputs.impermanence.nixosModules.impermanence ];

    boot.initrd.supportedFilesystems.btrfs = true;
    boot.initrd.systemd.services.rollback-root =
      let
        device = "/dev/disk/by-label/nixos";
        deviceUnit = "${utils.escapeSystemdPath device}.device";
        dependencies =
          [ deviceUnit ]
          ++ lib.optionals (config.boot.initrd.luks.devices ? cryptroot) [ "systemd-cryptsetup@cryptroot.service" ]
          ++ lib.optionals (config.boot.resumeDevice != null && config.boot.resumeDevice != "") [ "systemd-hibernate-resume.service" ];
      in
      {
        description = "Roll @root back to @root-blank";
        wantedBy = [ "initrd.target" ];
        requiredBy = [ "sysroot.mount" ];
        before = [ "sysroot.mount" ];
        # Wait for the actual root device and configured LUKS/resume services.
        requires = dependencies;
        after = dependencies;
        unitConfig.DefaultDependencies = "no";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          set -eu
          mountpoint=$(mktemp -d /run/rollback-root.XXXXXX)
          cleanup() {
            status=$?
            trap - EXIT
            if mountpoint -q "$mountpoint"; then
              umount "$mountpoint" || status=1
            fi
            rmdir "$mountpoint" || status=1
            exit "$status"
          }
          trap cleanup EXIT

          mount -t btrfs -o subvolid=5 "${device}" "$mountpoint"
          btrfs subvolume show "$mountpoint/@root" >/dev/null
          btrfs subvolume show "$mountpoint/@root-blank" >/dev/null
          btrfs subvolume delete --recursive "$mountpoint/@root"
          btrfs subvolume snapshot "$mountpoint/@root-blank" "$mountpoint/@root"
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
