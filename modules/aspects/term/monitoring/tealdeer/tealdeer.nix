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
}

