_:
{
  dotnix.account.users.user = { lib, ... }: {
    isNormalUser = lib.mkDefault true;
  };

  dotnix.account.passwords = { host, inputs, user, ... }:
    if (host.class or null) != "nixos" then
      { }
    else
      let
        passwordSecret = "password-${user.userName}";
        hashedPasswordSecret = "${passwordSecret}-hashed";
        defaultSecretsDir = "${inputs.self}/modules/hosts/${host.name}/secrets";
      in
      {
        user = { host, lib, osConfig ? { }, ... }:
          let
            secrets = osConfig.age.secrets or { };
          in
          lib.optionalAttrs
            ((host.class or null) == "nixos" && builtins.hasAttr hashedPasswordSecret secrets)
            {
              hashedPasswordFile = secrets.${hashedPasswordSecret}.path;
            };

        provides.${host.name}.nixos = { config, lib, ... }:
          let
            secretsDir = lib.attrByPath [ "age" "rekey" "secretsDir" ] defaultSecretsDir config;
            vaultReady = lib.pathExists "${secretsDir}/ssh_host_ed25519_key.pub";
          in
          {
            users.mutableUsers = lib.mkDefault (!vaultReady);
            age.secrets = lib.mkIf vaultReady {
              ${passwordSecret} = {
                generator.script = "alnum";
                intermediary = true;
              };
              ${hashedPasswordSecret}.generator = {
                dependencies = [ config.age.secrets.${passwordSecret} ];
                script = { pkgs, decrypt, deps, ... }: ''
                  ${decrypt} ${lib.escapeShellArg (lib.head deps).file} | ${pkgs.openssl}/bin/openssl passwd -6 -stdin
                '';
              };
            };
          };
      };
}
