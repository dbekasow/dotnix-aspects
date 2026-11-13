{
  dotnix.home.tokei.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.tokei ];
  };
}
