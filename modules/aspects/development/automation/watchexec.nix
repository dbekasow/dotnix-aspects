{
  flake.modules.homeManager.watchexec = { pkgs, ... }: {
    home.packages = [ pkgs.watchexec ];
  };
}

