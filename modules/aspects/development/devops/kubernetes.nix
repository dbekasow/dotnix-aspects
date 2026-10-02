{
  flake.modules.homeManager.kubernetes = { pkgs, ... }: {
    programs.k9s = {
      enable = true;

      settings.k9s = {
        ui = {
          enableMouse = true;
          headless = true;
          logoless = true;
          crumbsless = true;
          reactive = true;
        };

        shellPod = {
          image = "busybox";
          namespace = "default";
          limits = {
            cpu = "100m";
            memory = "100Mi";
          };
        };

        logger = {
          tail = 200;
          buffer = 5000;
          textWrap = false;
          showTime = false;
        };

        liveViewAutoRefresh = true;
        noExitOnCtrlC = true;

        thresholds = {
          cpu.critical = 90;
          cpu.warn = 70;
          memory.critical = 90;
          memory.warn = 70;
        };
      };
    };

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

    programs.fish.shellAbbrs.ks = "k9s";
  };
}
