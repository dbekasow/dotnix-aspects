{ inputs, ... }:
let
  btrfsOpts = [ "compress=zstd" "noatime" ];
  mkSubvol = mountpoint: { inherit mountpoint; mountOptions = btrfsOpts; };

  mkLuksFido2 = name: content: {
    type = "luks";
    extraFormatArgs = [ "--type" "luks2" "--pbkdf" "argon2id" ];
    extraFido2EnrollArgs = [ "--fido2-with-client-pin=no" ];
    enrollFido2 = true;
    enrollRecovery = true;
    settings.allowDiscards = true;
    settings.bypassWorkqueues = true;
    inherit name content;
  };
in
{
  flake.modules.nixos.disko = { lib, ... }: {
    imports = [ inputs.disko.nixosModules.disko ];

    disko.devices.disk.main = {
      device = lib.mkDefault "/dev/nvme0n1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          root = {
            priority = 2;
            size = "100%";
            content = mkLuksFido2 "cryptroot" {
              type = "btrfs";
              extraArgs = [ "-L" "nixos" "-f" ];
              subvolumes = {
                "@root" = mkSubvol "/";
                "@persist" = mkSubvol "/persist";
                "@nix" = mkSubvol "/nix";
                "@log" = mkSubvol "/var/log";
                "@swap" = {
                  mountpoint = "/swap";
                  mountOptions = [ "noatime" ];
                  swap.swapfile.size = lib.mkDefault "64G";
                };
              };
              postCreateHook = ''
                MNTPOINT=$(mktemp -d)
                mount -t btrfs -o subvol=/ /dev/disk/by-label/nixos "$MNTPOINT"
                trap 'umount "$MNTPOINT"; rm -rf "$MNTPOINT"' EXIT
                btrfs subvolume snapshot -r "$MNTPOINT/@root" "$MNTPOINT/@root-blank"
              '';
            };
          };
        };
      };
    };

    fileSystems."/persist".neededForBoot = true;
    fileSystems."/var/log".neededForBoot = true;
  };
}
