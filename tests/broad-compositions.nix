let
  source = builtins.getFlake (toString ../.);
  inputs = source.inputs // { dotnix = source; self = source; };
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;
  dotnix = source.denful.dotnix;
  system = "x86_64-linux";
  # Markers prove resource presence only; contents are not usable keys, certificates, or images. This suite evaluates gates only and never builds or activates these fake resource configs.
  resourceTree = (import nixpkgs { inherit system; }).runCommand "consumer-resources" { } ''
    mkdir -p $out/modules/hosts/fixture/secrets $out/modules/hosts/fixture/certificates $out/modules/users/fixture/secrets $out/modules/users/fixture/assets
    printf 'public fixture marker\\n' > $out/modules/hosts/fixture/secrets/ssh_host_ed25519_key.pub
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
    , withUser ? true
    , extraUsers ? { }
    , disablePersistenceRouting ? false
    , consumerSelf ? source
    ,
    }:
    let
      fixture = {
        imports = [
          inputs.den.flakeModule
          (inputs.den.namespace "dotnix" [ inputs.dotnix true ])
          ({ den, ... }: { den.default.includes = [ den.batteries.flake-scope ]; })
        ];
        den.hosts.${system}.fixture = {
          users = (lib.optionalAttrs withUser {
            fixture.classes = [ "homeManager" ];
          }) // extraUsers;
          instantiate = args:
            inputs.nixpkgs.lib.nixosSystem (args // {
              pkgs = import inputs.nixpkgs {
                inherit system;
                overlays = [ inputs.nur.overlays.default inputs.llm-agents.overlays.shared-nixpkgs inputs.niri.overlays.niri ];
              };
            });
        };
        den.aspects.fixture = {
          includes = hostIncludes;
          excludes = lib.optionals disablePersistenceRouting dotnix.impermanence.includes;
          nixos = bootstrap // hostModule;
          provides = {
            fixture = {
              includes = userIncludes;
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
      };
      consumerInputs = inputs // { self = consumerSelf; };
      flake = inputs.flake-parts.lib.mkFlake { inputs = consumerInputs; } fixture;
    in
    flake.nixosConfigurations.fixture.config;

  populatedResources = evaluate {
    consumerSelf = populatedSelf;
    hostIncludes = with dotnix; [ age age-rekey users yubikey-pam desktop-shell dms stylix certificates ];
    userIncludes = with dotnix; [ age-rekey stylix ];
    hostModule.users.users.fixture.home = "/home/fixture";
  };
  emptyResources = evaluate {
    hostIncludes = with dotnix; [ age age-rekey users yubikey-pam desktop-shell dms stylix certificates ];
    userIncludes = with dotnix; [ age-rekey stylix ];
    hostModule.users.users.fixture.home = "/home/fixture";
  };
  workstation = evaluate {
    hostIncludes = with dotnix; [
      core
      base
      boot-systemd
      performance
      bluetooth
      disko
      impermanence
      geolocation
      network
      network-wifi
      pipewire
      power
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
    hostIncludes = with dotnix; [ impermanence ];
    userIncludes = with dotnix; [ stylix desktop noctalia ];
    withUser = true;
  };
  homeWithNiri = evaluate {
    hostIncludes = with dotnix; [ impermanence ];
    userIncludes = with dotnix; [ desktop-shell noctalia ];
    withUser = true;
  };
  pipewireSelected = evaluate {
    hostIncludes = with dotnix; [ impermanence pipewire bluetooth ];
    userIncludes = with dotnix; [ pipewire ];
    extraUsers.unrelated.classes = [ "homeManager" ];
  };
  pipewireWithoutPersistenceRouting = evaluate {
    hostIncludes = with dotnix; [ impermanence pipewire bluetooth ];
    userIncludes = with dotnix; [ pipewire ];
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
  checks = {
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
      && lib.elem "authfile=${populatedResources.age.secrets.u2f.path}" populatedResources.programs.dank-material-shell.lockscreen.securityKey.moduleArgs;
    populatedWallpaperPath = toString populatedResources.home-manager.users.fixture.stylix.image == "${resourceTree}/modules/users/fixture/assets/wallpaper.png";
    populatedCertificateFiles = lib.unique populatedResources.security.pki.certificateFiles == [ "${resourceTree}/modules/hosts/fixture/certificates/fixture.crt" ];
    emptyResourceGates =
      emptyResources.age.secrets == { }
      && emptyResources.users.users.fixture.hashedPasswordFile == null
      && emptyResources.users.mutableUsers
      && !(emptyResources.security.pam.u2f.enable or false)
      && !(emptyResources.programs.dank-material-shell.lockscreen.securityKey.enable or false)
      && emptyResources.age.rekey.hostPubkey == ""
      && emptyResources.home-manager.users.fixture.age.rekey.hostPubkey == ""
      && emptyResources.security.pki.certificateFiles == [ ];
    workstationHasSelectedRootAndBootloader =
      workstation.fileSystems."/".fsType == "btrfs" && workstation.boot.loader.systemd-boot.enable;
    workstationHasCoreSystemDesktopDevelopment =
      workstation.programs.fish.enable
      && workstation.zramSwap.enable
      && workstation.programs.niri.enable
      && workstation.virtualisation.docker.enable
      && workstation.home-manager.users.fixture.programs.helix.enable;
    socketDoesNotSelectShellOrGreeter =
      !(socketOnly.programs.dank-material-shell.enable or false)
      && !(socketOnly.programs.dms-greeter.enable or false)
      && !(socketOnly.services.displayManager.noctalia-greeter.enable or false);
    dmsShellAndGreeterExplicitlySelected =
      dmsSelected.programs.dank-material-shell.enable && dmsSelected.programs.dms-greeter.enable;
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
    persistenceNeedsImpermanence = !(socketOnly.environment ? persistence);
    selectedHomePersistence =
      lib.any (directory: directory.directory == ".cache/mesa_shader_cache") homeWithNiri.home-manager.users.fixture.home.persistence."/persist".directories
      && !(lib.any (directory: directory.directory == ".mozilla") homeWithNiri.home-manager.users.fixture.home.persistence."/persist".directories)
      && lib.any (directory: directory.directory == ".mozilla") home.home-manager.users.fixture.home.persistence."/persist".directories;
    selectedPipewireHomePersistence =
      lib.any (directory: directory.directory == ".local/state/wireplumber") pipewireSelected.home-manager.users.fixture.home.persistence."/persist".directories;
    selectedBluetoothSystemPersistence =
      lib.any (directory: directory.directory == "/var/lib/bluetooth") pipewireSelected.environment.persistence."/persist".directories;
    unrelatedUserHasNoPipewireHomePersistence =
      !(lib.any (directory: directory.directory == ".local/state/wireplumber") pipewireSelected.home-manager.users.unrelated.home.persistence."/persist".directories);
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
