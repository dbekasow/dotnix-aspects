{
  flake.modules.homeManager.terminal = { pkgs, ... }: {
    home.packages = [ pkgs.tokei ];
  };
}

