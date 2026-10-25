{
  dotnix.anki.homeManager = {
    programs.anki = {
      enable = true;
    };
  };

  # Impermanence contribution for anki.
  # HM's anki keeps the collection in xdg.dataHome/Anki2.
  dotnix.anki.homePersistence = {
    home.persistence."/persist".directories = [ ".local/share/Anki2" ];
  };
}
