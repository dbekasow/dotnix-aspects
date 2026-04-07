{ inputs, ... }: {
  flake.modules.nixos.core = { config, lib, ... }: {
    imports = [ inputs.agenix.nixosModules.default ];

    age.secrets = lib.mergeAttrsList (map
      (owner: {
        "home-identity-${owner}" = {
          generator.script = "ssh-ed25519";
          mode = "600";
          inherit owner;
        };
      })
      config.dotnix.host.members);
  };

  flake.modules.homeManager.core = { config, osConfig, ... }: {
    imports = [ inputs.agenix.homeManagerModules.default ];

    age.identityPaths = [
      osConfig.age.secrets."home-identity-${config.home.username}".path
    ];
  };
}
