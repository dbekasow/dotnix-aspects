{
  dotnix.home.zoxide.homeManager = {
    programs.zoxide = {
      enable = true;
    };
  };

  # Impermanence contribution for zoxide.
  dotnix.home.zoxide.homePersistence = {
    home.persistence."/persist".directories = [ ".local/share/zoxide" ];
  };
}
