# Impermanence contribution for zellij — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
{
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [
      # session_serialization = true is a no-op without this.
      ".cache/zellij"
    ];
  };
}
