{
  inputs = {
    dotnix.url = "path:../..";
    flake-parts.follows = "dotnix/flake-parts";
    nixpkgs.follows = "dotnix/nixpkgs";
  };

  outputs =
    inputs:
    let
      server = {
        imports = [
          inputs.dotnix.nixosModules.server
          inputs.dotnix.nixosModules.security
        ];
        boot.loader.grub = {
          enable = true;
          device = "nodev";
        };
        fileSystems."/" = {
          device = "/dev/fixture-root";
          fsType = "ext4";
        };
      };
      hardwareGate = { config, lib, ... }: {
        options.fixture.hardwareAuthenticationGate = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        config = lib.mkIf config.fixture.hardwareAuthenticationGate {
          security.sudo-rs.wheelNeedsPassword = lib.mkForce false;
        };
      };
      hosts = inputs.self.nixosConfigurations;
      defaultHost = hosts.fixture-server.config;
      gatedHost = hosts.fixture-hardware-gated.config;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.dotnix.flakeModule ];

      dotnix.hosts = {
        fixture-server.modules = [ server ];
        fixture-hardware-gated.modules = [
          server
          hardwareGate
          { fixture.hardwareAuthenticationGate = true; }
        ];
      };

      flake.checks.x86_64-linux.headless-security =
        assert defaultHost.dotnix.hostname == "fixture-server";
        assert gatedHost.dotnix.hostname == "fixture-hardware-gated";
        assert !defaultHost.dotnix.vaultReady;
        assert defaultHost.security.sudo-rs.wheelNeedsPassword;
        assert gatedHost.fixture.hardwareAuthenticationGate;
        assert !gatedHost.security.sudo-rs.wheelNeedsPassword;
        assert defaultHost.fileSystems."/".device == "/dev/fixture-root";
        assert gatedHost.fileSystems."/".device == "/dev/fixture-root";
        assert defaultHost.boot.loader.grub.enable;
        assert gatedHost.boot.loader.grub.enable;
        inputs.nixpkgs.legacyPackages.x86_64-linux.runCommand "headless-security" { } "touch $out";
    };
}
