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
          home.username = "fixture";
          home.homeDirectory = "/home/fixture";
          home.stateVersion = "25.11";
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
          home-manager.useGlobalPkgs = true;
          home-manager.users.fixture = {
            imports = [
              niri.homeModules.niri
              source.modules.homeManager.niri
            ];
            programs.niri.enable = true;
          };
        }
      ]
      ++ modules;
    };

  niriOnly = nixos [ source.modules.nixos.niri ];
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
    niri.homeModules.niri
    source.modules.homeManager.niri
  ];
  niriNoctaliaHome = hm [
    niri.homeModules.niri
    source.modules.homeManager.niri
    source.modules.homeManager.noctalia
  ];
  noctaliaOnlyHome = hm [ source.modules.homeManager.noctalia ];
  dmsHome = hm [
    niri.homeModules.niri
    source.modules.homeManager.dms
  ];

  assertions = {
    niriOnlyPolkitAgent = niriOnly.config.systemd.user.services.niri-flake-polkit.enable;
    dmsOwnsPolkitAgent = !niriDms.config.systemd.user.services.niri-flake-polkit.enable;
    noctaliaLeavesPolkitToNiri = niriNoctalia.config.systemd.user.services.niri-flake-polkit.enable;
    niriOnlyHasGeneralBinding = builtins.hasAttr "Mod+Q" niriOnlyHome.config.programs.niri.settings.binds;
    niriOnlyHasNoDmsBinding =
      !(builtins.hasAttr "Mod+Space" niriOnlyHome.config.programs.niri.settings.binds);
    dmsHasIpcBinding =
      dmsHome.config.programs.niri.settings.binds."Mod+Space".action.spawn
      == [ "dms" "ipc" "call" "spotlight" "toggle" ];
    noctaliaNiriConfigGenerated = niriNoctaliaHome.config.xdg.configFile.niri-config.enable;
    noctaliaIsEnabled = niriNoctaliaHome.config.programs.noctalia.enable;
    noctaliaServiceEnabled = niriNoctaliaHome.config.programs.noctalia.systemd.enable;
    noctaliaUsesPinnedPackage =
      niriNoctaliaHome.config.programs.noctalia.package.outPath
      == source.inputs.noctalia.packages.${system}.default.outPath;
    noctaliaHasLauncherBinding =
      niriNoctaliaHome.config.programs.niri.settings.binds."Mod+Space".action.spawn
      == [ "noctalia" "msg" "panel-toggle" "launcher" ];
    noctaliaHasControlCenterBinding =
      niriNoctaliaHome.config.programs.niri.settings.binds."Mod+S".action.spawn
      == [ "noctalia" "msg" "panel-toggle" "control-center" ];
    noctaliaHasSettingsBinding =
      niriNoctaliaHome.config.programs.niri.settings.binds."Mod+Comma".action.spawn
      == [ "noctalia" "msg" "settings-toggle" ];
    noctaliaHasHoldWindowSwitcherBinding =
      niriNoctaliaHome.config.programs.niri.settings.binds."Alt+Tab".action.spawn
      == [ "noctalia" "msg" "window-switcher" "hold" ];
    noctaliaHasVolumeBinding =
      niriNoctaliaHome.config.programs.niri.settings.binds.XF86AudioRaiseVolume.action.spawn
      == [ "noctalia" "msg" "volume-up" ]
      && niriNoctaliaHome.config.programs.niri.settings.binds.XF86AudioLowerVolume.action.spawn
      == [ "noctalia" "msg" "volume-down" ]
      && niriNoctaliaHome.config.programs.niri.settings.binds.XF86AudioMute.action.spawn
      == [ "noctalia" "msg" "volume-mute" ];
    noctaliaHasBrightnessBinding =
      niriNoctaliaHome.config.programs.niri.settings.binds.XF86MonBrightnessUp.action.spawn
      == [ "noctalia" "msg" "brightness-up" ]
      && niriNoctaliaHome.config.programs.niri.settings.binds.XF86MonBrightnessDown.action.spawn
      == [ "noctalia" "msg" "brightness-down" ];
    noctaliaHasFloatingRule = builtins.any
      (
        rule:
        rule.open-floating == true
        && builtins.any (match: match.app-id == "dev.noctalia.Noctalia") (rule.matches or [ ])
      )
      niriNoctaliaHome.config.programs.niri.settings.window-rules;
    noctaliaWorksWithoutNiri =
      noctaliaOnlyHome.config.programs.noctalia.enable
      && !(noctaliaOnlyHome.config.programs ? niri);
  };
  failed = builtins.attrNames (lib.filterAttrs (_: passed: !passed) assertions);
in
if failed == [ ] then
  assertions
else
  throw "Niri/DMS fixture failed: ${lib.concatStringsSep ", " failed}"
