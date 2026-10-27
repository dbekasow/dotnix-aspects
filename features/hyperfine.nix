{
  dotnix.hyperfine.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.hyperfine ];
  };
}
