{ inputs, ... }:
let
  btrfsOpts = [ "compress=zstd" "noatime" ];
  mkSubvol = mountpoint: { inherit mountpoint; mountOptions = btrfsOpts; };

  mkLuksFido2 = enrollFido2: name: content: {
    type = "luks";
    extraFormatArgs = [ "--type" "luks2" "--pbkdf" "argon2id" ];
    extraFido2EnrollArgs = [ "--fido2-with-client-pin=no" ];
    inherit enrollFido2;
    enrollRecovery = true;
    settings.allowDiscards = true;
    settings.bypassWorkqueues = true;
    inherit name content;
  };

  # Subvolume geometry shared by the encrypted and plain variants —
  # rollback root, persistent, nix, log, swap on one labelled btrfs.
  btrfsContent = {
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
        swap.swapfile.size = "64G";
      };
    };
    postCreateHook = ''
      MNTPOINT=$(mktemp -d)
      mount -t btrfs -o subvol=/ /dev/disk/by-label/nixos "$MNTPOINT"
      trap 'umount "$MNTPOINT"; rm -rf "$MNTPOINT"' EXIT
      btrfs subvolume snapshot -r "$MNTPOINT/@root" "$MNTPOINT/@root-blank"
    '';
  };
in
{
  flake.modules.nixos.disko = { lib, config, ... }:
    let
      cfg = config.dotnix.disk;
      mkDefaultLeaves = lib.mapAttrsRecursive (_: lib.mkDefault);
    in
    {
      imports = [ inputs.disko.nixosModules.disko ];

      options.dotnix.disk = {
        encrypt = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Wrap the root btrfs in a LUKS2 container. Hosts without disk encryption (VMs, most cloud images) set this to false and get the same subvolume geometry unencrypted.";
        };
        enrollFido2 = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enroll a FIDO2 key as an additional LUKS credential next to the passphrase; meaningless when encrypt is false.";
        };
      };

      config = {
        # Library default layout; hosts override it with their own disko
        # config, or keep the geometry and switch the crypto options off.
        disko.devices.disk.main.type = lib.mkDefault "disk";
        disko.devices.disk.main.content = mkDefaultLeaves {
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
              content =
                if cfg.encrypt
                then mkLuksFido2 cfg.enrollFido2 "cryptroot" btrfsContent
                else btrfsContent;
            };
          };
        };

        # /nix must be up before the persist-*.services — they execute
        # store paths. Without neededForBoot the mount raced local-fs in
        # stage 2 and sporadically failed to bind machine-id and ssh keys.
        fileSystems."/nix".neededForBoot = true;
        fileSystems."/persist".neededForBoot = true;
        fileSystems."/var/log".neededForBoot = true;
      };
    };
}
