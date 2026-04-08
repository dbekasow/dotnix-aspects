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

    environment.variables = {
      NH_FLAKE =
        let
          primaryUser = lib.head config.dotnix.host.members;
          inherit (config.users.users.${primaryUser}) home;
        in
        lib.mkDefault "${home}/.dotnix";
    };
  };
}
