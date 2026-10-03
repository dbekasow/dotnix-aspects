{ inputs
, lib
, config
, ...
}:
with lib.types;
let
  inherit (config.flake) modules;

  hostSubModule = submoduleWith {
    specialArgs = { inherit (modules) nixos; };
    modules = [
      {
        options = {
          system = lib.mkOption {
            type = str;
            default = "x86_64-linux";
            description = "Nixpkgs system tuple the host evaluates for.";
          };
          modules = lib.mkOption {
            type = listOf deferredModule;
            default = [ ];
            description = ''
              NixOS modules merged into the host's configuration; pull library
              tiers and aspects through the `nixos` argument, host-local modules
              go into the same list.
            '';
          };
          members = lib.mkOption {
            type = listOf str;
            default = [ ];
            description = "Usernames the host imports; each must match a `flake.modules.nixos.<name>` registration (modules/users/<name>/default.nix).";
          };
          nixpkgs = lib.mkOption {
            type = nullOr raw;
            default = null;
            description = ''
              Per-host nixpkgs namespace (the `lib` of a nixpkgs flake), e.g.
              `inputs.nixpkgs-stable.lib` to build this host on a different
              channel than the flake-wide pin. Null builds against the
              library's nixpkgs input, which follows the consumer's pin.
              The library's option surfaces are verified against unstable;
              a stable channel may hit upstream option renames.
            '';
          };
        };
      }
    ];
  };
in
{
  options.dotnix.hosts = lib.mkOption {
    type = attrsOf hostSubModule;
    default = { };
    description = "Host registry; every key becomes a nixosConfigurations.<key> entry.";
  };
  config = {
    flake = {
      nixosConfigurations = lib.mapAttrs
        (
          hostname: host:
            let
              # Fail at the option naming the member, not deep inside attrVals.
              unknown = lib.filter (m: !(modules.nixos ? "${m}")) host.members;
              userModules = lib.attrVals host.members modules.nixos;
            in
            assert
            unknown == [ ]
            || throw (
              "dotnix.hosts.${hostname}.members: unknown member(s) "
              + "'${lib.concatStringsSep "', '" unknown}' -- each member needs a "
              + "user module at modules/users/<name>/default.nix "
              + "(registered: ${lib.concatStringsSep " " (lib.attrNames modules.nixos)})"
            );
            (if host.nixpkgs != null then host.nixpkgs else inputs.nixpkgs.lib).nixosSystem {
              inherit (host) system;
              modules =
                host.modules
                ++ userModules
                ++ [
                  {
                    dotnix = {
                      inherit hostname;
                      inherit (host) members;
                    };
                  }
                  { networking.hostName = lib.mkDefault hostname; }
                  modules.nixos.dotnix
                ];
            }
        )
        config.dotnix.hosts;
    };
  };
}
