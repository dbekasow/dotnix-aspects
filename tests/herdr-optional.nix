let
  flake = builtins.getFlake (toString ../.);
  lib = flake.inputs.nixpkgs.lib;
  pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; };
  homeManager = flake.inputs.home-manager;
  herdrPackage = flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr;

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
  herdrConfig = builtins.readFile standaloneHerdr.config.xdg.configFile."herdr/config.toml".source;
  containsPackage = config: package: builtins.elem package config.home.packages;
in
assert containsPackage standaloneHerdr.config herdrPackage;
assert herdrConfig == "[terminal]\ndefault_shell = \"${lib.getExe pkgs.fish}\"\n";
assert standaloneHerdr.config.xdg.configFile ? "herdr/config.toml";
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
