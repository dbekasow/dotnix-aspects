{
  flake.modules.homeManager.kubernetes = { pkgs, ... }: {
    programs.kubecolor.enable = true;
    programs.kubecolor.enableAlias = true;

    home.packages = with pkgs; [
      kubernetes-helm
      kubectx
      kubectl
      kubectl-tree
      kubectl-view-allocations
      kubectl-view-secret
      kubelogin-oidc
    ];

    programs.fish.functions =
      let wrap = cmd: { body = "${cmd} $argv"; wraps = cmd; }; in {
        k = wrap "kubecolor";
        kx = wrap "kubectx";
        kns = wrap "kubens";
      };
  };
}

