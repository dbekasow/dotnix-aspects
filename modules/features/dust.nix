{
  dotnix.home.dust.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.dust ];
  };
}
