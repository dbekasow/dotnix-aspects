{
  flake.modules.nixos.core = { config, ... }: {
    users.users = builtins.mapAttrs
      (_: cfg: {
        inherit (cfg) isNormalUser extraGroups;
      })
      config.dotnix.host.members;
  };
}
