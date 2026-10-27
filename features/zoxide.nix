{
  dotnix.zoxide.homeManager = {
    programs.zoxide = {
      enable = true;
    };
  };

  # Impermanence contribution for zoxide.
  dotnix.zoxide.homePersistence = {
    home.persistence."/persist".directories = [ ".local/share/zoxide" ];
  };
}
