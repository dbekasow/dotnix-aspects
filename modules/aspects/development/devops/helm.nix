{
  flake.modules.homeManager.devops = { pkgs, ... }: {
    home.packages = [ pkgs.kubernetes-helm ];
  };
}

