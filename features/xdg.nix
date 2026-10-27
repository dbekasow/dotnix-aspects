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
  dotnix.xdg.homeManager = { config, lib, ... }: {
    xdg.userDirs =
      let
        toAbsolute = dir: "${config.home.homeDirectory}/${dir}";
      in
      {
        enable = true;
        createDirectories = true;
      }
      // lib.mapAttrs (lib.const toAbsolute) persistedDirs;
  };

  # Impermanence contribution — the entry lives with the contributing
  # feature, not in the impermanence collector. persistedDirs mirrors the
  # map in xdg.nix — keep both in sync.
  dotnix.xdg.homePersistence =
    { lib, ... }:
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
      home.persistence."/persist".directories = lib.attrValues persistedDirs;
    };
}
