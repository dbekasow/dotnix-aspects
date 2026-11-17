{
  dotnix.home.repomix.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.repomix ];
  };
}
