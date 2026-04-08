{
  flake.modules.homeManager.mdcat = { pkgs, ... }: {
    home.packages = [ pkgs.mdcat ];
  };
}

