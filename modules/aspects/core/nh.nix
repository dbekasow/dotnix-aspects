{
  dotnix.nh.nixos = { config, host, lib, ... }: {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep 3 --keep-since 7d";
        dates = "weekly";
      };
    };
    environment.variables = lib.optionalAttrs (host.users != { }) (
      let
        primary = builtins.head (builtins.attrNames host.users);
        inherit (config.users.users."${primary}") home;
      in
      { NH_FLAKE = lib.mkDefault "${home}/.dotnix"; }
    );
  };
}
