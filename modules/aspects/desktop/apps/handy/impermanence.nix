# Impermanence contribution for handy — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
# models/, settings_store.json, history.db
{
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".local/share/com.pais.handy" ];
  };
}
