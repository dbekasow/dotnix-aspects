{
  flake.modules.nixos.users = { config, lib, pkgs, ... }:
    # Accounts exist without key material; passwords follow the same vault
    # gate as age.nix (locked accounts until `agenix generate` provides
    # the material).
    let vault = lib.optionalAttrs config.dotnix.vaultReady; in
    {
      users.defaultUserShell = pkgs.fish;
      # Declarative lock only with vault material; a fresh clone (no vault
      # yet) stays mutable so the console can bootstrap passwords.
      users.mutableUsers = !config.dotnix.vaultReady;

      users.users = lib.genAttrs config.dotnix.host.members (name: {
        hashedPasswordFile = lib.mkIf config.dotnix.vaultReady
          config.age.secrets."password-${name}-hashed".path;
        isNormalUser = lib.mkDefault true;
      });

      age.secrets = vault (lib.mergeAttrsList (map
        (name: {
          "password-${name}" = {
            generator.script = "alnum";
            intermediary = true;
          };
          "password-${name}-hashed" = {
            generator = {
              dependencies = [ config.age.secrets."password-${name}" ];
              script = { pkgs, decrypt, deps, ... }: ''
                ${decrypt} ${lib.escapeShellArg (lib.head deps).file} | \
                ${pkgs.openssl}/bin/openssl passwd -6 -stdin
              '';
            };
          };

        })
        config.dotnix.host.members));
    };
}
