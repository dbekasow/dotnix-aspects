# Impermanence contribution for docker — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
{
  flake.modules.homeManager.impermanence = {
    # Rootless docker keeps images and containers in the user's home;
    # /var/lib/docker would only persist a rootful daemon no member talks
    # to (WSL hosts run rootful but have no wipe to begin with).
    home.persistence."/persist".directories = [ ".local/share/docker" ];
  };
}
