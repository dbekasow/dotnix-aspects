{
  flake.modules.homeManager.ripgrep = {
    programs.ripgrep = {
      enable = true;

      arguments = [
        "--smart-case"
        "--follow"
        "--hidden"
        # --hidden would otherwise descend into .git
        "--glob=!.git/"
      ];
    };
  };
}

