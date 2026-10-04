{
  dotnix.dua.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.dua ];
  };
}

