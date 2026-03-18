{
  flake.modules.homeManager.devops = { pkgs, ... }: {
    home.packages = [ pkgs.argocd ];
  };
}

