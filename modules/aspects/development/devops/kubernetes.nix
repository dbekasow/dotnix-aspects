{
  flake.modules.homeManager.kubernetes = { pkgs, ... }: {
    programs.kubecolor.enable = true;
    programs.kubecolor.enableAlias = true;

    home.packages = with pkgs; [
      kubectl
      kubectx
      kubectl-tree
      kubectl-oidc-login
      kubectl-view-allocations
      kubectl-view-secret
      kubernetes-helm
    ];

    programs.fish.functions =
      let wrap = cmd: { body = "${cmd} $argv"; wraps = cmd; }; in {
        k = wrap "kubecolor";
        kx = wrap "kubectx";
        kns = wrap "kubens";
      };
  };
}

