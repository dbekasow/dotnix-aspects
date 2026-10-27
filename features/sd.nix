{
  dotnix.sd.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.sd ];
  };
}
