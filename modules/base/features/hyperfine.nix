{
  dotnix.home.hyperfine.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.hyperfine ];
  };
}
