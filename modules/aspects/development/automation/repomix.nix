{
  flake.modules.homeManager.repomix = { pkgs, ... }: {
    home.packages = [ pkgs.repomix ];
  };
}

