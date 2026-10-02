{
  # Host contract: this aspect ships no accounts. The consumer enables them
  # via accounts.email.accounts.<name>.aerc.enable and must set
  # `general.unsafe-accounts-conf = true` there — Home Manager writes
  # accounts.conf world-readable into the store, so aerc refuses to start
  # without that flag. The msmtp password comes from the vault
  # (passwordCommand), never from a store path.
  flake.modules.homeManager.aerc = {
    programs.aerc = {
      enable = true;
      extraConfig = {
        ui = {
          mouse-enabled = true;
          threading-enabled = true;
        };

        viewer.pager = "less -Rc";

        filters = {
          "text/calendar" = "calendar";
          "text/plain" = "colorize";
          "text/html" = "html | colorize";
        };

        compose.editor = "hx";
      };
    };
  };
}
