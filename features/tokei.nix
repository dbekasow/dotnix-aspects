{
  dotnix.tokei.homeManager = { pkgs, ... }: {
    home.packages = [ pkgs.tokei ];
  };
}
