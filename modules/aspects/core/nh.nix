{
  flake.modules.nixos.core = { config, lib, ... }: {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep 3 --keep-since 7d";
        dates = "weekly";
      };
    };

    environment.variables = {
      NH_FLAKE =
        let
          primaryUser = lib.head (lib.attrNames config.dotnix.host.members);
          inherit (config.users.users.${primaryUser}) home;
        in
        lib.mkDefault "${home}/.dotnix";
    };
  };
}
