# Impermanence contribution for xdg — collector pattern: the entry
# lives with the contributing feature, not in the impermanence collector.
# persistedDirs mirrors the map in xdg.nix — keep both in sync.
let
  persistedDirs = {
    download = "downloads";
    documents = "documents";
    pictures = "pictures";
    videos = "videos";
    music = "music";
    desktop = "desktop";
    publicShare = "shares";
    templates = "templates";
    projects = "projects";
  };
in
{
  flake.modules.homeManager.impermanence = { lib, ... }: {
    home.persistence."/persist".directories = lib.attrValues persistedDirs;
  };
}
