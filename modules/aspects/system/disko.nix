{ inputs, ... }:
let
  btrfsOpts = [ "compress=zstd" "noatime" ];
  mkSubvol = mountpoint: { inherit mountpoint; mountOptions = btrfsOpts; };
in
{
  flake.modules.nixos.disko = { lib, ... }: {
    imports = [ inputs.disko.nixosModules.disko ];

    disko.devices.disk.main = {
      device = lib.mkDefault "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          swap = {
            priority = 2;
            size = lib.mkDefault "8G";
            content = {
              type = "swap";
              resumeDevice = false;
            };
          };
          root = {
            priority = 3;
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-L" "nixos" "-f" ];
              subvolumes = {
                "@root-blank" = { };
                "@root" = mkSubvol "/";
                "@persist" = mkSubvol "/persist";
                "@nix" = mkSubvol "/nix";
                "@log" = mkSubvol "/var/log";
              };
              postCreateHook = ''
                MNTPOINT=$(mktemp -d)
                mount -t btrfs -o subvol=/ /dev/disk/by-label/nixos "$MNTPOINT"
                trap 'umount "$MNTPOINT"; rm -rf "$MNTPOINT"' EXIT
                btrfs subvolume delete "$MNTPOINT/@root-blank" 2>/dev/null || true
                btrfs subvolume snapshot -r "$MNTPOINT/@root" "$MNTPOINT/@root-blank"
              '';
            };
          };
        };
      };
    };
  };
}
