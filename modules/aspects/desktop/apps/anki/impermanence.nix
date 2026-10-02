# Impermanence contribution for anki — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
# HM's anki keeps the collection in xdg.dataHome/Anki2.
{
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".local/share/Anki2" ];
  };
}
