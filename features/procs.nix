{
  dotnix.procs.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.procs ];
  };
}

