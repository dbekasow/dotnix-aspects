{ source ? builtins.getFlake (toString ../.) }:
let
  inputs = source.inputs // { dotnix = source; self = source; };
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) lib;
  dotnix = source.denful.dotnix;
  system = "x86_64-linux";
  groups = [
    (inputs.dotnix + "/modules/base")
    (inputs.dotnix + "/modules/desktop")
  ];

  evaluate =
    { hostIncludes ? [ ]
    , userIncludes ? [ ]
    , hostModule ? { }
    , userModule ? { }
    , niriOverlay ? true
    , extraImports ? [ ]
    , extraUserIncludes ? (_: [ ])
    ,
    }:
    let
      fixture = { dotnix, ... }: {
        imports = groups ++ extraImports;
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
            includes = userIncludes ++ extraUserIncludes dotnix;
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
    hostIncludes = [ dotnix.host.niri ];
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
    hostIncludes = with dotnix; [ host.niri host.dms ];
  };
  niriNoctalia = evaluate {
    hostIncludes = with dotnix; [ host.niri host.noctalia ];
  };
  niriNoctaliaHome = evaluate {
    userIncludes = with dotnix; [ home.niri home.noctalia home.stylix home.ghostty ];
  };
  noctaliaCustomBarHome = evaluate {
    userIncludes = with dotnix; [ home.noctalia home.stylix ];
    userModule.programs.noctalia.settings.bar.default.end = [ "clock" ];
  };
  noctaliaSettings = niriNoctaliaHome.home.programs.noctalia.settings;
  ghosttySettings = niriNoctaliaHome.home.programs.ghostty.settings;
  hasCompositorBlur = appId: lib.any
    (rule: rule.background-effect.blur == true && lib.any
      (match: match.app-id != null && builtins.match match.app-id appId != null)
      rule.matches)
    niriNoctaliaHome.home.programs.niri.settings.window-rules;
  noctaliaOnlyHome = evaluate {
    userIncludes = with dotnix; [ home.noctalia ];
  };
  handyOnlyHome = evaluate {
    userIncludes = with dotnix; [ home.handy ];
  };
  handyNiriHome = evaluate {
    userIncludes = with dotnix; [ home.niri home.handy ];
  };
  desktopShellHome = evaluate {
    userIncludes = with dotnix; [ home.graphical home.gpg-agent-gui home.rbw-gui ];
  };
  desktopShellWithoutGuiPinentry = evaluate {
    userIncludes = with dotnix; [ home.graphical home.gpg-agent home.rbw ];
  };
  desktopShellOverrideHome = evaluate {
    userIncludes = with dotnix; [ home.graphical home.gpg-agent-gui home.rbw-gui ];
    userModule = {
      services.gpg-agent.pinentry.package = nixpkgs.legacyPackages.${system}.pinentry-curses;
      programs.rbw.settings.pinentry = nixpkgs.legacyPackages.${system}.pinentry-curses;
    };
  };
  dmsHome = evaluate {
    userIncludes = with dotnix; [ home.niri home.dms ];
  };
  familyHome = evaluate {
    hostIncludes = [ dotnix.host.persistence ];
    userIncludes = with dotnix; [ home.graphical home.firefox home.persistence ];
  };
  templateHome = evaluate {
    hostIncludes = [ dotnix.host.persistence ];
    userIncludes = [ dotnix.home.niri ];
    extraImports = [ ../modules/templates/dotnix/modules/users/myUser/default.nix ];
    extraUserIncludes = d: [ d.myuser ];
    userModule.home.stateVersion = "26.11";
  };
  multiUser =
    let
      fixture = {
        imports = groups;
        den.hosts.${system} = {
          fixture.users = {
            alice.classes = [ "homeManager" ];
            bob.classes = [ "homeManager" ];
          };
          other.users.bob.classes = [ "homeManager" ];
        };
        den.homes.${system}.standalone.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ inputs.niri.overlays.niri ];
        };
        den.aspects.standalone = {
          includes = [ dotnix.home.niri ];
          homeManager = { specialArgs, ... }: {
            home.username = "bob";
            home.homeDirectory = "/home/bob";
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
        den.aspects.other = {
          nixos = {
            system.stateVersion = "25.11";
            nixpkgs.hostPlatform = system;
            home-manager.useGlobalPkgs = true;
            users.users.bob = { isNormalUser = true; home = "/home/bob"; };
          };
          provides.bob.homeManager = {
            home.username = "bob";
            home.homeDirectory = "/home/bob";
            home.stateVersion = "25.11";
          };
        };
        den.aspects.fixture = {
          includes = [ dotnix.host.dms ];
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
              includes = with dotnix; [ home.niri home.firefox ];
              homeManager = {
                home.username = "alice";
                home.homeDirectory = "/home/alice";
                home.stateVersion = "25.11";
              };
            };
            bob = {
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
      other = flake.nixosConfigurations.other.config.home-manager.users.bob;
      standalone = flake.homeConfigurations.standalone.config;
    };
  niriOnlyHome = { home = multiUser.standalone; };
  bootable = {
    boot.loader.grub = { enable = true; device = "nodev"; };
    fileSystems."/" = { device = "/dev/fixture-root"; fsType = "ext4"; };
  };
  bothShells = evaluate {
    hostIncludes = with dotnix; [ host.niri host.dms ];
    userIncludes = with dotnix; [ home.niri home.noctalia ];
    hostModule = bootable;
  };
  bothHostShells = evaluate {
    hostIncludes = with dotnix; [ host.niri host.dms host.noctalia ];
    hostModule = bootable;
  };
  conflictOnly = builtins.getEnv "NIRI_DMS_CONFLICT_ONLY";

  assertions = {
    desktopCatalogHasExplicitChoices =
      !(dotnix.host ? desktop)
      && !(dotnix.home ? desktop)
      && !(dotnix.home ? desktop-apps)
      && dotnix.host ? graphical
      && builtins.all (name: builtins.hasAttr name dotnix.home) [
        "graphical"
        "alacritty"
        "anki"
        "ghostty"
        "handy"
        "firefox"
        "thunderbird"
        "office"
        "browsers"
        "mail"
      ];
    templateHomeSelectsItsApplicationsAndLaunchKeys =
      let
        inherit (templateHome) home;
        binds = home.programs.niri.settings.binds;
      in
      home.programs.ghostty.enable
      && home.programs.firefox.enable
      && home.programs.thunderbird.enable
      && builtins.all (pkg: builtins.elem pkg home.home.packages) [
        home.programs.ghostty.package
        home.programs.firefox.finalPackage
        home.programs.thunderbird.package
      ]
      && binds."Mod+T".action.spawn == [ "ghostty" ]
      && binds."Mod+B".action.spawn == [ "firefox" ]
      && binds."Mod+O".action.spawn == [ "thunderbird" ]
      && !(builtins.hasAttr "Mod+E" binds)
      && !home.programs.alacritty.enable
      && !home.programs.anki.enable
      && !home.programs.onlyoffice.enable
      && !(builtins.any (pkg: lib.getName pkg == "handy") home.home.packages);
    familyHomeNeedsNoDevelopmentOrAgentTools =
      let inherit (familyHome) home;
      in
      home.programs.firefox.enable
      && !home.programs.helix.enable
      && !(familyHome.config.programs.niri.enable or false)
      && !(builtins.any (pkg: builtins.elem (lib.getName pkg) [ "skills" "tokscale" "repomix" ]) home.home.packages)
      && !(builtins.any (entry: entry.directory == ".pi") home.home.persistence."/persist".directories);
    integratedNiriFinalConfig = niriOnly.home.programs.niri.finalConfigFile != null;
    integratedNiriActivationPackage = niriOnly.home.home.activationPackage.drvPath != "";
    integratedNiriDmsFinalConfig = niriDms.home.programs.niri.finalConfigFile != null;
    integratedNiriPackagePropagated =
      niriOnly.home.programs.niri.package.outPath == niriOnly.config.programs.niri.package.outPath;
    disabledHostCanOverrideNiri = !niriDisabled.config.programs.niri.enable;
    disabledProviderFinalConfig = niriDisabled.home.programs.niri.finalConfigFile != null;
    disabledProviderPackagePropagated =
      niriDisabled.home.programs.niri.package.outPath == niriDisabled.config.programs.niri.package.outPath;
    disabledProviderActivationPackage = niriDisabled.home.home.activationPackage.drvPath != "";
    standaloneNiriFinalConfig = niriOnlyHome.home.programs.niri.finalConfigFile != null;
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
    bothOccupantsGetOnlyDmsRuntime = builtins.all
      (home:
        builtins.elem "graphical-session.target" home.systemd.user.services.dms.Install.WantedBy
        && !(home.programs.noctalia.enable or false)
        && home.home.activationPackage.drvPath != "")
      [ multiUser.alice multiUser.bob ];
    dmsDoesNotSelectNiriBaseline =
      !(multiUser.config.programs.niri.enable or false)
      && !(multiUser.bob.programs.niri.settings.binds ? "Mod+Q");
    dmsUserDoesNotRunNiriPolkitAgent =
      !(builtins.elem "niri.service" (multiUser.alice.systemd.user.services.niri-flake-polkit.Install.WantedBy or [ ]));
    noctaliaUserGetsAuthentication =
      niriNoctalia.config.security.polkit.enable
      && (niriNoctalia.home.systemd.user.services ? niri-flake-polkit)
      && builtins.elem "niri.service" niriNoctalia.home.systemd.user.services.niri-flake-polkit.Install.WantedBy;
    noctaliaUserGetsNoDmsRuntime =
      builtins.elem "graphical-session.target" niriNoctalia.home.systemd.user.services.noctalia.Install.WantedBy
      && !(niriNoctalia.home.systemd.user.services ? dms)
      && !(niriNoctalia.config.systemd.user.services.noctalia.enable or false);
    otherTargetsGetNoShell = builtins.all
      (home: !(home.systemd.user.services ? dms) && !(home.programs.noctalia.enable or false))
      [ multiUser.other multiUser.standalone ];
    personalAppsStayWithTheirOccupant = multiUser.alice.programs.firefox.enable && !multiUser.bob.programs.firefox.enable;
    hostShellDoesNotSelectGreeter = !(multiUser.config.services.greetd.enable or false);
    sameTargetShellConflictHasDiagnostic =
      !(builtins.tryEval bothShells.config.system.build.toplevel.drvPath).success
      && builtins.any
        (assertion:
          !assertion.assertion
          && assertion.message == "DMS and Noctalia cannot both be selected for the same Home Manager target.")
        bothShells.home.assertions;
    userNiriSelectionDoesNotEnableHost = !(userNiriOnly.config.programs.niri.enable or false);
    homeNiriWorksWithoutHostOverlay =
      !(overlayFreeHomeNiri.config.programs.niri.enable or false)
      && overlayFreeHomeNiri.home.programs.niri.finalConfigFile != null
      && builtins.hasAttr "Mod+Q" overlayFreeHomeNiri.home.programs.niri.settings.binds;
    niriOnlyHasGeneralBinding = builtins.hasAttr "Mod+Q" niriOnlyHome.home.programs.niri.settings.binds;
    niriOnlyKeepsGeneralBindingsWithoutApplications =
      let binds = niriOnlyHome.home.programs.niri.settings.binds;
      in
      binds."Mod+1".action.focus-workspace == [ 1 ]
      && binds."Mod+Shift+E".action ? quit
      && builtins.all (key: !(builtins.hasAttr key binds)) [ "Mod+T" "Mod+B" "Mod+E" "Mod+O" ];
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
    featureOwnedGuiPinentrySelection =
      desktopShellHome.home.services.gpg-agent.pinentry.package.pname == "pinentry-gnome3"
      && desktopShellHome.home.programs.rbw.settings.pinentry
      == lib.getExe nixpkgs.legacyPackages.${system}.pinentry-gnome3;
    desktopShellDoesNotForceGuiPinentry =
      desktopShellWithoutGuiPinentry.home.services.gpg-agent.pinentry.package.pname == "pinentry-curses"
      && desktopShellWithoutGuiPinentry.home.programs.rbw.settings.pinentry
      == lib.getExe nixpkgs.legacyPackages.${system}.pinentry-curses;
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
    noctaliaBarDefaultsWithStylix =
      noctaliaSettings.bar.default.background_opacity == 0.85
      && noctaliaSettings.bar.default.end == [ "tray" "notifications" "clipboard" "battery" "control-center" "session" ]
      && noctaliaSettings.widget.tray.drawer
      && !(noctaliaSettings.bar ? background_opacity)
      && noctaliaSettings.shell.font_family == niriNoctaliaHome.home.stylix.fonts.sansSerif.name;
    noctaliaBarListIsOverridable =
      noctaliaCustomBarHome.home.programs.noctalia.settings.bar.default.end == [ "clock" ];
    noctaliaWeatherDoesNotChangeStylixIdlePolicy =
      noctaliaSettings.location.auto_locate && noctaliaSettings.weather.enabled
      && !(noctaliaSettings ? idle);
    thunarUsesNiriBlur = lib.any
      (rule: rule.background-effect.blur == true && rule.opacity == 0.94 && lib.any
        (match: match.app-id != null && builtins.match match.app-id "thunar" != null)
        rule.matches)
      niriNoctaliaHome.home.programs.niri.settings.window-rules;
    ghosttyUsesNiriBlur =
      hasCompositorBlur "com.mitchellh.ghostty" && hasCompositorBlur "Alacritty"
      && !(hasCompositorBlur "comXmitchellhXghostty")
      && ghosttySettings.background-blur == [ false ]
      && ghosttySettings.background-opacity == [ 0.94 ];
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
if conflictOnly == "1" then
  bothShells.config.system.build.toplevel.drvPath
else if conflictOnly == "host" then
  bothHostShells.config.system.build.toplevel.drvPath
else if failed == [ ] then
  assertions
else
  throw "Niri/DMS fixture failed: ${lib.concatStringsSep ", " failed}"
