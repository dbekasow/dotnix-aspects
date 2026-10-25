let
  source = builtins.getFlake (toString ../.);
  inputs = source.inputs // { dotnix = source; self = source; };
  dotnix = source.denful.dotnix;
  system = "x86_64-linux";

  bootstrap = {
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "nodev";
    fileSystems."/" = {
      device = "/dev/vda1";
      fsType = "ext4";
    };
    system.stateVersion = "25.11";
  };

  evaluate =
    { hostIncludes ? [ ], hostModule ? { } }:
    let
      fixture = {
        imports = [
          inputs.den.flakeModule
          (inputs.den.namespace "dotnix" [ inputs.dotnix true ])
          ({ den, ... }: { den.default.includes = [ den.batteries.flake-scope ]; })
        ];
        den.hosts.${system}.fixture = { };
        den.aspects.fixture = {
          includes = hostIncludes;
          nixos = bootstrap // hostModule;
        };
      };
      flake = inputs.flake-parts.lib.mkFlake { inherit inputs; } fixture;
    in
    flake.nixosConfigurations.fixture.config;

  server = evaluate {
    hostIncludes = [ dotnix.server ];
  };
  workstation = evaluate {
    hostIncludes = with dotnix; [
      host.home-manager
      base
      host.boot-systemd
      host.performance
      host.bluetooth
      host.disko
      impermanence
      host.geolocation
      host.network
      host.network-wifi
      host.pipewire
      host.power
      age
      age-rekey
      yubikey
      yubikey-pam
    ];
    hostModule = { disko.devices.disk.main.device = "/dev/vda"; };
  };
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
