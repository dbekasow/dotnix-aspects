{
  flake.modules.homeManager.bottom = {
    programs.bottom = {
      enable = true;

      settings = {
        flags = {
          temperature_type = "celsius";
          rate = 1000;
        };

        processes = {
          default_grouped = true;
          default_tree = false;
        };
      };
    };
  };
}

