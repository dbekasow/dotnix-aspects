{
  dotnix.home.watchexec.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.watchexec ];
  };
}
