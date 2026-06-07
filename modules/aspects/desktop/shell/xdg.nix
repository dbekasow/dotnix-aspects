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
  flake.modules.homeManager.xdg = { config, lib, ... }: {
    xdg.userDirs =
      let toAbsolute = dir: "${config.home.homeDirectory}/${dir}";
      in {
        enable = true;
        createDirectories = true;
        extraConfig = { XDG_PROJECTS_DIR = toAbsolute "projects"; };
      } // lib.mapAttrs (lib.const toAbsolute) (removeAttrs persistedDirs [ "projects" ]);
  };

  flake.modules.homeManager.impermanence = { lib, ... }: {
    home.persistence."/persist".directories = lib.attrValues persistedDirs;
  };
}
