{
  dotnix.dust.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.dust ];
  };
}
