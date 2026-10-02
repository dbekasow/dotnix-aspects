# Impermanence contribution for helix — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
{
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [
      ".cache/helix"
    ];
  };
}
