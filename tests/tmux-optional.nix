let
  flake = builtins.getFlake (toString ../.);
  lib = flake.inputs.nixpkgs.lib;
  pkgs = (import flake.inputs.nixpkgs { system = builtins.currentSystem; }).extend
    flake.inputs.llm-agents.overlays.shared-nixpkgs;
  homeManager = flake.inputs.home-manager;
  tmux = flake.homeManagerModules.tmux;
  workmux = flake.homeManagerModules.workmux;
  tuicr = flake.homeManagerModules.tuicr;

  fixture = { lib, ... }: {
    options.profile.fullname = lib.mkOption {
      type = lib.types.str;
      default = "Fixture User";
    };
    options.stylix.targets.tmux.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };
  osConfig = _: {
    _module.args.osConfig = {
      hardware.bluetooth.enable = false;
      networking.wireless.iwd.enable = false;
    };
  };
  evaluate = modules: homeManager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      fixture
      osConfig
      (_: {
        home.username = "test";
        home.homeDirectory = "/home/test";
        home.stateVersion = "24.11";
      })
    ] ++ modules;
  };
  names = attr: config: map (item: item.name) config.dotnix.tmux.${attr};

  tmuxOnly = evaluate [ tmux ];
  toolsAndEnabledTmux = evaluate [ tmux workmux tuicr ];
  toolsOnly = evaluate [ workmux tuicr ];
  toolsAndDisabledTmux = evaluate [
    tmux
    workmux
    tuicr
    (_: { programs.tmux.enable = lib.mkForce false; })
  ];
  enabledPopups = names "popups" toolsAndEnabledTmux.config;
  enabledBindings = names "bindings" toolsAndEnabledTmux.config;
  disabledPopups = names "popups" toolsAndDisabledTmux.config;
  disabledBindings = names "bindings" toolsAndDisabledTmux.config;
in
assert !(builtins.elem "agents" (names "popups" tmuxOnly.config));
assert !(builtins.elem "tuicr" (names "popups" tmuxOnly.config));
assert builtins.elem "agents" enabledPopups;
assert builtins.elem "tuicr" enabledPopups;
assert builtins.elem "Agent sidebar" enabledBindings;
assert builtins.elem "Agent sidebar (session)" enabledBindings;
assert lib.hasInfix "Agent sidebar" toolsAndEnabledTmux.config.programs.tmux.extraConfig;
assert lib.hasInfix "tuicr" toolsAndEnabledTmux.config.programs.tmux.extraConfig;
assert builtins.elem pkgs.llm-agents.workmux toolsOnly.config.home.packages;
assert builtins.elem pkgs.llm-agents.tuicr toolsOnly.config.home.packages;
assert !(toolsOnly.options ? dotnix);
assert !(builtins.elem "agents" disabledPopups);
assert !(builtins.elem "tuicr" disabledPopups);
assert !(builtins.elem "Agent sidebar" disabledBindings);
assert !(builtins.elem "Agent sidebar (session)" disabledBindings);
assert !(lib.hasInfix "Agent sidebar" toolsAndDisabledTmux.config.programs.tmux.extraConfig);
assert !(lib.hasInfix "tuicr" toolsAndDisabledTmux.config.programs.tmux.extraConfig);
true
