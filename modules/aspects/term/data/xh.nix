{
  flake.modules.homeManager.xh = { pkgs, ... }: {
    home.packages = [ pkgs.xh ];
  };
}

