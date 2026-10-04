let
  flake = builtins.getFlake (toString ../.);
  nixpkgs = flake.inputs.nixpkgs;
  homeManager = flake.inputs.home-manager;
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
  # HM switches Firefox's profile location at stateVersion 26.05; the
  # firefox impermanence contribution keys off programs.firefox.configPath.
  hmWithStateVersion = sv:
    (homeManager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      modules = [{
        home.username = "fixture";
        home.homeDirectory = "/home/fixture";
        home.stateVersion = sv;
      }];
    }).config.programs.firefox.configPath;
in
assert host.config.system.stateVersion == "26.05";
assert host.config.home-manager.users.fixture.home.stateVersion == "25.11";
assert hmWithStateVersion "25.11" == ".mozilla/firefox";
assert hmWithStateVersion "26.05" == ".config/mozilla/firefox";
"independent OS and Home Manager state versions passed"
