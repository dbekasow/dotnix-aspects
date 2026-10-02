# Impermanence contribution for television — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
# Persist the channel cache.
{
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".cache/television" ];
  };
}
