{
  inputs = {
    dotnix.url = "path:../..";
    den.follows = "dotnix/den";
    flake-parts.follows = "dotnix/flake-parts";
    nixpkgs.follows = "dotnix/nixpkgs";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.den.flakeModule
        (inputs.den.namespace "dotnix" [ inputs.dotnix true ])
        ({ dotnix, ... }: {
          den.hosts.x86_64-linux.fixture-server = { };
          den.hosts.x86_64-linux.fixture-hardware-gated = { };

          den.aspects.fixture-server = {
            includes = [ dotnix.server dotnix.host.security ];
            nixos = {
              boot.loader.grub = {
                enable = true;
                device = "nodev";
              };
              fileSystems."/" = {
                device = "/dev/fixture-root";
                fsType = "ext4";
              };
              networking.hostName = "fixture-server";
            };
          };

          den.aspects.fixture-hardware-gated = {
            includes = [ dotnix.server dotnix.host.security ];
            nixos = { config, lib, ... }: {
              options.fixture.hardwareAuthenticationGate = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };
              config = {
                boot.loader.grub = {
                  enable = true;
                  device = "nodev";
                };
                fileSystems."/" = {
                  device = "/dev/fixture-root";
                  fsType = "ext4";
                };
                networking.hostName = "fixture-hardware-gated";
                security.sudo-rs.wheelNeedsPassword = lib.mkIf config.fixture.hardwareAuthenticationGate (lib.mkForce false);
                fixture.hardwareAuthenticationGate = true;
              };
            };
          };
        })
      ];

      perSystem = { pkgs, ... }:
        let
          hosts = inputs.self.nixosConfigurations;
          defaultHost = hosts.fixture-server.config;
          gatedHost = hosts.fixture-hardware-gated.config;
        in
        {
          checks.headless-security =
            assert defaultHost.networking.hostName == "fixture-server";
            assert gatedHost.networking.hostName == "fixture-hardware-gated";
            assert (defaultHost.age.secrets or { }) == { };
            assert defaultHost.security.sudo-rs.wheelNeedsPassword;
            assert gatedHost.fixture.hardwareAuthenticationGate;
            assert !gatedHost.security.sudo-rs.wheelNeedsPassword;
            assert defaultHost.fileSystems."/".device == "/dev/fixture-root";
            assert gatedHost.fileSystems."/".device == "/dev/fixture-root";
            assert defaultHost.boot.loader.grub.enable;
            assert gatedHost.boot.loader.grub.enable;
            pkgs.runCommand "headless-security" { } "touch $out";
        };
    };
}
