{
  flake.modules.homeManager.k9s = {
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

      plugins = { };
    };
  };
}

