# Impermanence contribution for niri — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
{
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".cache/mesa_shader_cache" ];
  };
}
