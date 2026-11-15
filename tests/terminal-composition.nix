{ source ? builtins.getFlake (toString ../.) }:
let
  inputs = source.inputs // { dotnix = source; self = source; };
  inherit (inputs.nixpkgs) lib;
  dotnix = source.denful.dotnix;
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  agentPackages = inputs.llm-agents.packages.${system};

  evaluate = { aliceIncludes ? [ ], bobIncludes ? [ ] }:
    let
      fixture = {
        imports = [ source.flakeModules.default ];
        den.hosts.${system}.fixture = {
          users.alice.classes = [ "homeManager" ];
          users.bob.classes = [ "homeManager" ];
        };
        den.aspects.fixture = {
          includes = [ dotnix.host.persistence ];
          nixos = {
            system.stateVersion = "25.11";
            nixpkgs.hostPlatform = system;
            home-manager.useGlobalPkgs = true;
            users.users = {
              alice = { isNormalUser = true; home = "/home/alice"; };
              bob = { isNormalUser = true; home = "/home/bob"; };
            };
          };
          provides = {
            alice = {
              includes = [ dotnix.home.persistence ] ++ aliceIncludes;
              homeManager = {
                home.username = "alice";
                home.homeDirectory = "/home/alice";
                home.stateVersion = "25.11";
                accounts.email.accounts.fixture = {
                  primary = true;
                  realName = "Alice Fixture";
                  address = "alice@example.com";
                };
              };
            };
            bob = {
              includes = [ dotnix.home.persistence ] ++ bobIncludes;
              homeManager = {
                home.username = "bob";
                home.homeDirectory = "/home/bob";
                home.stateVersion = "25.11";
                accounts.email.accounts.fixture = {
                  primary = true;
                  realName = "Bob Fixture";
                  address = "bob@example.com";
                };
              };
            };
          };
        };
      };
      flake = inputs.flake-parts.lib.mkFlake { inherit inputs; } fixture;
      config = flake.nixosConfigurations.fixture.config;
    in
    {
      inherit config;
      alice = config.home-manager.users.alice;
      bob = config.home-manager.users.bob;
    };

  control = evaluate { };
  composed = evaluate {
    aliceIncludes = [ dotnix.home.terminal-herdr ];
    bobIncludes = with dotnix.home; [ terminal development ];
  };
  explicit = evaluate {
    aliceIncludes = with dotnix.home; [ terminal-herdr workmux llm-agents ai-tools repomix ];
    bobIncludes = with dotnix.home; [ terminal workmux ];
  };
  hasPackage = package: home:
    builtins.any (installed: installed.outPath == package.outPath) home.home.packages;
  persisted = home: map (entry: entry.directory) home.home.persistence."/persist".directories;
  assertions = {
    developmentKeepsGeneralTools =
      composed.bob.programs.helix.enable
      && composed.bob.programs.git.enable
      && composed.bob.programs.bacon.enable
      && hasPackage pkgs.just composed.bob;
    developmentDoesNotSelectAgentTools =
      !(hasPackage agentPackages.skills composed.bob)
      && !(hasPackage agentPackages.tokscale composed.bob)
      && !(hasPackage pkgs.repomix composed.bob)
      && !(builtins.elem ".pi" (persisted composed.bob));
    agentToolsRemainExplicitlySelectable =
      hasPackage agentPackages.skills explicit.alice
      && hasPackage agentPackages.tokscale explicit.alice
      && hasPackage pkgs.repomix explicit.alice
      && builtins.elem ".pi" (persisted explicit.alice);
    herdrTerminalDoesNotSelectTmuxSeshOrWorkmux =
      composed.alice.programs.herdr.enable
      && !composed.alice.programs.tmux.enable
      && !composed.alice.programs.sesh.enable
      && !(hasPackage agentPackages.workmux composed.alice)
      && !(composed.alice.xdg.configFile ? "workmux/config.yaml");
    ordinaryTerminalKeepsTmuxAndSeshWithoutWorkmux =
      composed.bob.programs.tmux.enable
      && composed.bob.programs.sesh.enable
      && !composed.bob.programs.herdr.enable
      && !(hasPackage agentPackages.workmux composed.bob)
      && !(composed.bob.xdg.configFile ? "workmux/config.yaml");
    explicitWorkmuxSurvivesHerdrExclusions =
      explicit.alice.programs.herdr.enable
      && !explicit.alice.programs.tmux.enable
      && !explicit.alice.programs.sesh.enable
      && hasPackage agentPackages.workmux explicit.alice
      && explicit.alice.xdg.configFile."workmux/config.yaml".enable
      && explicit.alice.programs.fish.shellAbbrs.wx == "workmux"
      && builtins.all (assertion: assertion.assertion) explicit.alice.assertions;
    workmuxTmuxBindingsStayConditional =
      !(lib.hasInfix "Agent sidebar" explicit.alice.programs.tmux.extraConfig)
      && lib.hasInfix "Agent sidebar" explicit.bob.programs.tmux.extraConfig;
    homeSelectionsDoNotAlterAccounts =
      builtins.attrNames composed.config.users.users == builtins.attrNames control.config.users.users
      && builtins.all
        (name:
          toString composed.config.users.users.${name}.shell == toString control.config.users.users.${name}.shell
          && composed.config.users.users.${name}.extraGroups == control.config.users.users.${name}.extraGroups)
        [ "alice" "bob" ];
  };
  failed = builtins.attrNames (lib.filterAttrs (_: passed: !passed) assertions);
in
if failed == [ ] then assertions
else throw "Terminal composition fixture failed: ${lib.concatStringsSep ", " failed}"
