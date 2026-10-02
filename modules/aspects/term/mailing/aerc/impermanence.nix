# Impermanence contribution for aerc — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
{
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".local/share/aerc" ];
  };
}
