{ inputs, lib, ... }: {
  flake.modules.nixos.dotnix = { config, ... }: {
    options.dotnix = {
      hostname = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Registry key of this host, used for host-scoped path lookups (secrets, certificates).";
      };
      members = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Usernames registered for this host.";
      };
      vaultReady = lib.mkOption {
        type = lib.types.bool;
        readOnly = true;
        description = ''
          True once modules/hosts/<name>/secrets/ssh_host_ed25519_key.pub
          exists; vault-backed aspects (age, users, yubikey-pam,
          git-credentials) gate on this so fresh consumers without key
          material evaluate green.
        '';
      };
    };

    config.dotnix.vaultReady =
      config.dotnix.hostname != null
      && lib.pathExists "${inputs.self}/modules/hosts/${config.dotnix.hostname}/secrets/ssh_host_ed25519_key.pub";
  };
}
