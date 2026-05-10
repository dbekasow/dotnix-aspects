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
  };
in
{
  flake.modules.homeManager = {
    xdg = { config, lib, ... }: {
      xdg.userDirs =
        let toAbsolute = dir: "${config.home.homeDirectory}/${dir}";
        in {
          enable = true;
          createDirectories = true;
        } // lib.mapAttrs (lib.const toAbsolute) persistedDirs;
    };

    impermanence = {
      home.persistence."/persist".directories = lib.attrValues persistedDirs;
    };
  };
}
