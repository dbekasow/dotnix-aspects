{
  dotnix.ouch.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.ouch ];
  };
}
