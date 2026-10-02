# Impermanence contribution for tealdeer — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
# Persist the tldr page cache.
{
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".cache/tealdeer" ];
  };
}
