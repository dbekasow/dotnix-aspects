{
  flake.modules.nixos.core = { lib, ... }: {
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep 3 --keep-since 7d";
        dates = "weekly";
      };
    };

    environment.variables = {
      NH_FLAKE = lib.mkDefault "home/dns/.dotnix"; # TODO
    };
  };
}
