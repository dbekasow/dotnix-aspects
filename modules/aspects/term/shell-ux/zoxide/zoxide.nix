{
  flake.modules.homeManager.zoxide = {
    programs.zoxide = {
      enable = true;
    };
  };

  # Impermanence contribution for zoxide.
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".local/share/zoxide" ];
  };
}
