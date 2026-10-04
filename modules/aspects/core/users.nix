{ inputs, ... }: {
  dotnix.users.nixos = { config, host, lib, pkgs, ... }:
    let
      users = builtins.attrNames host.users;
      secretsDir = "${inputs.self}/modules/hosts/${host.name}/secrets";
      vaultReady = lib.pathExists "${secretsDir}/ssh_host_ed25519_key.pub";
      vault = lib.optionalAttrs vaultReady;
    in
    {
      users.defaultUserShell = pkgs.fish;
      # Declarative lock only with vault material; a fresh clone (no vault
      # yet) stays mutable so the console can bootstrap passwords.
      users.mutableUsers = !vaultReady;

      users.users = lib.genAttrs users (name: {
        hashedPasswordFile = lib.mkIf vaultReady
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
        users));
    };
}
