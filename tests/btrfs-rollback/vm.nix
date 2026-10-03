{ pkgs, library }:
let
  provision = { ... }: {
    imports = [
      library.inputs.agenix.nixosModules.default
      library.inputs.home-manager.nixosModules.home-manager
      library.nixosModules.impermanence
    ];

    boot = {
      initrd.systemd.enable = true;
      initrd.systemd.emergencyAccess = true;
      initrd.supportedFilesystems.btrfs = true;
      initrd.systemd.initrdBin = [
        pkgs.btrfs-progs
        pkgs.util-linux
      ];
      initrd.systemd.services.panic-on-fail.serviceConfig.ExecStart =
        pkgs.lib.mkForce "${pkgs.coreutils}/bin/true";
    };

    virtualisation = {
      emptyDiskImages = [ 1024 ];
      useDefaultFilesystems = false;
      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "btrfs";
        options = [ "subvol=@root" ];
      };
    };

    boot.initrd.systemd.services.provision-btrfs-root = {
      description = "Provision disposable Btrfs rollback test disk";
      wantedBy = [ "initrd.target" ];
      before = [ "rollback-root.service" ];
      requires = [ "dev-vdb.device" ];
      after = [ "dev-vdb.device" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        set -eu
        disk=/dev/vdb
        mkdir -p /mnt
        if ! blkid "$disk" >/dev/null 2>&1; then
          mkfs.btrfs -f -L nixos "$disk"
          mount -t btrfs -o subvolid=5 "$disk" /mnt
          btrfs subvolume create /mnt/@root
          printf 'baseline\n' > /mnt/@root/baseline
          mkdir -p /mnt/@root/nix/store
          # Match Disko's read-only recovery snapshot, not a writable sibling.
          btrfs subvolume snapshot -r /mnt/@root /mnt/@root-blank
          btrfs subvolume create /mnt/@root/nested
          btrfs subvolume create /mnt/@root/nested/level-one
          btrfs subvolume create "/mnt/@root/nested/level-one/deep child"
          printf 'dirty root\n' > /mnt/@root/dirty
          printf 'keep for failure checks\n' > /mnt/@root/keep
          printf 'nested sentinel\n' > "/mnt/@root/nested/level-one/deep child/sentinel"
          for sibling in persist nix log swap; do
            btrfs subvolume create "/mnt/@$sibling"
            printf '%s\n' "$sibling" > "/mnt/@$sibling/sentinel"
          done
          umount /mnt
        fi
      '';
    };

    boot.initrd.systemd.services.rollback-failure-check = {
      description = "Verify rollback failure leaves root and siblings intact";
      after = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        set -eu
        systemctl is-failed rollback-root.service
        ! systemctl is-active --quiet sysroot.mount
        ! mountpoint -q /sysroot
        mkdir -p /mnt
        mount -t btrfs -o subvolid=5 /dev/vdb /mnt
        test -f /mnt/@root/keep
        test -z "$(find /run -maxdepth 1 -name 'rollback-root.*' -print -quit)"
        for sibling in persist nix log swap; do
          test "$(cat /mnt/@$sibling/sentinel)" = "$sibling"
        done
        umount /mnt
        echo "$FAILURE_MARKER" > /dev/ttyS0
      '';
    };

    system.stateVersion = "25.11";
  };

  failBtrfs = pkgs.writeShellScriptBin "btrfs" ''
    if [ "$1 $2" = "subvolume show" ]; then
      echo 'injected rollback pre-delete failure' >&2
      exit 42
    fi
    exec ${pkgs.btrfs-progs}/bin/btrfs "$@"
  '';
  successCheck = _: {
    boot.initrd.systemd.services.rollback-test-check = {
      description = "Assert Btrfs rollback result before switching root";
      wantedBy = [ "initrd.target" ];
      requires = [ "sysroot.mount" ];
      after = [ "sysroot.mount" ];
      before = [ "initrd-switch-root.target" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        set -eu
        test -f /sysroot/baseline
        test ! -e /sysroot/dirty
        test ! -e /sysroot/keep
        test ! -e '/sysroot/nested/level-one/deep child'
        touch /sysroot/writable
        mkdir -p /mnt
        mount -t btrfs -o subvolid=5 /dev/vdb /mnt
        for sibling in persist nix log swap; do
          test "$(cat /mnt/@$sibling/sentinel)" = "$sibling"
        done
        umount /mnt
        btrfs subvolume create /sysroot/nested
        btrfs subvolume create /sysroot/nested/level-one
        btrfs subvolume create '/sysroot/nested/level-one/deep child'
        printf 'dirty after verifier\\n' > /sysroot/dirty
        mounted_root_id=$(btrfs inspect-internal rootid /sysroot)
        systemctl start rollback-root.service
        test "$(systemctl show --property=ActiveState --value rollback-root.service)" = active
        test "$(systemctl show --property=SubState --value rollback-root.service)" = exited
        mount -t btrfs -o subvolid=5 /dev/vdb /mnt
        test "$(btrfs inspect-internal rootid /mnt/@root)" = "$mounted_root_id"
        test -f /mnt/@root/dirty
        test -d '/mnt/@root/nested/level-one/deep child'
        umount /mnt
        echo ROLLBACK_RESULT_VERIFIED > /dev/ttyS0
      '';
    };
  };
  missingBaselineFailure = _: {
    boot.initrd.systemd.services.rollback-root.onFailure = [ "rollback-failure-check.service" ];
    boot.initrd.systemd.services.rollback-failure-check.environment.FAILURE_MARKER =
      "MISSING_BASELINE_VERIFIED";
  };
  injectedFailure = _: {
    boot.initrd.systemd.services.rollback-root.path = [
      failBtrfs
      pkgs.coreutils
      pkgs.util-linux
    ];
    boot.initrd.systemd.services.rollback-root.onFailure = [ "rollback-failure-check.service" ];
    boot.initrd.systemd.services.rollback-failure-check.environment.FAILURE_MARKER =
      "INJECTED_FAILURE_VERIFIED";
  };
in
pkgs.testers.runNixOSTest {
  name = "impermanence-btrfs-rollback";

  nodes = {
    rollback = {
      imports = [
        provision
        successCheck
      ];
    };
    missingBaseline = { ... }: {
      imports = [
        provision
        missingBaselineFailure
      ];
      boot.initrd.systemd.services.provision-btrfs-root.script = pkgs.lib.mkForce ''
        set -eu
        disk=/dev/vdb
        mkdir -p /mnt
        if ! blkid "$disk" >/dev/null 2>&1; then
          mkfs.btrfs -f -L nixos "$disk"
          mount -t btrfs -o subvolid=5 "$disk" /mnt
          btrfs subvolume create /mnt/@root
          printf 'must survive\n' > /mnt/@root/keep
          for sibling in persist nix log swap; do
            btrfs subvolume create "/mnt/@$sibling"
            printf '%s\n' "$sibling" > "/mnt/@$sibling/sentinel"
          done
          umount /mnt
        fi
      '';
    };
    injectedFailure = {
      imports = [
        provision
        injectedFailure
      ];
    };
  };

  testScript = ''
    rollback.start()
    rollback.wait_for_console_text("ROLLBACK_RESULT_VERIFIED", timeout=120)

    missingBaseline.start()
    missingBaseline.wait_for_console_text("MISSING_BASELINE_VERIFIED", timeout=120)
    injectedFailure.start()
    injectedFailure.wait_for_console_text("INJECTED_FAILURE_VERIFIED", timeout=120)
  '';
}
