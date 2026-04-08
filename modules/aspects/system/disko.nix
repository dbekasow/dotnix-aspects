{ inputs, ... }: {
  flake.modules.nixos.disko = { lib, ... }: {
    imports = [ inputs.disko.nixosModules.disko ];

    disko.devices.disk.main = {
      device = lib.mkDefault "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          # EFI boot partition
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
          # Swap for hibernation support
          swap = {
            priority = 2;
            size = lib.mkDefault "8G"; # adjust based on ram
            content = {
              type = "swap";
              resumeDevice = true; # enable hibernation
            };
          };
          # Root filesystem
          root = {
            priority = 3;
            size = "100%"; # use remaining space
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
