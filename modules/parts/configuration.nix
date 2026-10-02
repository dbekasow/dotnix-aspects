{ inputs, lib, config, ... }: with lib.types;
let
  inherit (config.flake) modules;

  hostSubModule = submoduleWith {
    specialArgs = { inherit (modules) nixos; };
    modules = [{
      options = {
        system = lib.mkOption {
          type = str;
          default = "x86_64-linux";
          description = "Nixpkgs system tuple the host evaluates for.";
        };
        modules = lib.mkOption {
          type = listOf deferredModule;
          default = [ ];
          description = "NixOS modules merged into the host's configuration.";
        };
        members = lib.mkOption {
          type = listOf str;
          default = [ ];
          description = "Usernames whose generic profile modules the host imports.";
        };
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
      modules.nixos.dotnix = { config, ... }: {
        options.dotnix = {
          hostname = lib.mkOption { type = nullOr str; default = null; };
          host = lib.mkOption { type = hostSubModule; default = { }; };
          # True once the host's ssh identity exists. Vault-backed aspects
          # (age, users, yubikey-pam, git-credentials) follow this gate so
          # fresh consumers without key material evaluate green.
          vaultReady = lib.mkOption { type = bool; readOnly = true; };
        };

        config.dotnix.vaultReady = lib.pathExists
          "${inputs.self}/modules/hosts/${config.dotnix.hostname}/secrets/ssh_host_ed25519_key.pub";
      };

      nixosConfigurations = lib.mapAttrs
        (hostname: host:
          let userModules = lib.attrVals host.members modules.nixos; in
          inputs.nixpkgs.lib.nixosSystem {
            inherit (host) system;
            modules = host.modules ++ userModules ++ [
              { system.stateVersion = lib.mkDefault "26.11"; }
              { dotnix = { inherit hostname host; }; }
              { networking.hostName = hostname; }
              { boot.zfs.forceImportRoot = lib.mkDefault false; }
              modules.nixos.dotnix
            ];
          }
        )
        config.dotnix;
    };
  };
}
