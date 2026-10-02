# Impermanence contribution for nix-search-tv — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
# Persist the downloaded indexes (tool default: $XDG_CACHE_HOME/nix-search-tv).
{
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".cache/nix-search-tv" ];
  };
}
