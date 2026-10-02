{
  flake.modules.homeManager.eza = {
    programs.eza = {
      enable = true;

      colors = "always";
      icons = "auto";

      git = true;
    };

    # eza as the ls replacement; uutils-noprefix still provides `ls`,
    # the aliases route to the configured eza instead.
    home.shellAliases = {
      ls = "eza";
      ll = "eza -l";
      la = "eza -a";
    };
  };
}

