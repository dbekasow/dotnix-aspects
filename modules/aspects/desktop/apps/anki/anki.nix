{
  flake.modules.homeManager.anki = {
    programs.anki = {
      enable = true;
    };
  };

  # Impermanence contribution for anki.
  # HM's anki keeps the collection in xdg.dataHome/Anki2.
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".local/share/Anki2" ];
  };
}
