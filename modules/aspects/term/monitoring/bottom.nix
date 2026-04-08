{
  flake.modules.homeManager.bottom = {
    programs.bottom = {
      enable = true;

      settings = {
        flags = {
          temperature_type = "celsius";
          rate_ms = 1000;
          mem_as_value = false;
          group_processes = true;
          tree = false;
        };

        layout = {
          default_layout = "default";
        };
      };
    };
  };
}

