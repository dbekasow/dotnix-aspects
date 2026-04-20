{
  flake.modules.nixos.nh = { config, lib, ... }: {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep 3 --keep-since 7d";
        dates = "weekly";
      };
    };
    environment.variables = lib.optionalAttrs (config.dotnix.host.members != [ ]) (
      let
        primary = lib.head config.dotnix.host.members;
        inherit (config.users.users."${primary}") home;
      in
      { NH_FLAKE = lib.mkDefault "${home}/.dotnix"; }
    );
  };
}
