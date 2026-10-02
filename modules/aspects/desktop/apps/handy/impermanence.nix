# Impermanence contribution for handy — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
# Handy keeps everything under its XDG config dir on Linux (upstream
# README "App Data Directory"): models/, settings, transcript history.
# The previous .local/share entry matched nothing — models re-downloaded
# after every wipe.
{
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".config/com.pais.handy" ];
  };
}
