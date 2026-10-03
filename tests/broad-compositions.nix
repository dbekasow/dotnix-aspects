let
  flake = builtins.getFlake (toString ../.);
  nixpkgs = flake.inputs.nixpkgs;
  homeManager = flake.inputs.home-manager;
  system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
    overlays = [
      flake.inputs.nur.overlays.default
      flake.inputs.llm-agents.overlays.shared-nixpkgs
      flake.inputs.niri.overlays.niri
    ];
  };
  bootstrap = _: {
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "nodev";
    fileSystems."/" = {
      device = "/dev/vda1";
      fsType = "ext4";
    };
    system.stateVersion = "25.11";
    nixpkgs.hostPlatform = system;
  };
  evaluateNixOS =
    modules:
    (nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        flake.nixosModules.dotnix
        { dotnix.hostname = "fixture"; }
      ]
      ++ modules;
    }).config;
  workstation = evaluateNixOS [
    homeManager.nixosModules.default
    flake.nixosModules.core
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
    flake.nixosModules.desktop
    flake.nixosModules.development
    {
      home-manager.useGlobalPkgs = true;
      home-manager.users.fixture = {
        imports = [
          flake.homeManagerModules.desktop
          flake.homeManagerModules.development
          flake.homeManagerModules.noctalia
        ];
        home.username = "fixture";
        home.homeDirectory = "/home/fixture";
      };
    }
  ];
  socketOnly = evaluateNixOS [
    flake.nixosModules.desktop-shell
    bootstrap
  ];
  dmsSelected = evaluateNixOS [
    flake.nixosModules.desktop-shell
    flake.nixosModules.dms
    flake.nixosModules.dms-greeter
    bootstrap
    {
      dotnix.hostname = "fixture";
      dotnix.members = [ "fixture" ];
      users.users.fixture.home = "/home/fixture";
    }
  ];
  noctaliaSelected = evaluateNixOS [
    flake.nixosModules.desktop-shell
    flake.nixosModules.noctalia-greeter
    bootstrap
  ];
  home = homeManager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs.osConfig.system.stateVersion = "25.11";
    modules = [
      flake.homeManagerModules.stylix
      flake.homeManagerModules.desktop
      flake.homeManagerModules.noctalia
      (_: {
        home.username = "fixture";
        home.homeDirectory = "/home/fixture";
        home.stateVersion = "25.11";
      })
    ];
  };
  homeWithNiri = homeManager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs.osConfig.system.stateVersion = "25.11";
    modules = [
      flake.homeManagerModules.desktop-shell
      flake.homeManagerModules.noctalia
      (_: {
        home.username = "fixture";
        home.homeDirectory = "/home/fixture";
        home.stateVersion = "25.11";
      })
    ];
  };
  checks = {
    workstationHasSelectedRootAndBootloader =
      workstation.fileSystems."/".fsType == "btrfs" && workstation.boot.loader.systemd-boot.enable;
    workstationHasCoreSystemDesktopDevelopment =
      workstation.programs.fish.enable
      && workstation.zramSwap.enable
      && workstation.programs.niri.enable
      && workstation.virtualisation.docker.enable
      && workstation.home-manager.users.fixture.programs.helix.enable;
    socketDoesNotSelectShellOrGreeter =
      !(socketOnly.programs.dank-material-shell.enable or false)
      && !(socketOnly.programs.dms-greeter.enable or false)
      && !(socketOnly.services.displayManager.noctalia-greeter.enable or false);
    dmsShellAndGreeterExplicitlySelected =
      dmsSelected.programs.dank-material-shell.enable && dmsSelected.programs.dms-greeter.enable;
    noctaliaGreeterExplicitlySelected =
      noctaliaSelected.services.displayManager.noctalia-greeter.enable;
    noctaliaHomeShellExplicitlySelected = home.config.programs.noctalia.enable;
    noctaliaNiriContextHasBinds =
      homeWithNiri.config.programs.noctalia.enable
      && builtins.hasAttr "Mod+Space" homeWithNiri.config.programs.niri.settings.binds;
    developmentOptional = !socketOnly.programs.nix-ld.enable;
  };
  failed = builtins.attrNames (nixpkgs.lib.filterAttrs (_: passed: !passed) checks);
in
if failed == [ ] then
  checks
else
  throw "Broad composition fixture failed: ${nixpkgs.lib.concatStringsSep ", " failed}"
