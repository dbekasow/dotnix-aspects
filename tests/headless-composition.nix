{ source ? builtins.getFlake (toString ../.) }:
let
  inputs = source.inputs // { dotnix = source; self = source; };
  modules = import inputs.dotnix;
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
    { imports ? [ (inputs.dotnix + "/modules/base") ]
    , select ? (_: [ ])
    , hostModule ? { }
    }:
    let
      fixture = { dotnix, ... }: {
        inherit imports;
        den.hosts.${system}.fixture = { };
        den.aspects.fixture = {
          includes = select dotnix.host;
          nixos.imports = [ bootstrap hostModule ];
        };
      };
      flake = inputs.flake-parts.lib.mkFlake { inherit inputs; } fixture;
    in
    flake.nixosConfigurations.fixture.config;

  # Compare only the policy that power must leave to the platform or host.
  powerPolicy = config: {
    thermald = config.services.thermald.enable;
    resumeDevice = config.boot.resumeDevice;
    sleepMode = builtins.filter (param: builtins.match "mem_sleep_default=.*" param != null) config.boot.kernelParams;
    sleep = builtins.intersectAttrs
      {
        AllowSuspend = null;
        AllowHibernation = null;
        AllowSuspendThenHibernate = null;
        AllowHybridSleep = null;
        HibernateDelaySec = null;
      }
      config.systemd.sleep.settings.Sleep;
    logind = builtins.intersectAttrs
      {
        HandlePowerKey = null;
        HandleLidSwitch = null;
        HandleLidSwitchExternalPower = null;
      }
      config.services.logind.settings.Login;
    upower = {
      inherit (config.services.upower) percentageLow percentageCritical percentageAction criticalPowerAction;
    };
  };

  control = evaluate { };
  power = evaluate {
    select = host: [ host.power ];
  };
  server = evaluate {
    select = host: [ host.server ];
  };
  workstation = evaluate {
    select = host: [ host.workstation ];
  };
  nativeHost = {
    boot.resumeDevice = "/dev/vda2";
    boot.kernelParams = [ "mem_sleep_default=s2idle" ];
    systemd.sleep.settings.Sleep = {
      AllowHibernation = "no";
      HibernateDelaySec = "42min";
    };
    services.logind.settings.Login = {
      HandlePowerKey = "poweroff";
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "suspend";
    };
    services.upower = {
      percentageLow = 23;
      percentageCritical = 13;
      percentageAction = 5;
      criticalPowerAction = "PowerOff";
    };
  };
  nativeControl = evaluate { hostModule = nativeHost; };
  nativeWorkstation = evaluate {
    select = host: [ host.workstation ];
    hostModule = nativeHost;
  };
  optional = evaluate {
    select = host: [ host.performance dotnix.host.geolocation host.btrfs-root-reset ];
  };
  yubikey = evaluate {
    imports = [ modules.system modules.yubikey ];
    select = host: [ host.server host.yubikey host.yubikey-pam ];
  };
in
assert powerPolicy power == powerPolicy control;
assert power.services.upower.enable;
assert power.services.power-profiles-daemon.enable;
assert builtins.any (package: toString package == toString power.boot.kernelPackages.cpupower) power.environment.systemPackages;
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
assert server.services.openssh.enable;
assert server.security.polkit.enable;
assert server.security.sudo-rs.enable;
assert builtins.length dotnix.host.server.includes == 3;
assert !(server.programs.fish.enable or false);
assert !(server ? stylix);
assert !(server ? age);
assert workstation.boot.loader.systemd-boot.enable == control.boot.loader.systemd-boot.enable;
assert workstation.boot.loader.grub.enable;
assert workstation.fileSystems."/".device == "/dev/vda1";
assert workstation.fileSystems."/".fsType == "ext4";
assert builtins.attrNames workstation.fileSystems == builtins.attrNames control.fileSystems;
assert !(workstation ? disko);
assert !(workstation.environment ? persistence);
assert !(workstation.boot.initrd.systemd.services ? rollback-root);
assert !(workstation.boot.kernel.sysctl ? "vm.swappiness");
assert !(workstation.boot.kernel.sysctl ? "vm.vfs_cache_pressure");
assert !(workstation.boot.kernel.sysctl ? "vm.dirty_background_ratio");
assert !(workstation.boot.kernel.sysctl ? "vm.dirty_ratio");
assert workstation.boot.kernel.sysctl."vm.max_map_count" != 2147483642;
assert workstation.zramSwap.enable == control.zramSwap.enable;
assert workstation.services.fstrim.enable == control.services.fstrim.enable;
assert workstation.location.provider == control.location.provider;
assert workstation.services.geoclue2.enable == control.services.geoclue2.enable;
assert workstation.services.pcscd.enable == control.services.pcscd.enable;
assert workstation.boot.tmp.cleanOnBoot;
assert workstation.services.journald.settings.Journal.Storage == "persistent";
assert workstation.hardware.bluetooth.enable;
assert workstation.networking.networkmanager.enable;
assert workstation.networking.wireless.iwd.enable;
assert workstation.services.pipewire.enable;
assert workstation.services.upower.enable;
assert workstation.services.power-profiles-daemon.enable;
assert powerPolicy workstation == powerPolicy control;
assert powerPolicy nativeWorkstation == powerPolicy nativeControl;
assert nativeWorkstation.boot.loader.grub.enable;
assert nativeWorkstation.fileSystems."/".device == "/dev/vda1";
assert nativeWorkstation.fileSystems."/".fsType == "ext4";
assert nativeWorkstation.boot.resumeDevice == "/dev/vda2";
assert nativeWorkstation.systemd.sleep.settings.Sleep.AllowHibernation == "no";
assert nativeWorkstation.services.upower.percentageCritical == 13;
assert optional.boot.kernel.sysctl."vm.swappiness" == 10;
assert optional.boot.kernel.sysctl."vm.vfs_cache_pressure" == 50;
assert optional.boot.kernel.sysctl."vm.dirty_background_ratio" == 5;
assert optional.boot.kernel.sysctl."vm.dirty_ratio" == 10;
assert optional.boot.kernel.sysctl."vm.max_map_count" == 2147483642;
assert optional.zramSwap.enable;
assert optional.services.fstrim.enable;
assert optional.location.provider == "geoclue2";
assert optional.services.geoclue2.enable;
assert yubikey.services.pcscd.enable;
assert yubikey.security.pam.u2f.enable;
assert yubikey.programs.yubikey-manager.enable;
assert !(yubikey ? age || yubikey ? home-manager);
assert optional.boot.initrd.systemd.services ? rollback-root;
"headless and workstation composition checks passed"
