# Impermanence contribution for nix-index-database — collector pattern:
# the entry lives with the contributing feature, not in the impermanence
# collector.
{
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [
      # nix-index-database/comma
      ".cache/nix-index"
    ];
  };
}
