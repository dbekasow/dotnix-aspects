let
  flake = builtins.getFlake (toString ../.);
  nixpkgs = flake.inputs.nixpkgs;
  host = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      flake.nixosModules.home-manager
      (_: {
        system.stateVersion = "26.05";
        nixpkgs.hostPlatform = "x86_64-linux";
        home-manager.users.fixture = {
          home.username = "fixture";
          home.homeDirectory = "/home/fixture";
          home.stateVersion = "25.11";
        };
      })
    ];
  };
in
assert host.config.system.stateVersion == "26.05";
assert host.config.home-manager.users.fixture.home.stateVersion == "25.11";
"independent OS and Home Manager state versions passed"
