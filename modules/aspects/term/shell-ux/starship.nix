{
  flake.modules.homeManager.starship = {
    programs.starship = {
      enable = true;

      presets = [ "nerd-font-symbols" ];

      settings = {
        add_newline = false;

        character = {
          success_symbol = "[›](bold green)";
          error_symbol = "[›](bold red)";
        };

        directory.truncation_length = 3;

        nix_shell = {
          # detect nix shells without --pure flag
          heuristic = true;
        };
      };
    };
  };
}

