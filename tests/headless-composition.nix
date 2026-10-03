let
  flake = builtins.getFlake (toString ../.);
  nixpkgs = flake.inputs.nixpkgs;
  system = "x86_64-linux";
  bootstrap = { lib, ... }: {
    options.dotnix.vaultReady = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    config = {
      boot.loader.grub.enable = true;
      boot.loader.grub.device = "nodev";
      fileSystems."/" = {
        device = "/dev/vda1";
        fsType = "ext4";
      };
      system.stateVersion = "25.11";
    };
  };
  evaluate =
    modules:
    (nixpkgs.lib.nixosSystem {
      inherit system modules;
    }).config;
  server = evaluate [
    flake.nixosModules.server
    bootstrap
  ];
  workstation = evaluate [
    flake.inputs.agenix.nixosModules.default
    flake.inputs.home-manager.nixosModules.default
    flake.nixosModules.base
    flake.nixosModules.boot-systemd
    flake.nixosModules.performance
    flake.nixosModules.bluetooth
    flake.nixosModules.disko
    flake.nixosModules.impermanence
    flake.nixosModules.geolocation
    flake.nixosModules.network
    flake.nixosModules.network-wifi
    flake.nixosModules.pipewire
    flake.nixosModules.power
    flake.nixosModules.yubikey
    flake.nixosModules.yubikey-pam
    { disko.devices.disk.main.device = "/dev/vda"; }
    bootstrap
  ];
in
assert server.fileSystems."/".device == "/dev/vda1";
assert server.boot.loader.grub.enable;
assert !server.boot.loader.systemd-boot.enable;
assert !(server.boot.kernel.sysctl ? "vm.swappiness");
assert !(server.boot.kernel.sysctl ? "vm.vfs_cache_pressure");
assert !(server.boot.kernel.sysctl ? "vm.dirty_background_ratio");
assert !(server.boot.kernel.sysctl ? "vm.dirty_ratio");
assert server.boot.kernel.sysctl."vm.max_map_count" != 2147483642;
assert !server.zramSwap.enable;
assert !server.hardware.bluetooth.enable;
assert !server.services.pipewire.enable;
assert !server.services.upower.enable;
assert !server.services.thermald.enable;
assert server.boot.resumeDevice == "";
assert !(builtins.hasAttr "disko" server);
assert workstation.boot.kernel.sysctl."vm.swappiness" == 10;
assert workstation.boot.kernel.sysctl."vm.vfs_cache_pressure" == 50;
assert workstation.boot.kernel.sysctl."vm.dirty_background_ratio" == 5;
assert workstation.boot.kernel.sysctl."vm.dirty_ratio" == 10;
assert workstation.boot.kernel.sysctl."vm.max_map_count" == 2147483642;
assert workstation.zramSwap.enable;
assert workstation.services.fstrim.enable;
assert workstation.boot.loader.systemd-boot.enable;
"headless and workstation composition checks passed"
