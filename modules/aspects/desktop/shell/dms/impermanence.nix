# Impermanence contribution for dms — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
{
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".config/niri/dms" ];
  };
}
