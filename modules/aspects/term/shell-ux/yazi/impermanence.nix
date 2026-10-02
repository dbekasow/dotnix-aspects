# Impermanence contribution for yazi — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
{
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".local/state/yazi" ];
  };
}
