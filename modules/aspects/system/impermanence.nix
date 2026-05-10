{ inputs, ... }: {
  flake.modules.nixos.impermanence = { ... }: {
    imports = [ inputs.impermanence.nixosModules.impermanence ];

    boot.initrd.supportedFilesystems.btrfs = true;

    fileSystems."/persist".neededForBoot = true;

    environment.persistence."/persist" = {
      hideMounts = true;

      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd"
        "/var/lib/bluetooth"
        "/etc/NetworkManager/system-connections"
        "/etc/nixos"
        "/etc/ssh"
      ];

      files = [
        "/etc/machine-id"
        "/etc/adjtime"
      ];
    };

    home-manager.sharedModules = [{
      home.persistence."/persist" = { };
    }];
  };
}
