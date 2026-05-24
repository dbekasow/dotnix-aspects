{
  flake.modules.homeManager.thunderbird = {
    programs.thunderbird = {
      enable = true;

      profiles.default = {
        isDefault = true;
      };

      settings = { };
    };
  };

  flake.modules.homeManager.impermanence = {
    home.persistence."/persist".directories = [ ".thunderbird" ];
  };
}

