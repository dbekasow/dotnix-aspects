{
  flake.modules.homeManager.terminal = {
    programs.ripgrep = {
      enable = true;

      arguments = [
        "--smart-case"
        "--follow"
        "--hidden"
        "--glob=!.git/*"
      ];
    };
  };
}

