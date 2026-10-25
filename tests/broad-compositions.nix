let
  source = builtins.getFlake (toString ../.);
  inputs = source.inputs // { dotnix = source; self = source; };
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;
  dotnix = source.denful.dotnix;
  system = "x86_64-linux";
  bash = (import nixpkgs { inherit system; }).bashInteractive;
  # Markers prove resource presence only; contents are not usable keys, certificates, or images. This suite evaluates gates only and never builds or activates these fake resource configs.
  resourceTree = (import nixpkgs { inherit system; }).runCommand "consumer-resources" { } ''
    mkdir -p $out/modules/hosts/fixture/secrets $out/modules/hosts/fixture/certificates $out/modules/users/fixture/secrets $out/modules/users/fixture/assets $out/password-vault
    printf 'public fixture marker\\n' > $out/modules/hosts/fixture/secrets/ssh_host_ed25519_key.pub
    printf 'public fixture marker\\n' > $out/password-vault/ssh_host_ed25519_key.pub
    printf 'public fixture marker\\n' > $out/modules/users/fixture/secrets/home-key.pub
    printf 'certificate presence marker\\n' > $out/modules/hosts/fixture/certificates/fixture.crt
    printf 'ignored presence marker\\n' > $out/modules/hosts/fixture/certificates/ignored.txt
    printf 'wallpaper presence marker\\n' > $out/modules/users/fixture/assets/wallpaper.png
  '';
  populatedSelf = source // { outPath = resourceTree; };

  bootstrap = {
    boot.loader.grub.enable = true;
    boot.loader.grub.device = "nodev";
    fileSystems."/" = {
      device = "/dev/vda1";
      fsType = lib.mkDefault "ext4";
    };
    system.stateVersion = "25.11";
    nixpkgs.hostPlatform = system;
  };

  evaluate =
    { hostIncludes ? [ ]
    , userIncludes ? [ ]
    , hostModule ? { }
    , userModule ? { }
    , accountModule ? { }
    , userClasses ? [ "homeManager" ]
    , withUser ? true
    , extraUsers ? { }
    , disablePersistenceRouting ? false
    , otherHost ? false
    , consumerInputs ? inputs
    , consumerSelf ? source
    , overlays ? [ inputs.nur.overlays.default inputs.llm-agents.overlays.shared-nixpkgs inputs.niri.overlays.niri ]
    ,
    }:
    let
      instantiate = args:
        inputs.nixpkgs.lib.nixosSystem (args // {
          pkgs = import inputs.nixpkgs {
            inherit system;
            inherit overlays;
          };
        });
      fixture = {
        imports = [ source.flakeModules.default ];
        den.hosts.${system} = {
          fixture = {
            users = (lib.optionalAttrs withUser {
              fixture.classes = userClasses;
            }) // extraUsers;
            inherit instantiate;
          };
        } // lib.optionalAttrs otherHost {
          unselected = { inherit instantiate; };
        };
        den.aspects = {
          fixture = {
            includes = hostIncludes;
            excludes = lib.optionals disablePersistenceRouting dotnix.host.persistence.includes;
            nixos = bootstrap // hostModule;
            provides = {
              fixture = {
                includes = userIncludes;
                user = accountModule;
                homeManager = {
                  home.username = "fixture";
                  home.homeDirectory = "/home/fixture";
                  home.stateVersion = "25.11";
                } // userModule;
              };
              unrelated.homeManager = {
                home.username = "unrelated";
                home.homeDirectory = "/home/unrelated";
                home.stateVersion = "25.11";
              };
            };
          };
        } // lib.optionalAttrs otherHost {
          unselected.nixos = bootstrap;
        };
      };
      flakeInputs = consumerInputs // { self = consumerSelf; };
      flake = inputs.flake-parts.lib.mkFlake { inputs = flakeInputs; } fixture;
    in
    if otherHost then {
      selected = flake.nixosConfigurations.fixture.config;
      unselected = flake.nixosConfigurations.unselected.config;
    } else
      flake.nixosConfigurations.fixture.config;

  populatedResources = evaluate {
    consumerSelf = populatedSelf;
    hostIncludes = with dotnix; [ age age-rekey yubikey-pam desktop-shell dms stylix certificates ];
    userClasses = [ "user" "homeManager" ];
    userIncludes = with dotnix; [ account.passwords age-rekey stylix ];
    hostModule = {
      users.users.fixture.home = "/home/fixture";
      programs.dank-material-shell.lockscreen.securityKey = {
        enable = true;
        moduleArgs = [ "cue" "authfile=/run/fixture/u2f-authfile" ];
      };
    };
  };
  emptyResources = evaluate {
    hostIncludes = with dotnix; [ age age-rekey yubikey-pam desktop-shell dms stylix certificates ];
    userIncludes = with dotnix; [ age-rekey stylix ];
    hostModule.users.users.fixture.home = "/home/fixture";
  };
  passwordsWithoutVault = evaluate {
    hostIncludes = with dotnix; [ age age-rekey ];
    userClasses = [ "user" ];
    userIncludes = [ dotnix.account.passwords ];
  };
  passwordsWithOverriddenSecretsDir = evaluate {
    consumerSelf = source;
    hostIncludes = with dotnix; [ age age-rekey ];
    userClasses = [ "user" ];
    userIncludes = [ dotnix.account.passwords ];
    hostModule.age.rekey.secretsDir = lib.mkForce "${resourceTree}/password-vault";
  };
  coreOnly = evaluate {
    hostIncludes = [ dotnix.core ];
    userClasses = [ "user" ];
  };
  accountOnly = evaluate {
    userClasses = [ "user" ];
    userIncludes = [ dotnix.account.users ];
    extraUsers.unrelated.classes = [ "user" ];
  };
  accountWithHomeManager = evaluate {
    userClasses = [ "user" "homeManager" ];
    userIncludes = [ dotnix.account.users ];
    accountModule.isNormalUser = false;
  };
  workstation = evaluate {
    hostIncludes = with dotnix; [
      core
      base
      host.boot-systemd
      host.performance
      host.bluetooth
      host.disko
      host.persistence
      host.btrfs-root-reset
      host.geolocation
      host.network
      host.network-wifi
      host.pipewire
      host.power
      age
      age-rekey
      yubikey
      yubikey-pam
      desktop
      development
    ];
    userIncludes = with dotnix; [ desktop development noctalia ];
    hostModule = { disko.devices.disk.main.device = "/dev/vda"; };
  };
  fishHomeOnly = evaluate {
    userClasses = [ "user" "homeManager" ];
    userIncludes = [ dotnix.account.users dotnix.home.fish ];
  };
  nushellHomeOnly = evaluate {
    userClasses = [ "user" "homeManager" ];
    userIncludes = [ dotnix.account.users dotnix.home.nushell ];
  };
  fishHostOnly = evaluate {
    hostIncludes = [ dotnix.host.fish ];
    userClasses = [ "user" "homeManager" ];
    userIncludes = [ dotnix.account.users ];
    extraUsers.unrelated.classes = [ "user" ];
    hostModule.users.users.unrelated.shell = bash;
  };
  nushellHostOnly = evaluate {
    hostIncludes = [ dotnix.host.nushell ];
    userClasses = [ "user" "homeManager" ];
    userIncludes = [ dotnix.account.users ];
    extraUsers.unrelated.classes = [ "user" ];
    hostModule.users.users.unrelated.shell = bash;
  };
  fishAccountOnly = evaluate {
    userClasses = [ "user" ];
    userIncludes = [ dotnix.account.users dotnix.account.fish ];
    extraUsers.unrelated.classes = [ "user" ];
    hostModule.users.users.unrelated.shell = bash;
  };
  nushellAccountOnly = evaluate {
    userClasses = [ "user" ];
    userIncludes = [ dotnix.account.users dotnix.account.nushell ];
    extraUsers.unrelated.classes = [ "user" ];
    hostModule.users.users.unrelated.shell = bash;
  };
  hostShellWithOneAccount = evaluate {
    hostIncludes = [ dotnix.host.fish dotnix.host.nushell ];
    userClasses = [ "user" ];
    userIncludes = [ dotnix.account.users dotnix.account.fish ];
    extraUsers.unrelated.classes = [ "user" ];
    hostModule.users.users.unrelated.shell = bash;
  };
  shellHomeProfileOnly = evaluate {
    userClasses = [ "user" "homeManager" ];
    userIncludes = [ dotnix.account.users dotnix.term-shell ];
  };
  terminalShellAndUx = evaluate {
    userClasses = [ "user" "homeManager" ];
    userIncludes = [ dotnix.account.users dotnix.term-shell dotnix.term-ux ];
  };
  shellUxOnly = evaluate {
    userClasses = [ "user" "homeManager" ];
    userIncludes = [ dotnix.account.users dotnix.atuin dotnix.carapace dotnix.starship dotnix.fzf dotnix.skim dotnix.zoxide ];
    userModule.programs.starship.settings.add_newline = lib.mkForce true;
  };
  shellNativeOverrides = evaluate {
    hostIncludes = [ dotnix.host.fish ];
    userClasses = [ "user" "homeManager" ];
    userIncludes = [ dotnix.account.users dotnix.home.fish dotnix.account.fish ];
    hostModule.programs.fish.enable = false;
    userModule.programs.fish.enable = false;
    accountModule.shell = bash;
  };
  developmentHomeBaseline = evaluate { };
  developmentHome = evaluate {
    userIncludes = [ dotnix.development ];
  };
  standaloneJust = evaluate {
    userIncludes = [ dotnix.just ];
  };
  homeGitOnly = evaluate {
    userIncludes = [ dotnix.git ];
  };
  hostGitOnly = evaluate {
    hostIncludes = lib.optional (builtins.hasAttr "git" dotnix.host) dotnix.host.git;
    withUser = false;
  };
  adapterOnly = evaluate {
    withUser = false;
    consumerInputs = (lib.removeAttrs inputs [ "dotnix" ]) // { library = source; };
  };
  socketOnly = evaluate {
    hostIncludes = with dotnix; [ desktop-shell ];
    withUser = false;
  };
  dmsSelected = evaluate {
    hostIncludes = with dotnix; [ desktop-shell dms dms-greeter ];
    userIncludes = with dotnix; [ dms ];
    hostModule = {
      users.users.fixture.home = "/home/fixture";
    };
  };
  noctaliaSelected = evaluate {
    hostIncludes = with dotnix; [ desktop-shell noctalia-greeter ];
    withUser = false;
  };
  home = evaluate {
    hostIncludes = with dotnix; [ host.persistence ];
    userIncludes = with dotnix; [ dotnix.home.persistence stylix desktop noctalia ];
    withUser = true;
  };
  homeWithNiri = evaluate {
    hostIncludes = with dotnix; [ host.persistence ];
    userIncludes = with dotnix; [ dotnix.home.persistence desktop-shell noctalia ];
    withUser = true;
  };
  persistenceOnly = evaluate {
    hostIncludes = [ dotnix.host.persistence ];
    withUser = false;
    otherHost = true;
  };
  rootResetOnly = evaluate {
    hostIncludes = [ dotnix.host.btrfs-root-reset ];
    withUser = false;
    otherHost = true;
  };
  pipewireUserOnly = evaluate {
    hostIncludes = with dotnix; [ host.persistence host.home-manager ];
    userIncludes = [ dotnix.home.persistence dotnix.home.pipewire ];
    hostModule.users.users.fixture.home = "/home/fixture";
    extraUsers.unrelated.classes = [ "homeManager" ];
    consumerInputs = lib.removeAttrs inputs [ "impermanence" ];
  };
  pipewireSelected = evaluate {
    hostIncludes = with dotnix; [ host.persistence host.home-manager host.pipewire host.bluetooth ];
    userIncludes = [ dotnix.home.persistence ];
    otherHost = true;
    hostModule = {
      users.users.fixture.home = "/home/fixture";
      services.pipewire.pulse.enable = lib.mkForce false;
    };
    extraUsers.unrelated.classes = [ "homeManager" ];
  };
  pipewireHostOnly = evaluate {
    hostIncludes = [ dotnix.host.pipewire ];
    withUser = false;
  };
  hostFoundation = evaluate {
    hostIncludes = with dotnix.host; [
      boot
      boot-systemd
      disko
      network
      network-wifi
      bluetooth
      power
      performance
      geolocation
      journald
      locale
      security
      system-packages
      nix
      nur
      nh
      nix-ld
    ];
    withUser = false;
    otherHost = true;
    hostModule = {
      boot.loader.timeout = 17;
      disko.devices.disk.main.device = "/dev/vda";
      fileSystems."/".device = lib.mkForce "/dev/mapper/cryptroot";
    };
  };
  hostNixDefault = evaluate {
    hostIncludes = [ dotnix.host.nix ];
    withUser = false;
  };
  hostNixCommunityCache = evaluate {
    hostIncludes = [ dotnix.host.nix dotnix.host.nix-community-cache ];
    withUser = false;
  };
  nixCacheOverride = evaluate {
    hostIncludes = [ dotnix.host.nix ];
    withUser = false;
    hostModule.nix.settings = {
      substituters = [ "https://example.invalid" ];
      trusted-public-keys = [ ];
    };
  };
  pipewireWithoutPersistenceRouting = evaluate {
    hostIncludes = with dotnix; [ host.persistence host.home-manager host.pipewire host.bluetooth ];
    userIncludes = [ dotnix.home.persistence dotnix.home.pipewire ];
    disablePersistenceRouting = true;
  };
  broadNativeCompositions = evaluate {
    userIncludes = with dotnix; [ git rbw maildir ];
    hostModule.users.users.fixture.home = "/home/fixture";
    userModule = {
      programs.git.settings.user = {
        name = "Fixture User";
        email = "git@example.invalid";
      };
      programs.rbw.settings.email = "vault@example.invalid";
      programs.notmuch.settings.user = {
        name = "Fixture User";
        primary_email = "mail@example.invalid";
      };
      accounts.email.accounts = {
        alpha = {
          address = "mail@example.invalid";
          primary = true;
          realName = "Fixture User";
          notmuch.enable = true;
        };
        beta = {
          address = "other@example.invalid";
          realName = "Fixture User";
          notmuch.enable = true;
        };
      };
    };
  };
  popupTmuxOnly = evaluate {
    userIncludes = [ dotnix.tmux ];
    hostModule.users.users.fixture.home = "/home/fixture";
  };
  popupEnabled = evaluate {
    userIncludes = with dotnix; [ tmux herdr workmux ];
    hostModule.users.users.fixture.home = "/home/fixture";
    userModule.programs.k9s.enable = true;
  };
  popupDisabled = evaluate {
    userIncludes = with dotnix; [ tmux herdr workmux ];
    hostModule.users.users.fixture.home = "/home/fixture";
    userModule.programs.k9s.enable = false;
  };
  popupMissingBackendBinding = evaluate {
    userIncludes = with dotnix; [
      tmux
      herdr
      {
        popup-launcher = [
          {
            name = "tmux-only";
            command = "/bin/true";
            width = "20%";
            height = "20%";
            keys.tmux = "z";
          }
          {
            name = "herdr-only";
            command = "/bin/true";
            width = "20%";
            height = "20%";
            keys.herdr = "prefix+alt+q";
          }
        ];
      }
    ];
    hostModule.users.users.fixture.home = "/home/fixture";
  };
  standaloneHerdr =
    let
      fixture = {
        imports = [ source.flakeModules.default ];
        den.homes.${system}.fixture.pkgs = import nixpkgs { inherit system; };
        den.aspects.fixture.includes = [ dotnix.herdr ];
        den.aspects.fixture.homeManager = { specialArgs, ... }: {
          home.username = "fixture";
          home.homeDirectory = "/home/fixture";
          home.stateVersion = "25.11";
          programs.herdr.settings.keys.prefix = "ctrl+a";
          assertions = [
            {
              assertion = !(builtins.hasAttr "osConfig" specialArgs);
              message = "Standalone Herdr must not receive osConfig";
            }
          ];
        };
      };
      flake = inputs.flake-parts.lib.mkFlake { inherit inputs; } fixture;
    in
    flake.homeConfigurations.fixture.config;
  agentToolsWithoutGlobalOverlay = evaluate {
    overlays = [ ];
    hostIncludes = [ dotnix.host.home-manager ];
    userIncludes = with dotnix; [ ai-tools workmux repomix tuicr handy ];
    hostModule.users.users.fixture.home = "/home/fixture";
  };
  handyServiceSelected = evaluate {
    overlays = [ ];
    hostIncludes = [ dotnix.host.home-manager ];
    userIncludes = [ dotnix.handy-service ];
    hostModule.users.users.fixture.home = "/home/fixture";
  };
  checks = {
    popupTmuxWorksWithoutWorkmux =
      let tmux = popupTmuxOnly.home-manager.users.fixture.programs.tmux;
      in tmux.enable
        && lib.hasInfix ''bind -N "TUI popups" o display-menu'' tmux.extraConfig
        && !(lib.hasInfix ''bind -N "agents" -T prefix w display-menu'' tmux.extraConfig);
    popupQuirkEnabledForBothBackends =
      lib.any (entry: entry.description == "k9s") popupEnabled.home-manager.users.fixture.programs.herdr.settings.keys.command
      && lib.hasInfix "k9s" popupEnabled.home-manager.users.fixture.programs.tmux.extraConfig;
    popupQuirkExcludesDisabledLauncher =
      !(lib.any (entry: entry.description == "k9s") popupDisabled.home-manager.users.fixture.programs.herdr.settings.keys.command)
      && !(lib.hasInfix "k9s" popupDisabled.home-manager.users.fixture.programs.tmux.extraConfig);
    popupMissingBackendBindingIsOmitted =
      let
        tmux = popupMissingBackendBinding.home-manager.users.fixture.programs.tmux.extraConfig;
        herdr = popupMissingBackendBinding.home-manager.users.fixture.programs.herdr.settings.keys.command;
      in
      lib.hasInfix "tmux-only" tmux
      && !(lib.hasInfix "herdr-only" tmux)
      && lib.any (entry: entry.description == "herdr-only") herdr
      && !(lib.any (entry: entry.description == "tmux-only") herdr);
    popupMenuCoexistsWithWorkmux =
      let
        enabled = popupEnabled.home-manager.users.fixture.programs.tmux.extraConfig;
        disabled = popupDisabled.home-manager.users.fixture.programs.tmux.extraConfig;
      in
      lib.hasInfix ''bind -N "TUI popups" o display-menu'' enabled
      && lib.hasInfix ''bind -N "agents" -T prefix w display-menu'' enabled
      && lib.hasInfix ''bind -N "agents" -T prefix w display-menu'' disabled;
    popupQuirkDoesNotLeakToUnrelatedUser =
      !(popupEnabled.home-manager.users.unrelated.programs.herdr.settings.keys.command or [ ] != [ ])
      && !(lib.hasInfix "k9s" (popupEnabled.home-manager.users.unrelated.programs.tmux.extraConfig or ""));
    standaloneHerdrWorksWithoutHostOverlay =
      standaloneHerdr.programs.herdr.settings.keys.prefix == "ctrl+a"
      && !(lib.any (entry: entry.description == "bluetui") standaloneHerdr.programs.herdr.settings.keys.command);
    agentToolsResolveWithoutGlobalOverlay =
      let
        systemConfig = agentToolsWithoutGlobalOverlay;
        home = systemConfig.home-manager.users.fixture;
        packageNames = map lib.getName home.home.packages;
      in
      builtins.length systemConfig.nixpkgs.overlays == 0
      && !(systemConfig.nixpkgs.config.allowUnfree or false)
      && lib.elem "beads" packageNames
      && lib.elem "workmux" packageNames
      && lib.elem "repomix" packageNames
      && lib.elem "tuicr" packageNames
      && lib.elem "handy" packageNames
      && !(builtins.hasAttr "handy" home.systemd.user.services);
    handyServiceRequiresExplicitSelection =
      handyServiceSelected.home-manager.users.fixture.systemd.user.services.handy.Install.WantedBy
      == [ "graphical-session.target" ];
    populatedResourcesUseConsumerTree =
      populatedSelf.inputs == source.inputs
      && toString populatedSelf.outPath == toString resourceTree;
    populatedResourceGates =
      populatedResources.age.rekey.secretsDir == "${resourceTree}/modules/hosts/fixture/secrets"
      && populatedResources.age.rekey.hostPubkey != ""
      && populatedResources.home-manager.users.fixture.age.rekey.secretsDir == "${resourceTree}/modules/users/fixture/secrets"
      && populatedResources.home-manager.users.fixture.age.rekey.hostPubkey != ""
      && populatedResources.age.secrets ? "home-identity-fixture"
      && populatedResources.age.secrets ? "password-fixture"
      && populatedResources.users.users.fixture.hashedPasswordFile == populatedResources.age.secrets."password-fixture-hashed".path
      && !populatedResources.users.mutableUsers
      && populatedResources.security.pam.u2f.enable
      && populatedResources.security.pam.u2f.settings.authfile == populatedResources.age.secrets.u2f.path
      && populatedResources.programs.dank-material-shell.lockscreen.securityKey.enable
      && populatedResources.programs.dank-material-shell.lockscreen.securityKey.moduleArgs
      == [ "cue" "authfile=/run/fixture/u2f-authfile" ];
    populatedWallpaperPath = toString populatedResources.home-manager.users.fixture.stylix.image == "${resourceTree}/modules/users/fixture/assets/wallpaper.png";
    populatedCertificateFiles = lib.unique populatedResources.security.pki.certificateFiles == [ "${resourceTree}/modules/hosts/fixture/certificates/fixture.crt" ];
    emptyResourceGates =
      emptyResources.age.secrets == { }
      && emptyResources.users.users.fixture.hashedPasswordFile == null
      && emptyResources.users.mutableUsers
      && !(emptyResources.age.secrets ? "password-fixture")
      && !(emptyResources.security.pam.u2f.enable or false)
      && !(emptyResources.programs.dank-material-shell.lockscreen.securityKey.enable or false)
      && emptyResources.age.rekey.hostPubkey == ""
      && emptyResources.home-manager.users.fixture.age.rekey.hostPubkey == ""
      && emptyResources.security.pki.certificateFiles == [ ];
    accountSelectionIsExplicitAndHomeIndependent =
      accountOnly.users.users.fixture.isNormalUser
      && !(accountOnly.users.users.unrelated.isNormalUser or false)
      && !(builtins.hasAttr "home-manager" accountOnly)
      && accountOnly.users.mutableUsers
      && accountOnly.users.users.fixture.hashedPasswordFile == null
      && !(accountOnly ? age)
      && !(lib.elem "wheel" accountOnly.users.users.fixture.extraGroups)
      && accountOnly.users.defaultUserShell != accountOnly.programs.fish.package
      && !(accountOnly.programs.fish.enable or false);
    accountSelectionSupportsHomeManagerAndOverrides =
      accountWithHomeManager.users.users.fixture.isNormalUser == false
      && accountWithHomeManager.home-manager.users.fixture.home.username == "fixture";
    selectedPasswordRecipeStaysMutableWithoutVault =
      passwordsWithoutVault.users.mutableUsers
      && passwordsWithoutVault.users.users.fixture.hashedPasswordFile == null
      && !(passwordsWithoutVault.age.secrets ? "password-fixture")
      && !(passwordsWithoutVault.age.secrets ? "password-fixture-hashed");
    passwordRecipeUsesNativeSecretsDirOverride =
      passwordsWithOverriddenSecretsDir.age.rekey.secretsDir == "${resourceTree}/password-vault"
      && passwordsWithOverriddenSecretsDir.age.secrets ? "password-fixture"
      && passwordsWithOverriddenSecretsDir.users.users.fixture.hashedPasswordFile == passwordsWithOverriddenSecretsDir.age.secrets."password-fixture-hashed".path
      && !passwordsWithOverriddenSecretsDir.users.mutableUsers;
    coreDoesNotSelectPasswordRecipe =
      coreOnly.users.mutableUsers
      && coreOnly.users.users.fixture.hashedPasswordFile == null
      && !(coreOnly.age.secrets ? "password-fixture")
      && !(coreOnly.age.secrets ? "password-fixture-hashed");
    workstationHasSelectedRootAndBootloader =
      workstation.fileSystems."/".fsType == "btrfs" && workstation.boot.loader.systemd-boot.enable;
    workstationHasCoreSystemDesktopDevelopment =
      workstation.programs.fish.enable
      && workstation.zramSwap.enable
      && workstation.programs.niri.enable
      && !(workstation.virtualisation.docker.enable or false)
      && !(workstation.programs.nix-ld.enable or false)
      && workstation.home-manager.users.fixture.programs.helix.enable;
    shellHomeSelectionIsIndependent =
      fishHomeOnly.home-manager.users.fixture.programs.fish.enable
      && !(fishHomeOnly.programs.fish.enable or false)
      && (fishHomeOnly.users.users.fixture.shell or null) != fishHomeOnly.programs.fish.package
      && fishHomeOnly.users.users.fixture.shell != fishHomeOnly.programs.nushell.package
      && nushellHomeOnly.home-manager.users.fixture.programs.nushell.enable
      && !(nushellHomeOnly.programs.nushell.enable or false)
      && (nushellHomeOnly.users.users.fixture.shell or null) != nushellHomeOnly.programs.nushell.package
      && nushellHomeOnly.users.users.fixture.shell != nushellHomeOnly.programs.fish.package;
    shellHostSelectionIsIndependent =
      fishHostOnly.programs.fish.enable
      && !(fishHostOnly.home-manager.users.fixture.programs.fish.enable or false)
      && (fishHostOnly.users.users.fixture.shell or null) != fishHostOnly.programs.fish.package
      && fishHostOnly.users.users.unrelated.shell == bash
      && nushellHostOnly.programs.nushell.enable
      && !(nushellHostOnly.home-manager.users.fixture.programs.nushell.enable or false)
      && (nushellHostOnly.users.users.fixture.shell or null) != nushellHostOnly.programs.nushell.package
      && nushellHostOnly.users.users.unrelated.shell == bash;
    accountShellSelectionIsExplicitAndTargeted =
      fishAccountOnly.users.users.fixture.shell == fishAccountOnly.programs.fish.package
      && fishAccountOnly.users.users.unrelated.shell == bash
      && !(fishAccountOnly.home-manager.users.fixture.programs.fish.enable or false)
      && !(fishAccountOnly.programs.fish.enable or false)
      && !(fishAccountOnly ? age)
      && nushellAccountOnly.users.users.fixture.shell == nushellAccountOnly.programs.nushell.package
      && nushellAccountOnly.users.users.unrelated.shell == bash
      && !(nushellAccountOnly.home-manager.users.fixture.programs.nushell.enable or false)
      && !(nushellAccountOnly.programs.nushell.enable or false)
      && !(nushellAccountOnly ? age)
      && hostShellWithOneAccount.programs.fish.enable
      && hostShellWithOneAccount.programs.nushell.enable
      && hostShellWithOneAccount.users.users.fixture.shell == hostShellWithOneAccount.programs.fish.package
      && hostShellWithOneAccount.users.users.unrelated.shell == bash;
    shellHomeProfileAndUxRemainIndependent =
      shellHomeProfileOnly.home-manager.users.fixture.programs.fish.enable
      && shellHomeProfileOnly.home-manager.users.fixture.programs.nushell.enable
      && !(shellHomeProfileOnly.home-manager.users.fixture.programs.atuin.enable or false)
      && !(shellHomeProfileOnly.home-manager.users.fixture.programs.carapace.enable or false)
      && !(shellHomeProfileOnly.home-manager.users.fixture.programs.starship.enable or false)
      && !(shellHomeProfileOnly.home-manager.users.fixture.programs.fzf.enable or false)
      && !(shellHomeProfileOnly.home-manager.users.fixture.programs.skim.enable or false)
      && !(shellHomeProfileOnly.home-manager.users.fixture.programs.zoxide.enable or false)
      && !(shellHomeProfileOnly.home-manager.users.fixture.programs.tmux.enable or false)
      && !(shellHomeProfileOnly.home-manager.users.fixture.programs.herdr.enable or false)
      && !(shellHomeProfileOnly ? age)
      && !(shellHomeProfileOnly.home-manager.users.fixture ? age)
      && terminalShellAndUx.home-manager.users.fixture.programs.fish.enable
      && terminalShellAndUx.home-manager.users.fixture.programs.nushell.enable
      && terminalShellAndUx.home-manager.users.fixture.programs.atuin.enable
      && terminalShellAndUx.home-manager.users.fixture.programs.carapace.enable
      && terminalShellAndUx.home-manager.users.fixture.programs.starship.enable
      && terminalShellAndUx.home-manager.users.fixture.programs.fzf.enable
      && terminalShellAndUx.home-manager.users.fixture.programs.skim.enable
      && terminalShellAndUx.home-manager.users.fixture.programs.zoxide.enable
      && shellUxOnly.home-manager.users.fixture.programs.atuin.enable
      && shellUxOnly.home-manager.users.fixture.programs.carapace.enable
      && shellUxOnly.home-manager.users.fixture.programs.starship.enable
      && shellUxOnly.home-manager.users.fixture.programs.fzf.enable
      && shellUxOnly.home-manager.users.fixture.programs.skim.enable
      && shellUxOnly.home-manager.users.fixture.programs.zoxide.enable
      && shellUxOnly.home-manager.users.fixture.programs.starship.settings.add_newline
      && !(shellUxOnly.home-manager.users.fixture.programs.fish.enable or false)
      && !(shellUxOnly.home-manager.users.fixture.programs.nushell.enable or false);
    shellNativeDefaultsRemainOverridable =
      !(shellNativeOverrides.programs.fish.enable or false)
      && !(shellNativeOverrides.home-manager.users.fixture.programs.fish.enable or false)
      && shellNativeOverrides.users.users.fixture.shell == bash;
    developmentHomeKeepsHostPrerequisitesExplicit =
      developmentHome.home-manager.users.fixture.programs.helix.enable
      && !(developmentHome.virtualisation.docker.enable or false)
      && !(developmentHome.programs.nix-ld.enable or false)
      && (developmentHome.nix.settings.substituters or [ ]) == (adapterOnly.nix.settings.substituters or [ ])
      && (developmentHome.nix.settings.extra-substituters or [ ]) == (adapterOnly.nix.settings.extra-substituters or [ ])
      && (developmentHome.nix.settings.trusted-public-keys or [ ]) == (adapterOnly.nix.settings.trusted-public-keys or [ ])
      && (developmentHome.nix.settings.extra-trusted-public-keys or [ ]) == (adapterOnly.nix.settings.extra-trusted-public-keys or [ ])
      && map (package: package.drvPath) developmentHome.environment.systemPackages
      == map (package: package.drvPath) developmentHomeBaseline.environment.systemPackages
      && builtins.attrNames developmentHome.systemd.services
      == builtins.attrNames developmentHomeBaseline.systemd.services;
    standaloneDevelopmentToolNeedsNoProfile =
      lib.any (package: package.pname == "just") standaloneJust.home-manager.users.fixture.home.packages
      && !(standaloneJust.virtualisation.docker.enable or false)
      && !(standaloneJust.programs.nix-ld.enable or false);
    homeGitSelectionDoesNotEnableHostGit = !(homeGitOnly.programs.git.enable or false);
    hostGitRemainsExplicitlySelectable =
      builtins.hasAttr "git" dotnix.host
      && hostGitOnly.programs.git.enable
      && hostGitOnly.programs.git.lfs.enable;
    socketDoesNotSelectShellOrGreeter =
      !(socketOnly.programs.dank-material-shell.enable or false)
      && !(socketOnly.programs.dms-greeter.enable or false)
      && !(socketOnly.services.displayManager.noctalia-greeter.enable or false);
    dmsShellAndGreeterExplicitlySelected =
      dmsSelected.programs.dank-material-shell.enable
      && dmsSelected.programs.dms-greeter.enable
      && !dmsSelected.programs.dank-material-shell.systemd.enable
      && !(dmsSelected.programs.dank-material-shell.lockscreen.securityKey.enable or false);
    noctaliaGreeterExplicitlySelected =
      noctaliaSelected.services.displayManager.noctalia-greeter.enable;
    noctaliaHomeShellExplicitlySelected = home.home-manager.users.fixture.programs.noctalia.enable;
    noctaliaNiriContextHasBinds =
      homeWithNiri.home-manager.users.fixture.programs.noctalia.enable
      && builtins.hasAttr "Mod+Space" homeWithNiri.home-manager.users.fixture.programs.niri.settings.binds;
    developmentOptional = !socketOnly.programs.nix-ld.enable;
    selectedSystemPersistence =
      lib.any (directory: directory.directory == "/var/lib/bluetooth") workstation.environment.persistence."/persist".directories
      && !(lib.any (directory: directory.directory == "/var/lib/dms-greeter") workstation.environment.persistence."/persist".directories);
    selectedPersistenceWithoutHomeManagerIsGeneric =
      persistenceOnly.selected.environment.persistence."/persist".hideMounts
      && persistenceOnly.selected.fileSystems."/".fsType == "ext4"
      && !(persistenceOnly.selected.boot.initrd.systemd.services ? rollback-root)
      && !(persistenceOnly.selected.boot.initrd.supportedFilesystems.btrfs or false)
      && !(persistenceOnly.selected ? disko)
      && !(builtins.hasAttr "home-manager" persistenceOnly.selected)
      && !(persistenceOnly.unselected.environment ? persistence);
    selectedRootResetIsIndependent =
      rootResetOnly.selected.boot.initrd.systemd.services ? rollback-root
      && !(rootResetOnly.selected.environment ? persistence)
      && !(rootResetOnly.selected ? disko)
      && !(builtins.hasAttr "home-manager" rootResetOnly.selected)
      && !(rootResetOnly.unselected.boot.initrd.systemd.services ? rollback-root);
    persistenceNeedsSelection = !(socketOnly.environment ? persistence);
    selectedHomePersistence =
      lib.any (directory: directory.directory == ".cache/mesa_shader_cache") homeWithNiri.home-manager.users.fixture.home.persistence."/persist".directories
      && !(lib.any (directory: directory.directory == ".mozilla") homeWithNiri.home-manager.users.fixture.home.persistence."/persist".directories)
      && lib.any (directory: directory.directory == ".mozilla") home.home-manager.users.fixture.home.persistence."/persist".directories;
    adapterRegistrationIsInert =
      !(adapterOnly.services.pipewire.enable or false)
      && !(adapterOnly.programs.fish.enable or false)
      && !(builtins.hasAttr "home-manager" adapterOnly)
      && !(adapterOnly.environment ? persistence)
      && !(adapterOnly.boot.initrd.systemd.services ? rollback-root)
      && !(adapterOnly.boot.initrd.supportedFilesystems.btrfs or false);
    pipewireUserOnlySelectionDoesNotEnableHost = !(pipewireUserOnly.services.pipewire.enable or false);
    unselectedHostHasNoPipewire = !(pipewireSelected.unselected.services.pipewire.enable or false);
    pipewireHostSelectionWorksWithoutHomeManager =
      pipewireHostOnly.services.pipewire.enable
      && !(builtins.hasAttr "home-manager" pipewireHostOnly)
      && !(pipewireHostOnly.environment ? persistence);
    hostCapabilitiesAreSelectableWithoutHomeManager =
      let
        inherit (hostFoundation) selected;
        inherit (hostFoundation) unselected;
      in
      selected.boot.loader.timeout == 17
      && selected.boot.loader.systemd-boot.enable
      && selected.disko.devices.disk.main.type == "disk"
      && selected.networking.networkmanager.enable
      && selected.hardware.bluetooth.enable
      && selected.zramSwap.enable
      && selected.location.provider == "geoclue2"
      && selected.services.journald.settings.Journal.Storage == "persistent"
      && selected.time.timeZone == "Europe/Berlin"
      && selected.security.polkit.enable
      && !(lib.any (package: builtins.elem (package.pname or "") [ "herdr" "helix" ]) selected.environment.systemPackages)
      && selected.programs.nh.enable
      && selected.programs.nix-ld.enable
      && !(builtins.hasAttr "home-manager" selected)
      && !(selected.environment ? persistence)
      && !(unselected.networking.networkmanager.enable or false)
      && !(unselected.programs.nh.enable or false);
    hostNixCommunityCacheRequiresOptIn =
      let
        defaults = hostNixDefault.nix.settings;
        selected = hostNixCommunityCache.nix.settings;
      in
      !(lib.elem "https://nix-community.cachix.org" (defaults.substituters or [ ]))
      && (defaults.extra-substituters or [ ]) == [ ]
      && !(lib.elem "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" (defaults.trusted-public-keys or [ ]))
      && (defaults.extra-trusted-public-keys or [ ]) == [ ]
      && (selected.extra-substituters or [ ]) == [ "https://nix-community.cachix.org" ]
      && (selected.extra-trusted-public-keys or [ ]) == [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    hostNixCanonicalOverridesLeaveNoCommunityCache =
      let settings = nixCacheOverride.nix.settings; in
      lib.elem "https://example.invalid" settings.substituters
      && !(lib.elem "https://nix-community.cachix.org" settings.substituters)
      && (settings.extra-substituters or [ ]) == [ ]
      && !(lib.elem "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" settings.trusted-public-keys)
      && (settings.extra-trusted-public-keys or [ ]) == [ ];
    selectedPipewireHomePersistence =
      lib.any (directory: directory.directory == ".local/state/wireplumber") pipewireUserOnly.home-manager.users.fixture.home.persistence."/persist".directories;
    selectedBluetoothSystemPersistence =
      lib.any (directory: directory.directory == "/var/lib/bluetooth") pipewireSelected.selected.environment.persistence."/persist".directories;
    pipewireHostSelectionAndOverrideWork =
      pipewireSelected.selected.services.pipewire.enable && !pipewireSelected.selected.services.pipewire.pulse.enable;
    pipewireHostSelectionDoesNotRouteHome =
      !(pipewireSelected.selected.home-manager.users.fixture.home ? persistence)
      || !(pipewireSelected.selected.home-manager.users.fixture.home.persistence ? "/persist")
      || !(lib.any (directory: directory.directory == ".local/state/wireplumber") pipewireSelected.selected.home-manager.users.fixture.home.persistence."/persist".directories);
    unrelatedUserHasNoPipewireHomePersistence =
      !(pipewireUserOnly.home-manager.users.unrelated.home ? persistence)
      || !(pipewireUserOnly.home-manager.users.unrelated.home.persistence ? "/persist")
      || !(lib.any (directory: directory.directory == ".local/state/wireplumber") pipewireUserOnly.home-manager.users.unrelated.home.persistence."/persist".directories);
    homePersistenceBaselineIsTargeted =
      pipewireUserOnly.home-manager.users.fixture.home.persistence."/persist".hideMounts
      && !(pipewireUserOnly.home-manager.users.unrelated.home.persistence."/persist".hideMounts or false);
    persistenceRoutingCanBeExcluded =
      !(lib.any (directory: directory.directory == ".local/state/wireplumber") pipewireWithoutPersistenceRouting.home-manager.users.fixture.home.persistence."/persist".directories)
      && !(lib.any (directory: directory.directory == "/var/lib/bluetooth") pipewireWithoutPersistenceRouting.environment.persistence."/persist".directories)
      && pipewireWithoutPersistenceRouting.environment.persistence."/persist".hideMounts;
    nativeCompositionsPreserveIndependentIdentities =
      broadNativeCompositions.home-manager.users.fixture.programs.git.settings.user.name == "Fixture User"
      && broadNativeCompositions.home-manager.users.fixture.programs.git.settings.user.email == "git@example.invalid"
      && broadNativeCompositions.home-manager.users.fixture.programs.rbw.settings.email == "vault@example.invalid"
      && broadNativeCompositions.home-manager.users.fixture.programs.notmuch.settings.user.name == "Fixture User"
      && broadNativeCompositions.home-manager.users.fixture.programs.notmuch.settings.user.primary_email == "mail@example.invalid"
      && broadNativeCompositions.home-manager.users.fixture.accounts.email.accounts.alpha.address == "mail@example.invalid"
      && broadNativeCompositions.home-manager.users.fixture.accounts.email.accounts.alpha.primary
      && broadNativeCompositions.home-manager.users.fixture.accounts.email.accounts.beta.address == "other@example.invalid";
    nativeCompositionsBuildActivation =
      broadNativeCompositions.home-manager.users.fixture.home.activationPackage.drvPath != "";
  };
  failed = builtins.attrNames (nixpkgs.lib.filterAttrs (_: passed: !passed) checks);
in
if failed == [ ] then
  checks
else
  throw "Broad composition fixture failed: ${nixpkgs.lib.concatStringsSep ", " failed}"
