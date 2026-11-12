{
  dotnix.home.procs.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.procs ];
  };
}
