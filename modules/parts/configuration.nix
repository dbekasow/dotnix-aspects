{ inputs, lib, config, ... }: with lib.types;
let
  inherit (config.flake) modules;

  isoSubModule = submodule {
    options = {
      enable = lib.mkOption { type = bool; default = false; };
      buildOutput = lib.mkOption { type = str; default = "images.iso-installer"; };
    };
  };

  hostSubModule = submoduleWith {
    specialArgs = { inherit (modules) nixos; };
    modules = [{
      options = {
        system = lib.mkOption { type = str; default = "x86_64-linux"; };
        modules = lib.mkOption { type = listOf deferredModule; default = [ ]; };
        members = lib.mkOption { type = listOf str; default = [ ]; };
        iso = lib.mkOption { type = isoSubModule; default = { }; };
      };
    }];
  };
in
{
  options.dotnix = lib.mkOption {
    type = attrsOf hostSubModule;
    description = "Dotnix configuration namespace";
    default = { };
  };
  config = {
    flake = {
      modules.nixos.dotnix.options.dotnix = {
        hostname = lib.mkOption { type = str; default = null; };
        host = lib.mkOption { type = hostSubModule; default = { }; };
        age = lib.mkOption { type = bool; default = true; };
      };

      nixosConfigurations = lib.mapAttrs
        (hostname: host:
          let userModules = lib.attrVals host.members modules.nixos; in
          inputs.nixpkgs.lib.nixosSystem {
            inherit (host) system;
            modules = host.modules ++ userModules ++ [
              { system.stateVersion = lib.mkDefault "26.05"; }
              { dotnix = { inherit hostname host; }; }
              { networking.hostName = hostname; }
              modules.nixos.dotnix
            ];
          }
        )
        config.dotnix;
    };

    perSystem = { system, ... }: {
      packages = lib.pipe config.dotnix [
        (lib.filterAttrs (lib.const (host: host.iso.enable && host.system == system)))
        (lib.concatMapAttrs (hostname: host: {
          "${hostname}-iso" = lib.getAttrFromPath
            (lib.splitString "." host.iso.buildOutput)
            config.flake.nixosConfigurations.${hostname}.config.system.build;
        }))
      ];
    };
  };
}
