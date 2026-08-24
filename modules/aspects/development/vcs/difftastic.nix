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

    programs.lazygit.settings.git.diffRenderers = [{
      type = "extDiff";
      command = "${lib.getExe pkgs.difftastic} --color=always";
    }];
  };
}
