# Impermanence contribution for nix-tools — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
# Persist the per-user Nix cache
{
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".cache/nix" ];
  };
}
