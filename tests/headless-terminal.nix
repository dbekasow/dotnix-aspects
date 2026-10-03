let
  flake = builtins.getFlake (toString ../.);
  nixpkgs = flake.inputs.nixpkgs;
  system = "x86_64-linux";
  pkgs = import nixpkgs { inherit system; };
  host = nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      flake.inputs.home-manager.nixosModules.default
      flake.nixosModules.server
      (_: {
        boot.loader.grub.enable = true;
        boot.loader.grub.device = "nodev";
        fileSystems."/" = {
          device = "/dev/vda1";
          fsType = "ext4";
        };
        system.stateVersion = "25.11";
        users.users.fixture.isNormalUser = true;
        home-manager.useGlobalPkgs = true;
        home-manager.users.fixture = {
          imports = [
            flake.modules.homeManager.core
            flake.modules.homeManager.terminal
          ];
          home.stateVersion = "25.11";
          profile.email = "fixture@example.invalid";
        };
      })
    ];
  };
  user = host.config.home-manager.users.fixture;
in
assert user.services.gpg-agent.pinentry.package.pname == "pinentry-curses";
assert user.programs.rbw.settings.pinentry == nixpkgs.lib.getExe pkgs.pinentry-curses;
assert !(builtins.elem pkgs.wl-clipboard user.home.packages);
assert nixpkgs.lib.any
  (plugin: nixpkgs.lib.hasInfix ''tmux set-buffer -- "{}" && tmux paste-buffer'' (plugin.extraConfig or ""))
  user.programs.tmux.plugins;
"headless terminal composition checks passed"
