{
  flake.modules.homeManager.dust = { pkgs, ... }: {
    home.packages = [ pkgs.dust ];
  };
}

