{
  flake.modules.homeManager.kubernetes = { pkgs, lib, ... }: {
    programs.kubeswitch.enable = true;
    programs.kubeswitch.settings = {
      kind = "SwitchConfig";
      showPrefix = lib.mkDefault false;
      kubeconfigStores = lib.mkDefault [ ];
    };

    programs.kubecolor.enable = true;
    programs.kubecolor.enableAlias = true;

    home.packages = with pkgs; [
      kubectl
      kubectl-tree
      kubectl-view-allocations
      kubectl-view-secret
      kubectx
      kubelogin
      kubernetes-helm
    ];
  };
}

