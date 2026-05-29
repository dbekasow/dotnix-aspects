{
  flake.modules.homeManager.aerc = {
    programs.aerc = {
      enable = true;
      extraConfig = {
        general.unsafe-accounts-conf = true;

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

  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".local/share/aerc" ];
  };
}
