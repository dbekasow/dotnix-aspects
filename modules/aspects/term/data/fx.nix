{
  flake.modules.homeManager.fx = { pkgs, ... }: {
    home.packages = [ pkgs.fx ];
  };
}

