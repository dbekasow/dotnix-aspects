{ source ? builtins.getFlake (toString ../.) }:
let
  inputs = source.inputs // { dotnix = source; self = source; };
  inherit (inputs.nixpkgs) lib;
  dotnix = source.denful.dotnix;
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  agentPackages = inputs.llm-agents.packages.${system};

  bobAuthor = {
    name = "Bob Fixture";
    email = "bob-tools@example.com";
  };
  bobToolSettings = {
    programs.git.settings.user = bobAuthor;
    programs.rbw.settings.email = bobAuthor.email;
  };
  primaryMailbox = name: address: {
    accounts.email.accounts.${name} = {
      primary = true;
      realName = name;
      inherit address;
    };
  };
  originalMailbox = primaryMailbox "Original" "original@example.com";

  evaluate = { aliceIncludes ? [ ], bobIncludes ? [ ], bobSettings ? bobToolSettings }:
    let
      fixture = {
        imports = [ (inputs.dotnix + "/modules/base") ];
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
                programs.rbw.settings.email = "alice@example.com";
              };
            };
            bob = {
              includes = [ dotnix.home.persistence ] ++ bobIncludes;
              homeManager = {
                home.username = "bob";
                home.homeDirectory = "/home/bob";
                home.stateVersion = "25.11";
              } // bobSettings;
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
  composition = {
    aliceIncludes = [ dotnix.home.terminal-herdr ];
    bobIncludes = with dotnix.home; [ terminal development ];
  };
  composed = evaluate composition;
  bobWith = bobSettings: (evaluate (composition // { inherit bobSettings; })).bob;
  mailOnly = bobWith originalMailbox;
  explicit = evaluate {
    aliceIncludes = with dotnix.home; [ terminal-herdr workmux llm-agents ai-tools repomix ];
    bobIncludes = with dotnix.home; [ terminal workmux ];
  };
  hasPackage = package: home:
    builtins.any (installed: installed.outPath == package.outPath) home.home.packages;
  persisted = home: map (entry: entry.directory) home.home.persistence."/persist".directories;
  assertions = {
    explicitToolIdentitiesDoNotDependOnMail =
      builtins.all
        (home: home.programs.git.settings.user == bobAuthor && home.programs.rbw.settings.email == bobAuthor.email)
        [
          composed.bob
          (bobWith (bobToolSettings // originalMailbox))
          (bobWith (bobToolSettings // primaryMailbox "Replacement" "replacement@example.com"))
        ];
    primaryMailSuppliesToolDefaults =
      mailOnly.programs.git.settings.user == { name = "Original"; email = "original@example.com"; }
      && mailOnly.programs.rbw.settings.email == "original@example.com";
    toolFeaturesDoNotRequireMail =
      let home = bobWith { };
      in home.programs.git.enable && home.programs.rbw.enable
        && !(home.programs.git.settings ? user)
        # Home Manager still needs an explicit rbw email to render its config.
        && !(builtins.tryEval home.programs.rbw.settings.email).success;
    developmentKeepsGeneralTools =
      composed.bob.programs.helix.enable
      && composed.bob.programs.git.enable
      && composed.bob.programs.bacon.enable
      && hasPackage pkgs.just composed.bob;
    developmentAndTerminalShareReviewPopup =
      let
        tmuxConfig = composed.bob.xdg.configFile."tmux/tmux.conf".text;
        reviewLines = builtins.filter (line: lib.hasInfix ''"hunk" r '' line) (lib.splitString "\n" tmuxConfig);
      in
      composed.bob.programs.tmux.enable
      && hasPackage agentPackages.hunk composed.bob
      && lib.hasInfix ''bind -N "TUI popups" o display-menu'' tmuxConfig
      && builtins.length reviewLines == 1
      && lib.hasInfix (builtins.unsafeDiscardStringContext (lib.getExe agentPackages.hunk)) (builtins.head reviewLines);
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
