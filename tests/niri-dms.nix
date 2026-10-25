let
  source = builtins.getFlake (toString ../.);
  inputs = source.inputs // { dotnix = source; self = source; };
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;
  dotnix = source.denful.dotnix;
  system = "x86_64-linux";

  evaluate =
    { hostIncludes ? [ ]
    , userIncludes ? [ ]
    , hostModule ? { }
    , userModule ? { }
    , niriOverlay ? true
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
          users.fixture.classes = [ "homeManager" ];
          instantiate = args:
            inputs.nixpkgs.lib.nixosSystem (args // {
              pkgs = import inputs.nixpkgs {
                inherit system;
                overlays = lib.optional niriOverlay inputs.niri.overlays.niri;
              };
            });
        };
        den.aspects.fixture = {
          includes = hostIncludes;
          nixos = {
            system.stateVersion = "25.11";
            nixpkgs.hostPlatform = system;
            nixpkgs.overlays = lib.optional niriOverlay inputs.niri.overlays.niri;
            home-manager.useGlobalPkgs = true;
            users.users.fixture = {
              isNormalUser = true;
              home = "/home/fixture";
            };
          } // hostModule;
          provides.fixture = {
            includes = userIncludes;
            homeManager = {
              home.username = "fixture";
              home.homeDirectory = "/home/fixture";
              home.stateVersion = "25.11";
            } // userModule;
          };
        };
      };
      flake = inputs.flake-parts.lib.mkFlake { inherit inputs; } fixture;
      config = flake.nixosConfigurations.fixture.config;
    in
    {
      inherit config;
      home = config.home-manager.users.fixture;
    };

  niriOnly = evaluate {
    hostIncludes = with dotnix; [ host.niri ];
    userIncludes = with dotnix; [ home.niri ];
  };
  userNiriOnly = evaluate {
    userIncludes = with dotnix; [ home.niri ];
  };
  overlayFreeHomeNiri = evaluate {
    userIncludes = [ dotnix.home.niri ];
    niriOverlay = false;
  };
  niriDisabled = evaluate {
    hostIncludes = with dotnix; [ host.niri ];
    userIncludes = with dotnix; [ home.niri ];
    hostModule = { programs.niri.enable = lib.mkForce false; };
  };
  niriDms = evaluate {
    hostIncludes = with dotnix; [ host.niri dms ];
    userIncludes = with dotnix; [ home.niri dms ];
  };
  niriNoctalia = evaluate {
    hostIncludes = with dotnix; [ host.niri ];
    userIncludes = with dotnix; [ home.niri noctalia ];
  };
  standaloneHome =
    let
      fixture = {
        imports = [
          inputs.den.flakeModule
          (inputs.den.namespace "dotnix" [ inputs.dotnix true ])
          ({ den, ... }: { den.default.includes = [ den.batteries.flake-scope ]; })
        ];
        den.homes.${system}.fixture.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ inputs.niri.overlays.niri ];
        };
        den.aspects.fixture.includes = with dotnix; [ home.niri ];
        den.aspects.fixture.homeManager = { specialArgs, ... }: {
          home.username = "fixture";
          home.homeDirectory = "/home/fixture";
          home.stateVersion = "25.11";
          programs.niri.enable = true;
          assertions = [
            {
              assertion = !(builtins.hasAttr "osConfig" specialArgs);
              message = "Standalone Home Manager must not receive osConfig";
            }
          ];
        };
      };
      flake = inputs.flake-parts.lib.mkFlake { inherit inputs; } fixture;
    in
    { home = flake.homeConfigurations.fixture.config; };
  niriOnlyHome = standaloneHome;
  niriNoctaliaHome = evaluate {
    userIncludes = with dotnix; [ home.niri noctalia ];
  };
  noctaliaOnlyHome = evaluate {
    userIncludes = with dotnix; [ noctalia ];
  };
  handyOnlyHome = evaluate {
    userIncludes = with dotnix; [ handy ];
  };
  handyNiriHome = evaluate {
    userIncludes = with dotnix; [ home.niri handy ];
  };
  desktopShellHome = evaluate {
    userIncludes = with dotnix; [ desktop-shell gpg-agent rbw ];
  };
  desktopShellOverrideHome = evaluate {
    userIncludes = with dotnix; [ desktop-shell gpg-agent rbw ];
    userModule = {
      services.gpg-agent.pinentry.package = nixpkgs.legacyPackages.${system}.pinentry-curses;
      programs.rbw.settings.pinentry = nixpkgs.legacyPackages.${system}.pinentry-curses;
    };
  };
  dmsHome = evaluate {
    userIncludes = with dotnix; [ home.niri dms ];
  };
  multiUser =
    let
      fixture = {
        imports = [
          inputs.den.flakeModule
          (inputs.den.namespace "dotnix" [ inputs.dotnix true ])
          ({ den, ... }: { den.default.includes = [ den.batteries.flake-scope ]; })
        ];
        den.hosts.${system}.fixture = {
          users = {
            alice.classes = [ "homeManager" ];
            bob.classes = [ "homeManager" ];
          };
          instantiate = args:
            inputs.nixpkgs.lib.nixosSystem (args // {
              pkgs = import inputs.nixpkgs {
                inherit system;
                overlays = [ inputs.niri.overlays.niri ];
              };
            });
        };
        den.aspects.fixture = {
          includes = with dotnix; [ host.niri dms ];
          nixos = {
            system.stateVersion = "25.11";
            nixpkgs.hostPlatform = system;
            nixpkgs.overlays = [ inputs.niri.overlays.niri ];
            home-manager.useGlobalPkgs = true;
            users.users = {
              alice = { isNormalUser = true; home = "/home/alice"; };
              bob = { isNormalUser = true; home = "/home/bob"; };
            };
          };
          provides = {
            alice = {
              includes = with dotnix; [ home.niri dms ];
              homeManager = {
                home.username = "alice";
                home.homeDirectory = "/home/alice";
                home.stateVersion = "25.11";
              };
            };
            bob = {
              includes = with dotnix; [ home.niri noctalia ];
              homeManager = {
                home.username = "bob";
                home.homeDirectory = "/home/bob";
                home.stateVersion = "25.11";
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
  bothShells = evaluate {
    userIncludes = with dotnix; [ home.niri dms noctalia ];
  };
  sameTargetConflict = builtins.tryEval bothShells.home.home.activationPackage.drvPath;

  assertions = {
    integratedNiriFinalConfig = niriOnly.home.programs.niri.finalConfig != null;
    integratedNiriActivationPackage = niriOnly.home.home.activationPackage.drvPath != "";
    integratedNiriDmsFinalConfig = niriDms.home.programs.niri.finalConfig != null;
    integratedNiriPackagePropagated =
      niriOnly.home.programs.niri.package.outPath == niriOnly.config.programs.niri.package.outPath;
    disabledHostCanOverrideNiri = !niriDisabled.config.programs.niri.enable;
    disabledProviderFinalConfig = niriDisabled.home.programs.niri.finalConfig != null;
    disabledProviderPackagePropagated =
      niriDisabled.home.programs.niri.package.outPath == niriDisabled.config.programs.niri.package.outPath;
    disabledProviderActivationPackage = niriDisabled.home.home.activationPackage.drvPath != "";
    standaloneNiriFinalConfig = niriOnlyHome.home.programs.niri.finalConfig != null;
    standaloneNiriActivationPackage = niriOnlyHome.home.home.activationPackage.drvPath != "";
    niriHostDoesNotEnableGlobalPolkitAgent = !niriOnly.config.systemd.user.services.niri-flake-polkit.enable;
    niriHomeSelectsPolkitAgent =
      builtins.elem "niri.service" niriOnly.home.systemd.user.services.niri-flake-polkit.Install.WantedBy;
    dmsOwnsPolkitAgent =
      !niriDms.config.systemd.user.services.niri-flake-polkit.enable
      && !(builtins.elem "niri.service" (niriDms.home.systemd.user.services.niri-flake-polkit.Install.WantedBy or [ ]));
    noctaliaLeavesPolkitToNiri =
      !niriNoctalia.config.systemd.user.services.niri-flake-polkit.enable
      && builtins.elem "niri.service" niriNoctalia.home.systemd.user.services.niri-flake-polkit.Install.WantedBy;
    dmsHostRuntimeIsDisabled = !(multiUser.config.systemd.user.services.dms.enable or false);
    aliceDmsServiceExists = multiUser.alice.systemd.user.services ? dms;
    bobDmsServiceIsAbsent = !(multiUser.bob.systemd.user.services ? dms);
    aliceDoesNotGetNoctaliaRuntime = !(multiUser.alice.programs.noctalia.enable or false);
    bobNoctaliaServiceEnabled = multiUser.bob.programs.noctalia.systemd.enable;
    dmsUserDoesNotRunNiriPolkitAgent =
      !(builtins.elem "niri.service" (multiUser.alice.systemd.user.services.niri-flake-polkit.Install.WantedBy or [ ]));
    noctaliaUserGetsAuthentication =
      multiUser.config.security.polkit.enable
      && (multiUser.bob.systemd.user.services ? niri-flake-polkit)
      && builtins.elem "niri.service" multiUser.bob.systemd.user.services.niri-flake-polkit.Install.WantedBy;
    noctaliaUserGetsNoDmsRuntime =
      multiUser.bob.programs.noctalia.enable
      && !(multiUser.bob.systemd.user.services ? dms);
    sameTargetShellConflictRejected = !sameTargetConflict.success;
    sameTargetShellConflictHasDiagnostic = builtins.any
      (assertion:
        !assertion.assertion
        && assertion.message == "DMS and Noctalia cannot both be selected for the same Home Manager target.")
      bothShells.home.assertions;
    userNiriSelectionDoesNotEnableHost = !(userNiriOnly.config.programs.niri.enable or false);
    homeNiriWorksWithoutHostOverlay =
      !(overlayFreeHomeNiri.config.programs.niri.enable or false)
      && overlayFreeHomeNiri.home.programs.niri.finalConfig != null
      && builtins.hasAttr "Mod+Q" overlayFreeHomeNiri.home.programs.niri.settings.binds;
    niriOnlyHasGeneralBinding = builtins.hasAttr "Mod+Q" niriOnlyHome.home.programs.niri.settings.binds;
    niriOnlyHasNoDmsBinding = !(builtins.hasAttr "Mod+Space" niriOnlyHome.home.programs.niri.settings.binds);
    niriOnlyHasNoHandyBindings =
      !(builtins.hasAttr "Mod+D" niriOnlyHome.home.programs.niri.settings.binds)
      && !(builtins.hasAttr "Mod+Shift+D" niriOnlyHome.home.programs.niri.settings.binds);
    handyWorksWithoutNiri = !(handyOnlyHome.home.programs ? niri);
    handyNiriHasBindings =
      handyNiriHome.home.programs.niri.settings.binds."Mod+D".action.spawn == [
        "handy"
        "--toggle-transcription"
      ]
      && handyNiriHome.home.programs.niri.settings.binds."Mod+Shift+D".action.spawn == [
        "handy"
        "--cancel"
      ];
    desktopShellUsesGuiPinentry =
      desktopShellHome.home.services.gpg-agent.pinentry.package.pname == "pinentry-gnome3"
      && desktopShellHome.home.programs.rbw.settings.pinentry
      == lib.getExe nixpkgs.legacyPackages.${system}.pinentry-gnome3;
    desktopShellPreservesConsumerPinentry =
      desktopShellOverrideHome.home.services.gpg-agent.pinentry.package.pname == "pinentry-curses"
      && desktopShellOverrideHome.home.programs.rbw.settings.pinentry
      == lib.getExe nixpkgs.legacyPackages.${system}.pinentry-curses;
    desktopShellIncludesClipboard = builtins.elem nixpkgs.legacyPackages.${system}.wl-clipboard desktopShellHome.home.home.packages;
    desktopShellDoesNotSelectNiri = !(desktopShellHome.home.programs ? niri);
    dmsHasIpcBinding =
      dmsHome.home.programs.niri.settings.binds."Mod+Space".action.spawn == [
        "dms"
        "ipc"
        "call"
        "spotlight"
        "toggle"
      ];
    noctaliaNiriConfigGenerated = niriNoctaliaHome.home.xdg.configFile.niri-config.enable;
    noctaliaIsEnabled = niriNoctaliaHome.home.programs.noctalia.enable;
    noctaliaServiceEnabled = niriNoctaliaHome.home.programs.noctalia.systemd.enable;
    noctaliaUsesPinnedPackage =
      niriNoctaliaHome.home.programs.noctalia.package.outPath
      == inputs.noctalia.packages.${system}.default.outPath;
    noctaliaHasLauncherBinding =
      niriNoctaliaHome.home.programs.niri.settings.binds."Mod+Space".action.spawn == [
        "noctalia"
        "msg"
        "panel-toggle"
        "launcher"
      ];
    noctaliaHasControlCenterBinding =
      niriNoctaliaHome.home.programs.niri.settings.binds."Mod+S".action.spawn == [
        "noctalia"
        "msg"
        "panel-toggle"
        "control-center"
      ];
    noctaliaHasSettingsBinding =
      niriNoctaliaHome.home.programs.niri.settings.binds."Mod+Comma".action.spawn == [
        "noctalia"
        "msg"
        "settings-toggle"
      ];
    noctaliaHasHoldWindowSwitcherBinding =
      niriNoctaliaHome.home.programs.niri.settings.binds."Alt+Tab".action.spawn == [
        "noctalia"
        "msg"
        "window-switcher"
        "hold"
      ];
    noctaliaHasVolumeBinding =
      niriNoctaliaHome.home.programs.niri.settings.binds.XF86AudioRaiseVolume.action.spawn == [ "noctalia" "msg" "volume-up" ]
      && niriNoctaliaHome.home.programs.niri.settings.binds.XF86AudioLowerVolume.action.spawn == [ "noctalia" "msg" "volume-down" ]
      && niriNoctaliaHome.home.programs.niri.settings.binds.XF86AudioMute.action.spawn == [ "noctalia" "msg" "volume-mute" ];
    noctaliaHasBrightnessBinding =
      niriNoctaliaHome.home.programs.niri.settings.binds.XF86MonBrightnessUp.action.spawn == [ "noctalia" "msg" "brightness-up" ]
      && niriNoctaliaHome.home.programs.niri.settings.binds.XF86MonBrightnessDown.action.spawn == [ "noctalia" "msg" "brightness-down" ];
    noctaliaHasFloatingRule = builtins.any
      (rule: rule.open-floating == true && builtins.any (match: match.app-id == "dev.noctalia.Noctalia") (rule.matches or [ ]))
      niriNoctaliaHome.home.programs.niri.settings.window-rules;
    noctaliaWorksWithoutNiri = noctaliaOnlyHome.home.programs.noctalia.enable && !(noctaliaOnlyHome.home.programs ? niri);
  };
  failed = builtins.attrNames (lib.filterAttrs (_: passed: !passed) assertions);
in
if failed == [ ] then
  assertions
else
  throw "Niri/DMS fixture failed: ${lib.concatStringsSep ", " failed}"
