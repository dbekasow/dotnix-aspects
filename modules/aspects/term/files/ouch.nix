{
  flake.modules.homeManager.ouch = { pkgs, ... }: {
    home.packages = [ pkgs.ouch ];
  };
}

