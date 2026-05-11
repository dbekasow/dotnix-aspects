{
  flake.modules.homeManager.direnv = {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;

      silent = true;

      config = { };
    };
  };

  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".local/share/direnv" ];
  };
}

