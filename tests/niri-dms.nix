let
  source = builtins.getFlake (toString ../.);
  inherit (source.inputs)
    nixpkgs
    home-manager
    niri
    ;
  inherit (nixpkgs) lib;
  system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
    overlays = [ niri.overlays.niri ];
  };

  hm =
    modules:
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        {
          options.profile.email = lib.mkOption {
            type = lib.types.str;
            default = "fixture@example.invalid";
          };
          config = {
            profile.email = "fixture@example.invalid";
            home.username = "fixture";
            home.homeDirectory = "/home/fixture";
            home.stateVersion = "25.11";
          };
        }
      ]
      ++ modules;
    };

  nixos =
    modules:
    lib.nixosSystem {
      inherit system;
      modules = [
        home-manager.nixosModules.home-manager
        {
          system.stateVersion = "25.11";
          nixpkgs.hostPlatform = system;
          users.users.fixture = {
            isNormalUser = true;
            home = "/home/fixture";
          };
          home-manager.useGlobalPkgs = true;
          home-manager.users.fixture = {
            imports = [ source.modules.homeManager.niri ];
            home.stateVersion = "25.11";
          };
        }
      ]
      ++ modules;
    };

  niriOnly = nixos [ source.modules.nixos.niri ];
  niriDisabled = nixos [
    source.modules.nixos.niri
    { programs.niri.enable = lib.mkForce false; }
  ];
  niriDms = nixos [
    source.modules.nixos.niri
    source.modules.nixos.dms
    { home-manager.users.fixture.imports = [ source.modules.homeManager.dms ]; }
  ];
  niriNoctalia = nixos [
    source.modules.nixos.niri
    { home-manager.users.fixture.imports = [ source.modules.homeManager.noctalia ]; }
  ];
  niriOnlyHome = hm [
    source.modules.homeManager.niri
    { programs.niri.enable = true; }
  ];
  niriNoctaliaHome = hm [
    source.modules.homeManager.niri
    source.modules.homeManager.noctalia
  ];
  noctaliaOnlyHome = hm [ source.modules.homeManager.noctalia ];
  handyOnlyHome = hm [ source.modules.homeManager.handy ];
  handyNiriHome = hm [
    source.modules.homeManager.niri
    source.modules.homeManager.handy
  ];
  desktopShellHome = hm [
    source.modules.homeManager.desktop-shell
    source.modules.homeManager.gpg-agent
    source.modules.homeManager.rbw
  ];
  desktopShellOverrideHome = hm [
    source.modules.homeManager.desktop-shell
    source.modules.homeManager.gpg-agent
    source.modules.homeManager.rbw
    {
      services.gpg-agent.pinentry.package = pkgs.pinentry-curses;
      programs.rbw.settings.pinentry = pkgs.pinentry-curses;
    }
  ];
  dmsHome = hm [
    source.modules.homeManager.niri
    source.modules.homeManager.dms
  ];

  assertions = {
    integratedNiriFinalConfig =
      niriOnly.config.home-manager.users.fixture.programs.niri.finalConfig != null;
    integratedNiriActivationPackage =
      niriOnly.config.home-manager.users.fixture.home.activationPackage.drvPath != "";
    integratedNiriDmsFinalConfig =
      niriDms.config.home-manager.users.fixture.programs.niri.finalConfig != null;
    integratedNiriPackagePropagated =
      niriOnly.config.home-manager.users.fixture.programs.niri.package.outPath
      == niriOnly.config.programs.niri.package.outPath;
    disabledProviderFinalConfig =
      niriDisabled.config.home-manager.users.fixture.programs.niri.finalConfig != null;
    disabledProviderPackagePropagated =
      niriDisabled.config.home-manager.users.fixture.programs.niri.package.outPath
      == niriDisabled.config.programs.niri.package.outPath;
    disabledProviderActivationPackage =
      niriDisabled.config.home-manager.users.fixture.home.activationPackage.drvPath != "";
    standaloneNiriFinalConfig = niriOnlyHome.config.programs.niri.finalConfig != null;
    standaloneNiriActivationPackage = niriOnlyHome.config.home.activationPackage.drvPath != "";
    niriOnlyPolkitAgent = niriOnly.config.systemd.user.services.niri-flake-polkit.enable;
    dmsOwnsPolkitAgent = !niriDms.config.systemd.user.services.niri-flake-polkit.enable;
    noctaliaLeavesPolkitToNiri = niriNoctalia.config.systemd.user.services.niri-flake-polkit.enable;
    niriOnlyHasGeneralBinding = builtins.hasAttr "Mod+Q" niriOnlyHome.config.programs.niri.settings.binds;
    niriOnlyHasNoDmsBinding =
      !(builtins.hasAttr "Mod+Space" niriOnlyHome.config.programs.niri.settings.binds);
    niriOnlyHasNoHandyBindings =
      !(builtins.hasAttr "Mod+D" niriOnlyHome.config.programs.niri.settings.binds)
      && !(builtins.hasAttr "Mod+Shift+D" niriOnlyHome.config.programs.niri.settings.binds);
    handyWorksWithoutNiri = !(handyOnlyHome.config.programs ? niri);
    handyNiriHasBindings =
      handyNiriHome.config.programs.niri.settings.binds."Mod+D".action.spawn == [
        "handy"
        "--toggle-transcription"
      ]
      &&
      handyNiriHome.config.programs.niri.settings.binds."Mod+Shift+D".action.spawn == [
        "handy"
        "--cancel"
      ];
    desktopShellUsesGuiPinentry =
      desktopShellHome.config.services.gpg-agent.pinentry.package.pname == "pinentry-gnome3"
      &&
      desktopShellHome.config.programs.rbw.settings.pinentry == nixpkgs.lib.getExe pkgs.pinentry-gnome3;
    desktopShellPreservesConsumerPinentry =
      desktopShellOverrideHome.config.services.gpg-agent.pinentry.package.pname == "pinentry-curses"
      &&
      desktopShellOverrideHome.config.programs.rbw.settings.pinentry
      == nixpkgs.lib.getExe pkgs.pinentry-curses;
    desktopShellIncludesClipboard = builtins.elem pkgs.wl-clipboard desktopShellHome.config.home.packages;
    dmsHasIpcBinding =
      dmsHome.config.programs.niri.settings.binds."Mod+Space".action.spawn == [
        "dms"
        "ipc"
        "call"
        "spotlight"
        "toggle"
      ];
    noctaliaNiriConfigGenerated = niriNoctaliaHome.config.xdg.configFile.niri-config.enable;
    noctaliaIsEnabled = niriNoctaliaHome.config.programs.noctalia.enable;
    noctaliaServiceEnabled = niriNoctaliaHome.config.programs.noctalia.systemd.enable;
    noctaliaUsesPinnedPackage =
      niriNoctaliaHome.config.programs.noctalia.package.outPath
      == source.inputs.noctalia.packages.${system}.default.outPath;
    noctaliaHasLauncherBinding =
      niriNoctaliaHome.config.programs.niri.settings.binds."Mod+Space".action.spawn == [
        "noctalia"
        "msg"
        "panel-toggle"
        "launcher"
      ];
    noctaliaHasControlCenterBinding =
      niriNoctaliaHome.config.programs.niri.settings.binds."Mod+S".action.spawn == [
        "noctalia"
        "msg"
        "panel-toggle"
        "control-center"
      ];
    noctaliaHasSettingsBinding =
      niriNoctaliaHome.config.programs.niri.settings.binds."Mod+Comma".action.spawn == [
        "noctalia"
        "msg"
        "settings-toggle"
      ];
    noctaliaHasHoldWindowSwitcherBinding =
      niriNoctaliaHome.config.programs.niri.settings.binds."Alt+Tab".action.spawn == [
        "noctalia"
        "msg"
        "window-switcher"
        "hold"
      ];
    noctaliaHasVolumeBinding =
      niriNoctaliaHome.config.programs.niri.settings.binds.XF86AudioRaiseVolume.action.spawn == [
        "noctalia"
        "msg"
        "volume-up"
      ]
      &&
      niriNoctaliaHome.config.programs.niri.settings.binds.XF86AudioLowerVolume.action.spawn == [
        "noctalia"
        "msg"
        "volume-down"
      ]
      &&
      niriNoctaliaHome.config.programs.niri.settings.binds.XF86AudioMute.action.spawn == [
        "noctalia"
        "msg"
        "volume-mute"
      ];
    noctaliaHasBrightnessBinding =
      niriNoctaliaHome.config.programs.niri.settings.binds.XF86MonBrightnessUp.action.spawn == [
        "noctalia"
        "msg"
        "brightness-up"
      ]
      &&
      niriNoctaliaHome.config.programs.niri.settings.binds.XF86MonBrightnessDown.action.spawn == [
        "noctalia"
        "msg"
        "brightness-down"
      ];
    noctaliaHasFloatingRule = builtins.any
      (
        rule:
        rule.open-floating == true
        && builtins.any (match: match.app-id == "dev.noctalia.Noctalia") (rule.matches or [ ])
      )
      niriNoctaliaHome.config.programs.niri.settings.window-rules;
    noctaliaWorksWithoutNiri =
      noctaliaOnlyHome.config.programs.noctalia.enable && !(noctaliaOnlyHome.config.programs ? niri);
  };
  failed = builtins.attrNames (lib.filterAttrs (_: passed: !passed) assertions);
in
if failed == [ ] then
  assertions
else
  throw "Niri/DMS fixture failed: ${lib.concatStringsSep ", " failed}"
