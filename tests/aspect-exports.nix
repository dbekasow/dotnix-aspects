let
  inputs = builtins.getFlake (toString ../.);
  flakeInputs = inputs.inputs // {
    dotnix = inputs;
  };
  result = inputs.inputs.flake-parts.lib.mkFlake { inputs = flakeInputs; } {
    imports = [ inputs.flakeModule ];

    flake.modules.nixos.alice = {
      users.users.alice.isNormalUser = true;
    };
    flake.modules.nixos.bob = {
      users.users.bob.isNormalUser = true;
    };

    dotnix.hosts = {
      alpha = {
        members = [ "alice" ];
        modules = [
          inputs.modules.nixos.disko
          (_: {
            boot.loader.grub.enable = true;
            boot.loader.grub.device = "nodev";
            fileSystems."/" = {
              device = "/dev/vda1";
              fsType = "ext4";
            };
            system.stateVersion = "25.11";
          })
        ];
      };
      beta = {
        members = [ "bob" ];
        modules = [
          inputs.modules.nixos.disko
          (_: {
            dotnix.disk.encrypt = false;
            boot.loader.grub.enable = true;
            boot.loader.grub.device = "nodev";
            fileSystems."/" = {
              device = "/dev/vda1";
              fsType = "ext4";
            };
            system.stateVersion = "25.11";
          })
        ];
      };
    };
  };
  registry = inputs.inputs.flake-parts.lib.mkFlake { inputs = flakeInputs; } {
    imports = [ inputs.flakeModules.aspects ];
  };
  registryHost = inputs.inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [ registry.modules.nixos.dotnix ];
  };
  hosts = result.nixosConfigurations;
  alpha = hosts.alpha.config;
  beta = hosts.beta.config;
  profileOptions =
    builtins.attrNames
      (inputs.inputs.nixpkgs.lib.evalModules {
        modules = [ inputs.modules.generic.users-profile ];
        specialArgs = {
          self = inputs;
        };
      }).options.profile;
  nixosExports = builtins.attrNames inputs.nixosModules;
  homeManagerExports = builtins.attrNames inputs.homeManagerModules;
  home = inputs.inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.inputs.nixpkgs {
      system = "x86_64-linux";
      overlays = [ inputs.inputs.niri.overlays.niri ];
    };
    extraSpecialArgs.osConfig = {
      hardware.bluetooth.enable = false;
      networking.wireless.iwd.enable = false;
    };
    modules = [
      inputs.homeManagerModules.tmux
      inputs.homeManagerModules.git-repos
      inputs.homeManagerModules.niri
      (_: {
        config = {
          home.username = "fixture";
          home.homeDirectory = "/home/fixture";
          home.stateVersion = "25.11";
          dotnix.tmux.bindings = [
            {
              key = "z";
              name = "Fixture binding";
              command = "display-message fixture";
            }
          ];
          dotnix.git.repositories.fixture = "https://example.invalid/fixture.git";
        };
      })
    ];
  };
  stylixHome = inputs.inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.inputs.nixpkgs.legacyPackages.x86_64-linux;
    extraSpecialArgs.osConfig = {
      hardware.bluetooth.enable = false;
      networking.wireless.iwd.enable = false;
    };
    modules = [
      inputs.homeManagerModules.tmux
      inputs.homeManagerModules.stylix
      (_: {
        home.username = "fixture";
        home.homeDirectory = "/home/fixture";
        home.stateVersion = "25.11";
      })
    ];
  };
in
assert alpha.dotnix.hostname == "alpha";
assert alpha.networking.hostName == "alpha";
assert alpha.dotnix.members == [ "alice" ];
assert beta.dotnix.hostname == "beta";
assert beta.dotnix.members == [ "bob" ];
assert !(alpha.dotnix ? host);
assert !(beta.dotnix ? host);
assert alpha.dotnix.vaultReady == false;
assert hosts.alpha.options.dotnix.vaultReady.readOnly;
assert registry.nixosConfigurations == { };
assert registryHost.config.dotnix.hostname == null;
assert registryHost.config.dotnix.vaultReady == false;
assert registryHost.options.dotnix.vaultReady.readOnly;
assert
profileOptions == [
  "email"
  "fullname"
];
assert builtins.elem "dotnix" nixosExports;
assert builtins.elem "disko" nixosExports;
assert builtins.elem "tmux" homeManagerExports;
assert builtins.elem "git-repos" homeManagerExports;
assert !(builtins.elem "home-manager" homeManagerExports);
assert alpha.dotnix.disk.encrypt;
assert alpha.disko.devices.disk.main.content.partitions.root.content.type == "luks";
assert !beta.dotnix.disk.encrypt;
assert beta.disko.devices.disk.main.content.partitions.root.content.type == "btrfs";
assert !(home.options ? stylix);
assert builtins.any (binding: binding.key == "z") home.config.dotnix.tmux.bindings;
assert home.config.dotnix.git.repositories.fixture == "https://example.invalid/fixture.git";
assert !stylixHome.config.stylix.targets.tmux.enable;
assert
home.config.programs.niri.settings.screenshot-path
  == "~/pictures/screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
"aspect export contract checks passed"
