let
  flake = builtins.getFlake (toString ../.);
  lib = flake.inputs.nixpkgs.lib;
  pkgs = import flake.inputs.nixpkgs {
    system = "x86_64-linux";
    overlays = [ flake.inputs.llm-agents.overlays.shared-nixpkgs ];
  };
  homeManager = flake.inputs.home-manager;
  herdrPackage = pkgs.llm-agents.herdr;

  evaluate = modules: withOsConfig:
    homeManager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = lib.optionalAttrs withOsConfig {
        osConfig = {
          hardware.bluetooth.enable = false;
          networking.wireless.iwd.enable = false;
        };
      };
      modules = [
        (_: {
          home.username = "test";
          home.homeDirectory = "/home/test";
          home.stateVersion = "24.11";
        })
      ] ++ modules;
    };

  standaloneHerdr = evaluate [ flake.modules.homeManager.herdr ] false;
  terminal = evaluate [ flake.modules.homeManager.terminal ] true;
  terminalHerdr = evaluate [ flake.modules.homeManager.terminal-herdr ] true;
  herdrConfig = standaloneHerdr.config.xdg.configFile."herdr/config.toml";
  containsPackage = config: package: builtins.elem package config.home.packages;
  # Popup launcher mirrors the tmux popup menu; ungated tools only in the
  # standalone evaluation (no osConfig, no enabled programs).
  herdrBindings = standaloneHerdr.config.programs.herdr.settings.keys.command;
  terminalHerdrBindings = terminalHerdr.config.programs.herdr.settings.keys.command;
in
assert containsPackage standaloneHerdr.config herdrPackage;
assert standaloneHerdr.config.programs.herdr.package == herdrPackage;
assert standaloneHerdr.config.programs.herdr.settings.terminal.default_shell
  == lib.getExe pkgs.fish;
assert standaloneHerdr.config.programs.herdr.settings.keys.prefix == "ctrl+space";
assert lib.hasSuffix "herdr-config.toml" (toString herdrConfig.source);
assert builtins.all (b: b.type == "popup") herdrBindings;
assert map (b: b.description) herdrBindings
  == [ "shell" "nix-graph" "dua" "scratch" ];
assert builtins.elem "yazi" (map (b: b.description) terminalHerdrBindings);
assert !(builtins.elem "bluetui"
  (map (b: b.description) terminalHerdrBindings));
assert !(lib.any
  (name: lib.hasInfix "claude" name || lib.hasInfix "codex" name)
  (builtins.attrNames standaloneHerdr.config.xdg.configFile));
assert terminal.config.programs.tmux.enable;
assert terminal.config.programs.sesh.enable;
assert !(containsPackage terminal.config herdrPackage);
assert !(terminal.config.xdg.configFile ? "herdr/config.toml");
assert containsPackage terminalHerdr.config herdrPackage;
assert terminalHerdr.config.programs.starship.enable;
assert terminalHerdr.config.programs.yazi.enable;
assert !(terminalHerdr.options ? dotnix);
assert !(builtins.elem pkgs.tmux terminalHerdr.config.home.packages);
assert !(builtins.elem pkgs.zellij terminalHerdr.config.home.packages);
assert !(builtins.elem pkgs.sesh terminalHerdr.config.home.packages);
true
