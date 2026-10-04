{
  flake.modules.homeManager.tealdeer = {
    programs.tealdeer = {
      enable = true;
      enableAutoUpdates = false;

      settings.updates = {
        auto_update = true;
        auto_update_interval_hours = 720;
      };
    };
  };

  # Impermanence contribution for tealdeer.
  # Persist the tldr page cache.
  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".cache/tealdeer" ];
  };
}
