{
  flake.modules.homeManager.devops = { pkgs, ... }: {
    programs.kubeswitch.enable = true;

    programs.kubecolor.enable = true;
    programs.kubecolor.enableAlias = true;

    home.packages = with pkgs; [
      kubectl
      kubectl-tree
      kubectl-view-allocations
      kubectl-view-secret
      kubectx
      kubelogin
    ];
  };
}

