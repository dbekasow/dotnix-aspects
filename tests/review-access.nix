{ source ? builtins.getFlake (toString ../.) }:
let
  inputs = source.inputs // { dotnix = source; self = source; };
  inherit (inputs.nixpkgs) lib;
  dotnix = source.denful.dotnix;
  system = "x86_64-linux";
  hunk = inputs.llm-agents.packages.${system}.hunk;
  selectedHunk = hunk.overrideAttrs (_: { pname = "hunk-consumer"; });
  selectedOverlay = _: _: { llm-agents.hunk = selectedHunk; };

  fixture = { aliceIncludes ? [ ], bobIncludes ? [ ], overlays ? [ ], perUserPkgs ? false }: {
    imports = [ inputs.dotnix.flakeModules.default ];
    den.hosts.${system}.fixture.users = {
      alice.classes = [ "homeManager" ];
      bob.classes = [ "homeManager" ];
    };
    den.aspects.fixture = {
      nixos = {
        system.stateVersion = "25.11";
        nixpkgs.hostPlatform = system;
        nixpkgs.overlays = overlays;
        home-manager.useGlobalPkgs = !perUserPkgs;
        users.users = {
          alice = { isNormalUser = true; home = "/home/alice"; };
          bob = { isNormalUser = true; home = "/home/bob"; };
        };
      };
      provides = {
        alice = {
          includes = aliceIncludes;
          homeManager = {
            home.username = "alice";
            home.homeDirectory = "/home/alice";
            home.stateVersion = "25.11";
          } // lib.optionalAttrs perUserPkgs { nixpkgs.overlays = [ selectedOverlay ]; };
        };
        bob = {
          includes = bobIncludes;
          homeManager = {
            home.username = "bob";
            home.homeDirectory = "/home/bob";
            home.stateVersion = "25.11";
          } // lib.optionalAttrs perUserPkgs { nixpkgs.overlays = [ selectedOverlay ]; };
        };
      };
    };
  };
  evaluate = selections:
    (inputs.flake-parts.lib.mkFlake { inherit inputs; } (fixture selections)).nixosConfigurations.fixture.config;
  config = evaluate { aliceIncludes = [ dotnix.home.hunk ]; };
  control = evaluate { };
  alice = config.home-manager.users.alice;
  bob = config.home-manager.users.bob;
  development = (evaluate { aliceIncludes = [ dotnix.home.development ]; }).home-manager.users.alice;
  tmux = evaluate {
    aliceIncludes = [ dotnix.home.hunk dotnix.home.tmux ];
    bobIncludes = [ dotnix.home.tmux ];
    perUserPkgs = true;
  };
  tmuxAlice = tmux.home-manager.users.alice;
  tmuxBob = tmux.home-manager.users.bob;
  tmuxConfig = tmuxAlice.xdg.configFile."tmux/tmux.conf".text;
  herdr = evaluate {
    aliceIncludes = [ dotnix.home.hunk dotnix.home.herdr ];
    bobIncludes = [ dotnix.home.herdr ];
    overlays = [ selectedOverlay ];
  };
  herdrAlice = herdr.home-manager.users.alice;
  herdrBob = herdr.home-manager.users.bob;
  herdrCommands = herdrAlice.programs.herdr.settings.keys.command;
  herdrMenu = lib.head (builtins.filter (binding: binding.key == "prefix+o") herdrCommands);
  bobHerdrMenu = lib.head (builtins.filter (binding: binding.key == "prefix+o") herdrBob.programs.herdr.settings.keys.command);

  assertions = {
    standaloneHunkSelection =
      builtins.elem hunk alice.home.packages
      && !(builtins.elem hunk bob.home.packages)
      && alice.programs.fish.shellAbbrs.cr == lib.getExe hunk
      && !(bob.programs.fish.shellAbbrs ? cr)
      && builtins.filter (package: package != hunk) alice.home.packages == bob.home.packages
      && !alice.programs.tmux.enable
      && !alice.programs.herdr.enable
      && config.nixpkgs.overlays == control.nixpkgs.overlays
      && config.nix.settings.substituters == control.nix.settings.substituters
      && config.nix.settings.trusted-public-keys == control.nix.settings.trusted-public-keys;
    developmentSelectsHunk =
      builtins.elem hunk development.home.packages
      && development.programs.fish.shellAbbrs.cr == lib.getExe hunk
      && !(builtins.elem inputs.llm-agents.packages.${system}.tuicr development.home.packages)
      && !(development.xdg.configFile ? "tuicr/config.toml")
      && !(dotnix.home ? tuicr);
    tmuxReviewMenu =
      builtins.elem selectedHunk tmuxAlice.home.packages
      && !(builtins.elem selectedHunk tmuxBob.home.packages)
      && tmuxAlice.programs.fish.shellAbbrs.cr == lib.getExe selectedHunk
      && lib.hasInfix ''bind -N "TUI popups" o display-menu'' tmuxConfig
      && lib.hasInfix ''"hunk" r 'display-popup -EE -w 90% -h 85%'' tmuxConfig
      && lib.hasInfix (builtins.unsafeDiscardStringContext (lib.getExe selectedHunk)) tmuxConfig
      && builtins.length (lib.splitString ''"hunk" r'' tmuxConfig) == 2
      && !(lib.hasInfix "hunk" tmuxBob.xdg.configFile."tmux/tmux.conf".text)
      && !(lib.hasInfix "-T prefix r display-popup" tmuxConfig)
      && lib.all (a: a.assertion) tmuxAlice.assertions
      && lib.all (a: a.assertion) tmuxBob.assertions;
    herdrReviewMenu =
      builtins.elem selectedHunk herdrAlice.home.packages
      && !(builtins.elem selectedHunk herdrBob.home.packages)
      && builtins.length (builtins.filter (binding: binding.key == "prefix+o") herdrCommands) == 1
      && !(builtins.any (binding: binding.key == "prefix+r") herdrCommands)
      && herdrMenu.type == "popup"
      && herdrMenu.width == "90%"
      && herdrMenu.height == "85%"
      && lib.hasInfix "echo 'r → hunk'" herdrMenu.command
      && lib.hasInfix ("r) exec " + builtins.unsafeDiscardStringContext (lib.getExe selectedHunk) + " ;;") herdrMenu.command
      && builtins.length (lib.splitString "r) exec " herdrMenu.command) == 2
      && !(lib.hasInfix "hunk" bobHerdrMenu.command)
      && lib.all (a: a.assertion) herdrAlice.assertions
      && lib.all (a: a.assertion) herdrBob.assertions;
  };
  failed = builtins.attrNames (lib.filterAttrs (_: passed: !passed) assertions);
in
if failed == [ ] then assertions
else throw "Review access fixture failed: ${lib.concatStringsSep ", " failed}"
