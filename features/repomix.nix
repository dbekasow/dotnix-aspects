{
  dotnix.repomix.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.repomix ];
  };
}
