{
  flake.modules.homeManager.zoxide = {
    programs.zoxide = {
      enable = true;
    };
  };

  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".local/share/zoxide" ];
  };
}

