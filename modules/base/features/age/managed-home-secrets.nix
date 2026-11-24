{ dotnix, ... }:
{
  # Provision the host-encrypted identity without importing any home vault.
  dotnix.home.managed-secrets-bootstrap = { host, user, ... }:
    let
      account = user.userName;
      secretName = "home-identity-${account}";
    in
    {
      provides.${host.name}.nixos = { config, lib, options, ... }:
        let
          hasVault = options ? age.secrets && options ? age.rekey;
          vaultReady = hasVault
            && config.age.rekey.generatedSecretsDir != null
            && config.age.rekey.hostPubkey != ""
            && config.age.rekey.hostPubkey != options.age.rekey.hostPubkey.default;
        in
        {
          config = lib.mkMerge ([
            {
              assertions = [{
                assertion = vaultReady;
                message = "Managed home secrets for ${host.hostName}/${account} require host.age and host.age-rekey with a host public key and a generated secrets directory.";
              }];
            }
          ] ++ lib.optional hasVault (lib.mkIf vaultReady {
            age.secrets.${secretName} = {
              generator.script = "ssh-ed25519";
              owner = account;
              mode = "600";
            };
          }));
        };
    };

  dotnix.home.managed-secrets = { host, user, ... }:
    let
      account = user.userName;
      secretName = "home-identity-${account}";
    in
    {
      includes = with dotnix.home; [ managed-secrets-bootstrap age age-rekey ];
      homeManager = { config, lib, options, osConfig, ... }:
        let
          dummyKey = options.age.rekey.hostPubkey.default;
          homeSecretsDir = config.age.rekey.secretsDir;
          hostSecretsDir = osConfig.age.rekey.secretsDir or null;
          recipientFile = if homeSecretsDir == null then null else
          "${homeSecretsDir}/hosts/${host.hostName}/home-key.pub";
        in
        {
          age.identityPaths = lib.optional (builtins.hasAttr secretName (osConfig.age.secrets or { }))
            osConfig.age.secrets.${secretName}.path;

          age.rekey = {
            # These defaults supersede the native aspect's account-wide layout.
            # Ordinary native definitions still win, e.g. for an existing vault.
            hostPubkey = lib.mkOverride 900 (
              if recipientFile != null && builtins.pathExists recipientFile then builtins.readFile recipientFile else dummyKey
            );
            localStorageDir = lib.mkOverride 900 (
              if hostSecretsDir == null then
                throw "Managed home secrets for ${host.hostName}/${account} require a host age.rekey.secretsDir or an explicit home age.rekey.localStorageDir."
              else "${hostSecretsDir}/homes/${account}/local"
            );
          };

          assertions = [{
            assertion = lib.trim config.age.rekey.hostPubkey != "" && config.age.rekey.hostPubkey != dummyKey;
            message = "Managed home secrets for ${host.hostName}/${account} are missing a recipient public key: "
              + (if recipientFile == null then "set home age.rekey.secretsDir or age.rekey.hostPubkey" else recipientFile);
          }];
        };
    };
}
