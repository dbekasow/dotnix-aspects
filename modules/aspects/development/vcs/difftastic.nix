{
  flake.modules.homeManager.development = {
    programs.difftastic = {
      enable = true;
      git.enable = true;

      options = {
        background = "dark";
        display = "side-by-side";
        parse-error-limit = 20;
        strip-or = true;
      };
    };

    programs.lazygit.settings.git.pagers = [{
      colorArg = "always";
      pager = "difftastic --display side-by-side";
    }];
  };
}
