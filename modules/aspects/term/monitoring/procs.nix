{
  flake.modules.homeManager.procs = { pkgs, ... }: {
    home.packages = [ pkgs.procs ];
  };
}

