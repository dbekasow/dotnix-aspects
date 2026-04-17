{ inputs, lib, config, ... }: with lib.types;
let
  inherit (config.flake) modules;

  hostSubModule = submoduleWith {
    specialArgs = { inherit (modules) nixos; };
    modules = [{
      options = {
        system = lib.mkOption { type = str; default = "x86_64-linux"; };
        modules = lib.mkOption { type = listOf deferredModule; default = [ ]; };
        members = lib.mkOption { type = listOf str; default = { }; };
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
      modules.nixos.core.options.dotnix = {
        hostname = lib.mkOption { type = str; default = null; };
        host = lib.mkOption { type = hostSubModule; default = { }; };
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
              modules.nixos.core
            ];
          }
        )
        config.dotnix;
    };

    perSystem = { system, ... }: {
      packages = lib.pipe config.dotnix [
        (lib.filterAttrs (lib.const (host: host.system == system)))
        (lib.concatMapAttrs (hostname: lib.const {
          "${hostname}-iso" = config.flake.nixosConfigurations.${hostname}.config.system.build.images.iso-installer;
        }))
      ];
    };
  };
}
