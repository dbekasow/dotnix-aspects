{
  dotnix.watchexec.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.watchexec ];
  };
}

