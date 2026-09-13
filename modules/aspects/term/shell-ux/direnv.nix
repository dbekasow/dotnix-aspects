{ inputs, ... }: {
  flake.modules.homeManager.direnv = {
    imports = [ inputs.direnv-instant.homeModules.direnv-instant ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;

      silent = true;

      # direnv-instant replaces the shell hook — running both loads every
      # .envrc twice. nix-direnv and the direnv binary itself stay.
      enableBashIntegration = false;
      enableFishIntegration = false;
    };

    # Prompt returns immediately; direnv runs in a background daemon and
    # signals the shell when the environment is ready. If an .envrc takes
    # longer than 4s, it opens a tmux split with direnv's output.
    programs.direnv-instant.enable = true;
  };

  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".local/share/direnv" ];
  };
}
