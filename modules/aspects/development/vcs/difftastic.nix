{
  flake.modules.homeManager.difftastic = { lib, pkgs, ... }: {
    programs.difftastic = {
      enable = true;

      options = {
        background = "dark";
        color = "always";
        display = "inline";
      };
    };

    programs.lazygit.settings.git.pagers = [{
      externalDiffCommand = "${lib.getExe pkgs.difftastic} --color=always";
    }];
  };
}
