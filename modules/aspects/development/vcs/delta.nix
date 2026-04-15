{
  flake.modules.homeManager.delta = { lib, pkgs, ... }: {
    programs.delta = {
      enable = true;
      enableGitIntegration = true;

      options = {
        dark = true;
        line-numbers = true;
        navigate = true;
        side-by-side = true;
      };
    };

    programs.lazygit.settings.git.pagers = [{
      colorArg = "always";
      pager = "${lib.getExe pkgs.delta} --color-only --paging=never";
    }];
  };
}
