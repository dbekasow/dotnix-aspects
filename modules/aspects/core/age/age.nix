# The `generator` option is the agenix-rekey extension — age.nix must be
# imported alongside age-rekey (users.nix and yubikey-pam.nix depend on
# the same extension).
{ inputs, ... }: {
  flake-file.inputs.agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  dotnix.age.nixos =
    { host, lib, ... }:
    let
      users = builtins.attrNames host.users;
      secretsDir = "${inputs.self}/modules/hosts/${host.name}/secrets";
      vaultReady = lib.pathExists "${secretsDir}/ssh_host_ed25519_key.pub";
    in
    {
      imports = [ inputs.agenix.nixosModules.default ];

      # Keep fresh clones evaluable until host key material exists.
      age.secrets = lib.optionalAttrs vaultReady (
        lib.mergeAttrsList (
          map
            (owner: {
              "home-identity-${owner}" = {
                generator.script = "ssh-ed25519";
                mode = "600";
                inherit owner;
              };
            })
            users
        )
      );
    };

  dotnix.age.homeManager =
    { config
    , lib
    , osConfig
    , ...
    }:
    {
      imports = [ inputs.agenix.homeManagerModules.default ];

      age.identityPaths = lib.optional
        (
          osConfig.age.secrets ? "home-identity-${config.home.username}"
        )
        osConfig.age.secrets."home-identity-${config.home.username}".path;
    };

  # Impermanence contribution for age.
  dotnix.age.systemPersistence = {
    age.identityPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
  };
}
